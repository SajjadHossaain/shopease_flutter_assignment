import 'package:hive/hive.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product.dart';

class ProductRepository {
  final ProductRemoteDataSource _remote = ProductRemoteDataSource();
  Box<Product> get _box => Hive.box<Product>('products');

  List<Product> getCachedProducts() => _box.values
      .where((product) => !product.isDeleted)
      .toList()
    ..sort((a, b) => a.id.compareTo(b.id));

  Future<List<Product>> fetchProducts({required int limit, required int skip}) async {
    final remoteProducts = await _remote.fetchProducts(limit: limit, skip: skip);
    for (final remote in remoteProducts) {
      final existing = _box.get(remote.id);
      // Keep local edits; only refresh records that have not been edited locally.
      if (existing == null) {
        await _box.put(remote.id, remote);
      } else if (!existing.isLocal && !existing.isDeleted) {
        await _box.put(remote.id, remote);
      }
    }
    return remoteProducts;
  }

  Future<void> addProduct(Product product) async => _box.put(product.id, product);

  Future<void> updateProduct(Product product) async =>
      _box.put(product.id, product.copyWith(isLocal: true));

  Future<void> deleteProduct(Product product) async {
    await _box.put(product.id, product.copyWith(isDeleted: true, isLocal: true));
  }
}
