import 'package:dio/dio.dart';
import '../models/product.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://dummyjson.com',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ));

  final Dio _dio;

  Future<List<Product>> fetchProducts({required int limit, required int skip}) async {
    final response = await _dio.get('/products', queryParameters: {
      'limit': limit,
      'skip': skip,
    });
    final list = response.data['products'] as List;
    return list.map((item) => Product.fromJson(item)).toList();
  }
}
