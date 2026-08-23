import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'models/article_models.dart';

class ArticleRepository {
  final Dio _dio;
  ArticleRepository(this._dio);

  Future<List<Article>> list({String? q}) async {
    try {
      final res = await _dio.get(
        '${ApiConfig.apiPrefix}/articles',
        queryParameters: {if (q != null && q.isNotEmpty) 'q': q},
      );
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

  /// "Recommended for you" guides, matched to the provider's skills (P9.3).
  Future<List<Article>> getRecommended() async {
    try {
      final res = await _dio.get('${ApiConfig.apiPrefix}/articles/recommended');
      final data = res.data['data'] as List<dynamic>;
      return data
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  /// Record a view (P9.4).
  Future<Article> recordView(String slug) async {
    try {
      final res = await _dio.post('${ApiConfig.apiPrefix}/articles/$slug/view');
      return Article.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  /// Rate an article's helpfulness 1–5 (P9.4).
  Future<Article> rate(String slug, int rating) async {
    try {
      final res = await _dio.post(
        '${ApiConfig.apiPrefix}/articles/$slug/rate',
        data: {'rating': rating},
      );
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
