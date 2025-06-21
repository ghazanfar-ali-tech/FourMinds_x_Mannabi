import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mini_shopping_app/views/detail_page_screen.dart';
import 'package:mini_shopping_app/widgets/widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mini_shopping_app/models/product_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SavedProductScreen extends StatefulWidget {
  const SavedProductScreen({super.key});

  @override
  State<SavedProductScreen> createState() => _SavedProductScreenState();
}

class _SavedProductScreenState extends State<SavedProductScreen> {
  List<ProductModel> products = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('products') ?? [];
    setState(() {
      products = data
          .map((e) => ProductModel.fromJson(jsonDecode(e)))
          .toList();
    });
  }

  String formatPriceWithDollarSign(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.grey.shade800,
          centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text("Saved Products", style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),)),
      body: products.isEmpty
          ? Center(
              child: Text(
                "No saved products yet",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
              height: MediaQuery.of(context).size.height * 0.20,
              child: CarouselSlider.builder(
                itemCount: imageList.length,
                itemBuilder: (context, index, realIndex) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(imageList[index]),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(2, 4),
              ),
            ],
                    ),
                  );
                },
                options: CarouselOptions(
                 height: 170,
                          autoPlayInterval: const Duration(seconds: 3),
                          autoPlay: true,
                          aspectRatio: 2.0,
                          enlargeCenterPage: true,
                          viewportFraction: 0.7,
                ),
              ),
            ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                         color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        crossAxisCount: 2,
                        childAspectRatio: 7 / 9,
                      ),
                      itemCount: products.length,
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final image = product.imagePath != null && File(product.imagePath!).existsSync()
                            ? product.imagePath!
                            : 'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png';
                        
                        // Parse price
                        final priceString = product.productPrice.replaceAll("\$", "");
                        final productPriceDouble = double.tryParse(priceString) ?? 0.0;
                        final formattedPrice = formatPriceWithDollarSign(productPriceDouble);
                
                        return InkWell(
                          onTap: (){
                         
                          final imagePath = product.imagePath;
                          final isLocal = imagePath != null && File(imagePath).existsSync();
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) =>
                              DetailPageScreen(
                                 imageUrl: isLocal ? imagePath : image,
                    title: product.productName,
                    price: productPriceDouble,
                    description: product.productDescription,
                    isLocalImage: isLocal,
                                )));
                          },
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                                    child: product.imagePath != null && File(product.imagePath!).existsSync()
                                        ? Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: FileImage(File(product.imagePath!)),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: image,
                                            imageBuilder: (context, imageProvider) => Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            placeholder: (context, url) => SizedBox(
                                              width: MediaQuery.of(context).size.width,
                                              child: Shimmer.fromColors(
                                                baseColor: Colors.grey[300]!,
                                                highlightColor: Colors.white,
                                                child: Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => const Icon(Icons.error),
                                          ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.productName,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        formattedPrice,
                                        style: const TextStyle(color: Colors.green, fontSize: 14,fontWeight: FontWeight.bold),
                                      ),
                                      const Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.orange, size: 15),
                                          Icon(Icons.star, color: Colors.orange, size: 15),
                                          Icon(Icons.star, color: Colors.orange, size: 15),
                                          Icon(Icons.star, color: Colors.orange, size: 15),
                                          Icon(Icons.star_half, color: Colors.orange, size: 15),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
    );
  }
}