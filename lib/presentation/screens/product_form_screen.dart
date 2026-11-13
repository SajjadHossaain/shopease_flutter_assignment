import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/product.dart';
import '../../providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});
  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _category;
  late final TextEditingController _image;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _title = TextEditingController(text: p?.title ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(text: p?.price.toString() ?? '');
    _category = TextEditingController(text: p?.category ?? 'General');
    _image = TextEditingController(text: p?.thumbnail ?? '');
  }

  @override
  void dispose() {
    _title.dispose(); _description.dispose(); _price.dispose();
    _category.dispose(); _image.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.product != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit product' : 'Add product')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6657E8), Color(0xFF9A70F5)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(editing ? 'Update your product details' : 'Add a new item to your collection',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 22),
            _field(_title, 'Product name', Icons.shopping_bag_outlined),
            _field(_description, 'Description', Icons.notes_rounded, maxLines: 4),
            _field(_price, 'Price (USD)', Icons.attach_money_rounded, number: true),
            _field(_category, 'Category', Icons.category_outlined),
            _field(_image, 'Image URL (optional)', Icons.image_outlined, required: false),
            const SizedBox(height: 12),
            SizedBox(height: 52, child: FilledButton.icon(
              onPressed: _save,
              icon: Icon(editing ? Icons.save_outlined : Icons.add_rounded),
              label: Text(editing ? 'Save changes' : 'Add product'),
            )),
            const SizedBox(height: 10),
            Text('Note: DummyJSON is read-only. Your changes are saved on this device using Hive.',
              textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon,
      {int maxLines = 1, bool number = false, bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        validator: (value) {
          if (!required && (value == null || value.trim().isEmpty)) return null;
          if (value == null || value.trim().isEmpty) return 'This field is required';
          if (number && (double.tryParse(value) == null || double.parse(value) <= 0)) return 'Enter a valid price';
          return null;
        },
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ProductProvider>();
    final old = widget.product;
    final product = Product(
      id: old?.id ?? -DateTime.now().microsecondsSinceEpoch,
      title: _title.text.trim(),
      description: _description.text.trim(),
      price: double.parse(_price.text.trim()),
      thumbnail: _image.text.trim(),
      category: _category.text.trim(),
      brand: old?.brand ?? 'Custom',
      rating: old?.rating ?? 0,
      stock: old?.stock ?? 0,
      images: old?.images ?? const [],
      isLocal: true,
    );
    if (old == null) {
      await provider.add(product);
    } else {
      await provider.update(product);
    }
    if (mounted) Navigator.pop(context);
  }
}
