enum MenuCategory {
  broth, // Kuah hotpot
  beef, // Daging sapi
  chicken, // Ayam
  seafood, // Hasil laut
  vegetable, // Sayuran
  tofu, // Tahu & sejenisnya
  noodle, // Mie & karbo
  rice, // Nasi
  drink, // Minuman
  dessert, // Dessert
}

class MenuItem {
  final int? id;
  final String? docId; // Firebase document ID
  final String name;
  final String description;
  final double price;
  final MenuCategory category;
  final String? image;
  final bool isAvailable;
  final DateTime createdAt;

  MenuItem({
    this.id,
    this.docId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.image,
    this.isAvailable = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'docId': docId,
      'name': name,
      'description': description,
      'price': price,
      'category': category.toString().split('.').last,
      'image': image,
      'is_available': isAvailable ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static MenuItem fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'],
      docId: map['docId'],
      name: map['name'],
      description: map['description'],
      price: map['price'].toDouble(),
      category: MenuCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
      ),
      image: map['image'],
      isAvailable: map['is_available'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  MenuItem copyWith({
    int? id,
    String? docId,
    String? name,
    String? description,
    double? price,
    MenuCategory? category,
    String? image,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      image: image ?? this.image,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
