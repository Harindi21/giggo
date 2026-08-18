import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'models/order_models.dart';

class OrderRepository {
  final Dio _dio;
  OrderRepository(this._dio);

  Future<ToolOrder> place({
    required String toolId,
    required int quantity,
    String? contactName,
    String? contactPhone,
    String? shippingAddress,
  }) async {
    try {
      final res = await _dio.post(
        '${ApiConfig.apiPrefix}/orders',
        data: {
          'toolId': toolId,
          'quantity': quantity,
          'contactName': ?contactName,
          'contactPhone': ?contactPhone,
          'shippingAddress': ?shippingAddress,
        },
      );
      return ToolOrder.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  Future<ToolOrder> pay(String id) => _action(id, 'pay');
  Future<ToolOrder> cancel(String id) => _action(id, 'cancel');

  Future<ToolOrder> _action(String id, String action) async {
    try {
      final res = await _dio.post('${ApiConfig.apiPrefix}/orders/$id/$action');
      return ToolOrder.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_message(e));
    }
  }

  Future<List<ToolOrder>> list() async {
    try {
      final res = await _dio.get('${ApiConfig.apiPrefix}/orders');
      final data = res.data['data'] as List<dynamic>;
      return data
          .map((e) => ToolOrder.fromJson(e as Map<String, dynamic>))
          .toList();
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

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(dioProvider));
});
