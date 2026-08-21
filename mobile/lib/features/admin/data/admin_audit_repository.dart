import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'models/audit_entry.dart';

/// Admin audit-log viewer (P11.10). Backed by GET /api/v1/admin/audit-log.
class AdminAuditRepository {
  final Dio _dio;
  AdminAuditRepository(this._dio);

  Future<List<AuditEntry>> getAuditLog() async {
    try {
      final res = await _dio.get('${ApiConfig.apiPrefix}/admin/audit-log');
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => AuditEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        throw ApiException(data['message'] as String);
      }
      throw ApiException('Could not load the audit log.');
    }
  }
}

final adminAuditRepositoryProvider = Provider<AdminAuditRepository>((ref) {
  return AdminAuditRepository(ref.watch(dioProvider));
});

final adminAuditProvider = FutureProvider<List<AuditEntry>>((ref) {
  return ref.watch(adminAuditRepositoryProvider).getAuditLog();
});
