import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'models/assistant_models.dart';

/// Talks to the backend Knowledge-assistant proxy (RAG-05), which forwards the
/// question to the retrieval-augmented ML service and returns a cited answer.
class AssistantRepository {
  final Dio _dio;
  AssistantRepository(this._dio);

  Future<AssistantAnswer> ask(String question) async {
    try {
      final res = await _dio.post(
        '${ApiConfig.apiPrefix}/assistant/ask',
        data: {'question': question},
      );
      return AssistantAnswer.fromJson(res.data['data'] as Map<String, dynamic>);
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

final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  return AssistantRepository(ref.watch(dioProvider));
});
