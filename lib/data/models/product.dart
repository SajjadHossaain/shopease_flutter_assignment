import 'package:hive/hive.dart';

class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String thumbnail;
  final String category;
  final String brand;
  final double rating;
  final int stock;
  final List<String> images;
  final bool isLocal;
  final bool isDeleted;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.thumbnail,
    required this.category,
    this.brand = 'Unknown',
    this.rating = 0,
    this.stock = 0,
    this.images = const [],
    this.isLocal = false,
    this.isDeleted = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num).toInt(),
      title: json['title']?.toString() ?? 'Untitled product',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      thumbnail: json['thumbnail']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      brand: json['brand']?.toString() ?? 'Unknown',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      images: (json['images'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }

  Product copyWith({
    String? title, String? description, double? price, String? thumbnail,
    String? category, String? brand, double? rating, int? stock,
    List<String>? images, bool? isLocal, bool? isDeleted,
  }) => Product(
    id: id, title: title ?? this.title, description: description ?? this.description,
    price: price ?? this.price, thumbnail: thumbnail ?? this.thumbnail,
    category: category ?? this.category, brand: brand ?? this.brand,
    rating: rating ?? this.rating, stock: stock ?? this.stock,
    images: images ?? this.images, isLocal: isLocal ?? this.isLocal,
    isDeleted: isDeleted ?? this.isDeleted,
  );
}

/// Manual Hive adapter: no code generation is needed for this beginner project.
class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < count; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Product(
      id: fields[0] as int,
      title: fields[1] as String,
      description: fields[2] as String,
      price: (fields[3] as num).toDouble(),
      thumbnail: fields[4] as String,
      category: fields[5] as String,
      brand: fields[6] as String,
      rating: (fields[7] as num).toDouble(),
      stock: fields[8] as int,
      images: (fields[9] as List).cast<String>(),
      isLocal: fields[10] as bool,
      isDeleted: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.title)
      ..writeByte(2)..write(obj.description)
      ..writeByte(3)..write(obj.price)
      ..writeByte(4)..write(obj.thumbnail)
      ..writeByte(5)..write(obj.category)
      ..writeByte(6)..write(obj.brand)
      ..writeByte(7)..write(obj.rating)
      ..writeByte(8)..write(obj.stock)
      ..writeByte(9)..write(obj.images)
      ..writeByte(10)..write(obj.isLocal)
      ..writeByte(11)..write(obj.isDeleted);
  }
}
