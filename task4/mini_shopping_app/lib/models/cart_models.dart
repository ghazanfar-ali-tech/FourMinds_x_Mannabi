class CartItemModel {
  final String title;
  final String imageUrl;
  final double price;

  CartItemModel({required this.title, required this.imageUrl, required this.price});

  Map<String, dynamic> toJson() => {
        'title': title,
        'imageUrl': imageUrl,
        'price': price,
      };

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        title: json['title'],
        imageUrl: json['imageUrl'],
        price: json['price'],
      );
}
