import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'models/article_models.dart';

class ArticleRepository {
  final Dio _dio;
  ArticleRepository(this._dio);

  Future<List<Article>> list() async {
    try {
      final res = await _dio.get('${ApiConfig.apiPrefix}/articles');
      final data = res.data['data'] as List<dynamic>;
      return data
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  Future<Article> getBySlug(String slug) async {
    try {
      final res = await _dio.get('${ApiConfig.apiPrefix}/articles/$slug');
      return Article.fromJson(res.data['data'] as Map<String, dynamic>);
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

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository(ref.watch(dioProvider));
});
