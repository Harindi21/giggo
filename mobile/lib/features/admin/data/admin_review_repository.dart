import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'models/admin_review_models.dart';

class AdminReviewRepository {
  final Dio _dio;
  AdminReviewRepository(this._dio);

  Future<List<AdminReview>> list({bool reportedOnly = false}) async {
    try {
      final res = await _dio.get(
        '${ApiConfig.apiPrefix}/admin/reviews',
        queryParameters: {'reportedOnly': reportedOnly},
      );
      final data = res.data['data'] as List<dynamic>;
      return data
          .map((e) => AdminReview.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  Future<AdminReview> hide(String id, String? reason) =>
      _post(id, 'hide', {'reason': ?reason});

  Future<AdminReview> restore(String id) => _post(id, 'restore', null);

  Future<AdminReview> _post(String id, String action, Object? data) async {
    try {
      final res = await _dio.post(
        '${ApiConfig.apiPrefix}/admin/reviews/$id/$action',
        data: data,
      );
      return AdminReview.fromJson(res.data['data'] as Map<String, dynamic>);
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

final adminReviewRepositoryProvider = Provider<AdminReviewRepository>((ref) {
  return AdminReviewRepository(ref.watch(dioProvider));
});
