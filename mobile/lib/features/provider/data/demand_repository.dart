import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'models/demand.dart';

/// Provider demand insights (AI #4). Backed by GET /api/v1/provider/demand.
class DemandRepository {
  final Dio _dio;
  DemandRepository(this._dio);

  Future<List<CategoryDemand>> getMyDemand() async {
    try {
      final res = await _dio.get('${ApiConfig.apiPrefix}/provider/demand');
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => CategoryDemand.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        throw ApiException(data['message'] as String);
      }
      throw ApiException('Could not load demand insights.');
    }
  }
}

final demandRepositoryProvider = Provider<DemandRepository>((ref) {
  return DemandRepository(ref.watch(dioProvider));
});

final myDemandProvider = FutureProvider<List<CategoryDemand>>((ref) {
  return ref.watch(demandRepositoryProvider).getMyDemand();
});
