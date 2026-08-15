import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'models/notification_models.dart';

class NotificationRepository {
  final Dio _dio;
  NotificationRepository(this._dio);

  Future<List<AppNotification>> list() async {
    try {
      final res = await _dio.get('${ApiConfig.apiPrefix}/notifications');
      final data = res.data['data'] as List<dynamic>;
      return data
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  Future<int> unreadCount() async {
    try {
      final res = await _dio.get(
        '${ApiConfig.apiPrefix}/notifications/unread-count',
      );
      return (res.data['data']['count'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _dio.post('${ApiConfig.apiPrefix}/notifications/$id/read');
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.post('${ApiConfig.apiPrefix}/notifications/read-all');
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

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(dioProvider));
});
