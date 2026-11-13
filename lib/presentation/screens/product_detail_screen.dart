import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/product.dart';
import '../../providers/product_provider.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final int productId;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(builder: (context, provider, _) {
      Product? product;
      for (final item in provider.products) {
        if (item.id == productId) { product = item; break; }
      }
      if (product == null) {
        return const Scaffold(body: Center(child: Text('Product not found')));
      }
      final item = product;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Product details'),
          actions: [
            IconButton(
              tooltip: 'Edit product',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductFormScreen(product: item))),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Delete product',
              onPressed: () => _confirmDelete(context, provider, item),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          children: [
            Container(
              height: 270,
              decoration: BoxDecoration(color: const Color(0xFFF0EFF8), borderRadius: BorderRadius.circular(24)),
              child: CachedNetworkImage(
                imageUrl: item.thumbnail, fit: BoxFit.contain,
                errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, size: 55),
              ),
            ),
            const SizedBox(height: 20),
            Text(item.category.toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 8),
            Text(item.title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Row(children: [
              Text('\$${item.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              const SizedBox(width: 14),
              const Icon(Icons.star_rounded, color: Color(0xFFFFB547)),
              Text('${item.rating} / 5'),
            ]),
            const SizedBox(height: 20),
            const Text('Description', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(item.description, style: const TextStyle(height: 1.6)),
            const SizedBox(height: 20),
            _InfoRow(label: 'Brand', value: item.brand),
            _InfoRow(label: 'Stock', value: '${item.stock} items'),
            _InfoRow(label: 'Product ID', value: '${item.id}'),
            _InfoRow(label: 'Storage', value: item.isLocal ? 'Local / edited' : 'API product'),
            if (item.images.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text('More images', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(height: 100, child: ListView.separated(
                scrollDirection: Axis.horizontal, itemCount: item.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, index) => Container(width: 110, padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: const Color(0xFFF0EFF8), borderRadius: BorderRadius.circular(14)),
                  child: CachedNetworkImage(imageUrl: item.images[index], fit: BoxFit.contain)),
              )),
            ],
          ],
        ),
      );
    });
  }

  Future<void> _confirmDelete(BuildContext context, ProductProvider provider, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Are you sure you want to delete "${product.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton.tonal(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await provider.delete(product);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(children: [
      SizedBox(width: 105, child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
    ]),
  );
}
