import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'models/tool_models.dart';

class ToolRepository {
  final Dio _dio;
  ToolRepository(this._dio);

  Future<List<Tool>> list() async {
    try {
      final res = await _dio.get('${ApiConfig.apiPrefix}/tools');
      final data = res.data['data'] as List<dynamic>;
      return data.map((e) => Tool.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  Future<Tool> getBySlug(String slug) async {
    try {
      final res = await _dio.get('${ApiConfig.apiPrefix}/tools/$slug');
      return Tool.fromJson(res.data['data'] as Map<String, dynamic>);
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

final toolRepositoryProvider = Provider<ToolRepository>((ref) {
  return ToolRepository(ref.watch(dioProvider));
});
