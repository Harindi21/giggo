import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../booking/data/models/payment_models.dart';
import 'models/earnings.dart';

/// Provider earnings + withdrawals (P7.10). Backed by /api/v1/provider/earnings.
class EarningsRepository {
  final Dio _dio;
  EarningsRepository(this._dio);

  static const _base = '${ApiConfig.apiPrefix}/provider/earnings';

  Future<EarningsSummary> getSummary() async {
    try {
      final res = await _dio.get(_base);
      return EarningsSummary.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  Future<List<Payment>> getHistory() async {
    try {
      final res = await _dio.get('$_base/history');
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  Future<List<Payout>> getMyPayouts() async {
    try {
      final res = await _dio.get('$_base/payouts');
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => Payout.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  /// Request a withdrawal; a null amount withdraws the full available balance.
  Future<Payout> requestPayout({double? amount}) async {
    try {
      final res = await _dio.post('$_base/payouts', data: {'amount': ?amount});
      return Payout.fromJson(res.data['data'] as Map<String, dynamic>);
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

final earningsRepositoryProvider = Provider<EarningsRepository>((ref) {
  return EarningsRepository(ref.watch(dioProvider));
});
