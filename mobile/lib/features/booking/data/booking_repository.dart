import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'models/booking_models.dart';
import 'models/payment_models.dart';
import 'models/receipt_models.dart';

class BookingRepository {
  final Dio _dio;
  BookingRepository(this._dio);

  /// Live price estimate before booking. Location is optional; when omitted the
  /// travel fee is zero (backend rule).
  Future<PricingBreakdown> quote({
    required String providerId,
    required double estimatedHours,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final res = await _dio.post(
        '${ApiConfig.apiPrefix}/bookings/quote',
        data: {
          'providerId': providerId,
          'estimatedHours': estimatedHours,
          'latitude': ?latitude,
          'longitude': ?longitude,
        },
      );
      return PricingBreakdown.fromJson(
        res.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  /// Create a booking request (customer only). The backend snapshots the price.
  Future<Booking> createBooking({
    required String providerId,
    required String skillId,
    required DateTime scheduledAt,
    required double estimatedHours,
    String? addressLine,
    double? latitude,
    double? longitude,
    String? taskTitle,
    String? description,
    String? contactName,
    String? contactPhone,
  }) async {
    try {
      final res = await _dio.post(
        '${ApiConfig.apiPrefix}/bookings',
        data: {
          'providerId': providerId,
          'skillId': skillId,
          'scheduledAt': scheduledAt.toUtc().toIso8601String(),
          'estimatedHours': estimatedHours,
          if (_notBlank(addressLine)) 'addressLine': addressLine,
          'latitude': ?latitude,
          'longitude': ?longitude,
          if (_notBlank(taskTitle)) 'taskTitle': taskTitle,
          if (_notBlank(description)) 'description': description,
          if (_notBlank(contactName)) 'contactName': contactName,
          if (_notBlank(contactPhone)) 'contactPhone': contactPhone,
        },
      );
      return Booking.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  /// A single booking the caller is part of.
  Future<Booking> getBooking(String id) async {
    try {
      final res = await _dio.get('${ApiConfig.apiPrefix}/bookings/$id');
      return Booking.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  /// All bookings the caller is part of (as customer or provider),
  /// newest first.
  Future<List<Booking>> listMine() async {
    try {
      final res = await _dio.get('${ApiConfig.apiPrefix}/bookings');
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  /// Ordered status history for a booking (P5.5).
  Future<List<StatusEvent>> getTimeline(String id) async {
    try {
      final res = await _dio.get(
        '${ApiConfig.apiPrefix}/bookings/$id/timeline',
      );
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => StatusEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  /// Cancel a booking (either party). Returns the updated booking.
  Future<Booking> cancelBooking(String id, {String? reason}) async {
    try {
      final res = await _dio.post(
        '${ApiConfig.apiPrefix}/bookings/$id/cancel',
        data: {'reason': ?reason},
      );
      return Booking.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  // ---- Provider lifecycle actions (P4.10) ----
  Future<Booking> accept(String id) => _transition(id, 'accept');
  Future<Booking> decline(String id) => _transition(id, 'decline');
  Future<Booking> enRoute(String id) => _transition(id, 'en-route');
  Future<Booking> start(String id) => _transition(id, 'start');
  Future<Booking> complete(String id) => _transition(id, 'complete');

  Future<Booking> _transition(String id, String action) async {
    try {
      final res = await _dio.post(
        '${ApiConfig.apiPrefix}/bookings/$id/$action',
      );
      return Booking.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  // ---- Payments + escrow (P7) ----

  /// Current payment for a booking, or null if none has been started yet.
  Future<Payment?> getPayment(String bookingId) async {
    try {
      final res = await _dio.get(
        '${ApiConfig.apiPrefix}/bookings/$bookingId/payment',
      );
      return Payment.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException(_message(e));
    }
  }

  /// Start payment for a completed booking; returns a checkout session.
  Future<Payment> initiatePayment(String bookingId) async {
    try {
      final res = await _dio.post(
        '${ApiConfig.apiPrefix}/bookings/$bookingId/payment',
      );
      return Payment.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  /// Gateway capture callback (stubbed): moves funds into escrow (HELD).
  Future<Payment> confirmPayment(String paymentId) =>
      _paymentAction(paymentId, 'confirm');

  /// Release escrow to the provider (RELEASED) and settle the booking as PAID.
  Future<Payment> releasePayment(String paymentId) =>
      _paymentAction(paymentId, 'release');

  Future<Payment> _paymentAction(String paymentId, String action) async {
    try {
      final res = await _dio.post(
        '${ApiConfig.apiPrefix}/payments/$paymentId/$action',
      );
      return Payment.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  /// Receipt / invoice for a paid booking (P4.12-4.14). Available once funds are
  /// captured; returns null while the booking is unpaid (backend 400/404).
  Future<Receipt?> getReceipt(String bookingId) async {
    try {
      final res = await _dio.get(
        '${ApiConfig.apiPrefix}/bookings/$bookingId/receipt',
      );
      return Receipt.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 400 || code == 404) return null;
      throw ApiException(_message(e));
    }
  }

  bool _notBlank(String? v) => v != null && v.trim().isNotEmpty;

  String _message(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    if (e.response?.statusCode == 401) {
      return 'Your session expired. Please log in again.';
    }
    return 'Something went wrong. Please try again.';
  }
}

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(dioProvider));
});
