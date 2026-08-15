import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'models/kyc_models.dart';

class KycRepository {
  final Dio _dio;
  KycRepository(this._dio);

  /// The provider's current submission, or null if none has been made.
  Future<KycSubmission?> getMine() async {
    try {
      final res = await _dio.get('${ApiConfig.apiPrefix}/kyc/me');
      return KycSubmission.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException(_message(e));
    }
  }

  Future<KycSubmission> submit({
    required String fullName,
    required String documentType,
    required String documentNumber,
    String? documentImageUrl,
  }) async {
    try {
      final res = await _dio.post(
        '${ApiConfig.apiPrefix}/kyc',
        data: {
          'fullName': fullName,
          'documentType': documentType,
          'documentNumber': documentNumber,
          if (documentImageUrl != null && documentImageUrl.isNotEmpty)
            'documentImageUrl': documentImageUrl,
        },
      );
      return KycSubmission.fromJson(res.data['data'] as Map<String, dynamic>);
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

final kycRepositoryProvider = Provider<KycRepository>((ref) {
  return KycRepository(ref.watch(dioProvider));
});
