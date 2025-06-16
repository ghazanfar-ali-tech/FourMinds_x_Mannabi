class ProductModel {
  String productName;
  String productPrice;
  String productDescription;
  String? imagePath;
  String? category; 

  ProductModel({
    required this.productName,
    required this.productPrice,
    required this.productDescription,
    this.imagePath,
    this.category,
  });

  Map<String, dynamic> toJson() => {
        'productName': productName,
        'productPrice': productPrice,
        'productDescription': productDescription,
        'imagePath': imagePath,
        'category': category, 
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        productName: json['productName'],
        productPrice: json['productPrice'],
        productDescription: json['productDescription'],
        imagePath: json['imagePath'],
        category: json['category'], 
      );
}
