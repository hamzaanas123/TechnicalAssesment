class Product {
  final int id;
  final String title;
  final String description;
  final String brand;
  final String thumbnail;
  final num price;
  final num rating;
  final int stock;
  final List<String> images;
  final String category;
  final String qr;
  final num discount;


  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.brand,
    required this.thumbnail,
    required this.price,
    required this.rating,
    required this.stock,
    required this.images,
    required this.category,
    required this.qr,
    required this.discount,
  });

  factory Product.fromJson(Map<String, dynamic> j) {
    return Product(
      id: j['id'] ?? 0,
      title: j['title'] ?? '',
      description: j['description'] ?? '',
      brand: j['brand'] ?? '',
      thumbnail: j['thumbnail'] ?? '',
      price: j['price'] ?? 0,
      rating: j['rating'] ?? 0,
      stock: j['stock'] ?? 0,
      images: (j['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      category: j['category'] ?? '',
      qr: j["meta"]["qrCode"]??'',
      discount: j["discountPercentage"]??0
    );
  }
}
