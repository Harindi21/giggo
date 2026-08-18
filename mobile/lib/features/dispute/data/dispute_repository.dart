import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'models/dispute_models.dart';

class DisputeRepository {
  final Dio _dio;
  DisputeRepository(this._dio);

  /// The dispute on a booking, or null if none has been raised.
  Future<Dispute?> getForBooking(String bookingId) async {
    try {
      final res = await _dio.get(
        '${ApiConfig.apiPrefix}/bookings/$bookingId/dispute',
      );
      return Dispute.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException(_message(e));
    }
  }

  Future<Dispute> raise(String bookingId, String reason) async {
    try {
      final res = await _dio.post(
        '${ApiConfig.apiPrefix}/bookings/$bookingId/dispute',
        data: {'reason': reason},
      );
      return Dispute.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  // ---- Admin ----
  Future<List<Dispute>> listByStatus(String status) async {
    try {
      final res = await _dio.get(
        '${ApiConfig.apiPrefix}/admin/disputes',
        queryParameters: {'status': status},
      );
      final data = res.data['data'] as List<dynamic>;
      return data
          .map((e) => Dispute.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  Future<Dispute> resolve(
    String id, {
    required bool refund,
    String? note,
  }) async {
    try {
      final res = await _dio.post(
        '${ApiConfig.apiPrefix}/admin/disputes/$id/resolve',
        data: {'refund': refund, 'note': ?note},
      );
      return Dispute.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

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

final disputeRepositoryProvider = Provider<DisputeRepository>((ref) {
  return DisputeRepository(ref.watch(dioProvider));
});
