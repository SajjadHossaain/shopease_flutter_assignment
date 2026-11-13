import 'package:flutter/foundation.dart';
import '../data/models/product.dart';
import '../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider(this._repository);

  final ProductRepository _repository;
  static const int _pageSize = 12;

  List<Product> _products = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasError = false;
  bool hasMore = true;
  String errorMessage = '';
  String searchQuery = '';
  int _skip = 0;

  List<Product> get products {
    final visible = _products.where((p) => !p.isDeleted).toList();
    if (searchQuery.trim().isEmpty) return visible;
    final query = searchQuery.toLowerCase().trim();
    return visible.where((p) =>
      p.title.toLowerCase().contains(query) ||
      p.category.toLowerCase().contains(query) ||
      p.description.toLowerCase().contains(query)
    ).toList();
  }

  Future<void> loadInitial() async {
    isLoading = true;
    hasError = false;
    errorMessage = '';
    _skip = 0;
    hasMore = true;
    _products = _repository.getCachedProducts();
    notifyListeners();

    try {
      final firstPage = await _repository.fetchProducts(limit: _pageSize, skip: 0);
      _products = _repository.getCachedProducts();
      _skip = _pageSize;
      hasMore = firstPage.length == _pageSize;
    } catch (_) {
      hasError = _products.isEmpty;
      errorMessage = 'Could not connect. Showing saved products if available.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore || isLoading) return;
    isLoadingMore = true;
    notifyListeners();
    try {
      final nextPage = await _repository.fetchProducts(limit: _pageSize, skip: _skip);
      _products = _repository.getCachedProducts();
      _skip += _pageSize;
      hasMore = nextPage.length == _pageSize;
    } catch (_) {
      errorMessage = 'Could not load more products. Please try again.';
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async => loadInitial();

  void setSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }

  Future<void> add(Product product) async {
    await _repository.addProduct(product);
    _products = _repository.getCachedProducts();
    notifyListeners();
  }

  Future<void> update(Product product) async {
    await _repository.updateProduct(product);
    _products = _repository.getCachedProducts();
    notifyListeners();
  }

  Future<void> delete(Product product) async {
    await _repository.deleteProduct(product);
    _products = _repository.getCachedProducts();
    notifyListeners();
  }
}
