class Shoe {
  final int? id;
  final String modelName;
  final double size;
  final double price;
  final int stockQuantity;
  final int? brandId;
  final String? brandName;

  Shoe({
    this.id,
    required this.modelName,
    required this.size,
    required this.price,
    required this.stockQuantity,
    this.brandId,
    this.brandName,
  });

  factory Shoe.fromJson(Map<String, dynamic> json) {
    return Shoe(
      id: json['id'],
      modelName: json['model_name'],
      size: double.parse(json['size'].toString()),
      price: double.parse(json['price'].toString()),
      stockQuantity: json['stock_quantity'],
      brandId: json['brand_id'],
      brandName: json['brand_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model_name': modelName,
      'size': size,
      'price': price,
      'stock_quantity': stockQuantity,
      'brand_id': brandId,
    };
  }
}