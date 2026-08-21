import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'models/admin_metrics.dart';

/// Admin analytics (P11.1/P11.7). Backed by GET /api/v1/admin/metrics.
class AdminMetricsRepository {
  final Dio _dio;
  AdminMetricsRepository(this._dio);

  Future<AdminMetrics> getMetrics() async {
    try {
      final res = await _dio.get('${ApiConfig.apiPrefix}/admin/metrics');
      return AdminMetrics.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        throw ApiException(data['message'] as String);
      }
      throw ApiException('Could not load analytics.');
    }
  }
}

final adminMetricsRepositoryProvider = Provider<AdminMetricsRepository>((ref) {
  return AdminMetricsRepository(ref.watch(dioProvider));
});

final adminMetricsProvider = FutureProvider<AdminMetrics>((ref) {
  return ref.watch(adminMetricsRepositoryProvider).getMetrics();
});
