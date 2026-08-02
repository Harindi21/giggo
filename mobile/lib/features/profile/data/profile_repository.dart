import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/data/models/user_model.dart';

class ProfileRepository {
  final Dio _dio;
  ProfileRepository(this._dio);

  Future<UserModel> getMe() async {
    try {
      final res = await _dio.get('${ApiConfig.apiPrefix}/users/me');
      return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  Future<UserModel> updateName(String fullName) async {
    try {
      final res = await _dio.patch(
        '${ApiConfig.apiPrefix}/users/me',
        data: {'fullName': fullName},
      );
      return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  String _message(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) return data['message'] as String;
    if (e.response?.statusCode == 401) return 'Your session expired. Please log in again.';
    return 'Something went wrong. Please try again.';
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(dioProvider));
});

final profileProvider = FutureProvider<UserModel>((ref) async {
  return ref.watch(profileRepositoryProvider).getMe();
});
