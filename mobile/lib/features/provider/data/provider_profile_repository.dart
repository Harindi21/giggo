import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'models/provider_profile.dart';

/// The signed-in provider's own profile (P2.1). Backed by
/// GET/PUT /api/v1/provider/profile (the GET auto-creates a blank profile).
class MyProviderProfileRepository {
  final Dio _dio;
  MyProviderProfileRepository(this._dio);

  Future<ProviderProfile> getMyProfile() async {
    try {
      final res = await _dio.get('${ApiConfig.apiPrefix}/provider/profile');
      return ProviderProfile.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  Future<ProviderProfile> updateMyProfile(ProviderProfileUpdate update) async {
    try {
      final res = await _dio.put(
        '${ApiConfig.apiPrefix}/provider/profile',
        data: update.toJson(),
      );
      return ProviderProfile.fromJson(res.data['data'] as Map<String, dynamic>);
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

final myProviderProfileRepositoryProvider =
    Provider<MyProviderProfileRepository>((ref) {
      return MyProviderProfileRepository(ref.watch(dioProvider));
    });
