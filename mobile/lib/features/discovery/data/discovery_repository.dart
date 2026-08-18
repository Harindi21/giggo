import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'models/catalog_models.dart';
import 'models/provider_models.dart';
import 'models/review.dart';

class DiscoveryRepository {
  final Dio _dio;
  DiscoveryRepository(this._dio);

  Future<List<Category>> getCategories() async {
    try {
      final res = await _dio.get('${ApiConfig.apiPrefix}/catalog/categories');
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  Future<List<Skill>> getSkills(String categoryId) async {
    try {
      final res = await _dio.get(
        '${ApiConfig.apiPrefix}/catalog/categories/$categoryId/skills',
      );
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => Skill.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  Future<List<ProviderCard>> searchProviders({
    String? categoryId,
    String? skillId,
    String? district,
    String? query,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (categoryId != null) params['categoryId'] = categoryId;
      if (skillId != null) params['skillId'] = skillId;
      if (district != null && district.isNotEmpty) {
        params['district'] = district;
      }
      if (query != null && query.isNotEmpty) params['q'] = query;
      final res = await _dio.get(
        '${ApiConfig.apiPrefix}/providers',
        queryParameters: params,
      );
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => ProviderCard.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  /// Personalised "recommended for you" providers for the signed-in customer
  /// (P3.4). Ranked by the ML recommender, with a quality-ranking fallback.
  Future<List<ProviderCard>> getRecommendations({
    int limit = 10,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final params = <String, dynamic>{'limit': limit};
      if (latitude != null) params['lat'] = latitude;
      if (longitude != null) params['lng'] = longitude;
      final res = await _dio.get(
        '${ApiConfig.apiPrefix}/recommendations',
        queryParameters: params,
      );
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => ProviderCard.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  Future<ProviderDetail> getProvider(String id) async {
    try {
      final res = await _dio.get('${ApiConfig.apiPrefix}/providers/$id');
      return ProviderDetail.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  Future<List<Review>> getProviderReviews(String providerId) async {
    try {
      final res = await _dio.get(
        '${ApiConfig.apiPrefix}/providers/$providerId/reviews',
      );
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  Future<Review> submitReview(String bookingId, int stars, String? body) async {
    try {
      final res = await _dio.post(
        '${ApiConfig.apiPrefix}/bookings/$bookingId/reviews',
        data: {
          'stars': stars,
          if (body != null && body.isNotEmpty) 'body': body,
        },
      );
      return Review.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  /// Report a review for moderation (P6.5).
  Future<void> reportReview(String reviewId) async {
    try {
      await _dio.post('${ApiConfig.apiPrefix}/reviews/$reviewId/report');
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

final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return DiscoveryRepository(ref.watch(dioProvider));
});
