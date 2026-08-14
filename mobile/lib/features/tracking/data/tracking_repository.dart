import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'models/eta_info.dart';
import 'models/provider_location.dart';

class TrackingRepository {
  final Dio _dio;
  TrackingRepository(this._dio);

  /// ETA from the provider's last-known position to the destination.
  Future<EtaInfo> getEta(String jobId, double destLat, double destLng) async {
    try {
      final res = await _dio.get(
        '${ApiConfig.apiPrefix}/tracking/$jobId/eta',
        queryParameters: {'destLat': destLat, 'destLng': destLng},
      );
      return EtaInfo.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  /// Last-known location (for the initial render before the socket delivers one).
  Future<ProviderLocation?> getLastKnown(String jobId) async {
    try {
      final res = await _dio.get('${ApiConfig.apiPrefix}/tracking/$jobId/location');
      return ProviderLocation.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null; // none yet
      throw ApiException(_message(e));
    }
  }

  String _message(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) return data['message'] as String;
    return 'Could not reach the tracking service.';
  }
}

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return TrackingRepository(ref.watch(dioProvider));
});
