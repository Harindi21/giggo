import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'models/working_hour.dart';

/// A provider's weekly working hours (P2.10). Backed by /provider/availability.
class AvailabilityRepository {
  final Dio _dio;
  AvailabilityRepository(this._dio);

  static const _base = '${ApiConfig.apiPrefix}/provider/availability';

  Future<List<WorkingHour>> getMyAvailability() async {
    try {
      final res = await _dio.get(_base);
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => WorkingHour.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  Future<List<WorkingHour>> setMyAvailability(List<WorkingHour> days) async {
    try {
      final res = await _dio.put(
        _base,
        data: {'days': days.map((d) => d.toJson()).toList()},
      );
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => WorkingHour.fromJson(e as Map<String, dynamic>))
          .toList();
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

final availabilityRepositoryProvider = Provider<AvailabilityRepository>((ref) {
  return AvailabilityRepository(ref.watch(dioProvider));
});

final myAvailabilityProvider = FutureProvider<List<WorkingHour>>((ref) {
  return ref.watch(availabilityRepositoryProvider).getMyAvailability();
});
