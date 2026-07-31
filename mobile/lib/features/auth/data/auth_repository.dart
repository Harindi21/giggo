import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'models/register_request.dart';
import 'models/user_model.dart';

import 'models/login_request.dart';
import 'models/auth_result.dart';

class AuthRepository {
  final Dio _dio;
  AuthRepository(this._dio);

  Future<UserModel> register(RegisterRequest request) async {
    try {
      final res = await _dio.post(
        '${ApiConfig.apiPrefix}/auth/register',
        data: request.toJson(),
      );
      final data = res.data['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(_messageFrom(e));
    }
  }

  Future<AuthResult> login(LoginRequest request) async {
    try {
      final res = await _dio.post(
        '${ApiConfig.apiPrefix}/auth/login',
        data: request.toJson(),
      );
      final data = res.data['data'] as Map<String, dynamic>;
      return AuthResult.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(_messageFrom(e));
    }
  }

  String _messageFrom(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String; // backend's friendly message
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Cannot reach the server. Is the backend running?';
    }
    return 'Something went wrong. Please try again.';
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
}


);
