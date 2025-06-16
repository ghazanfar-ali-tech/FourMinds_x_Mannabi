import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mini_shopping_app/models/cart_models.dart';
import 'package:mini_shopping_app/routes/app_routes.dart';
import 'package:mini_shopping_app/services/cart_services.dart';
import 'package:mini_shopping_app/views/buy_now_screen.dart';
import 'package:mini_shopping_app/widgets/round_button.dart';
import 'package:readmore/readmore.dart';


class DetailPageScreen extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double price;
  final String description;
  final bool isLocalImage;

  const DetailPageScreen({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.description,
    this.isLocalImage = false,
  });

  String formatPrice(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
  
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PRODUCT IMAGE
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.33,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: isLocalImage
                    ? Image.file(File(imageUrl), fit: BoxFit.cover)
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.error, size: 40),
                      ),
              ),
            ),

            // TITLE
            Text(
              title,
              style: GoogleFonts.notoSans(
                                   fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
            ),

            const SizedBox(height: 15),

                              Row(
                    children: [
                      // Rating Box
                      _buildInfoBox(
                        icon: Icons.star,
                        label: '4.8',
                        sublabel: '117 reviews',
                        iconColor: Colors.orange,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      // Thumbs Up Box
                      _buildInfoBox(
                        icon: Icons.thumb_up_alt_rounded,
                        label: '94%',
                        sublabel: 'Positive',
                        iconColor: Colors.green,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      // Comments Box
                      _buildInfoBox(
                        icon: Icons.message_sharp,
                        label: '8',
                        sublabel: 'Comments',
                        iconColor: Colors.blueAccent,
                      ),
                    ],
                  ),

                  
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Image(
                        height: 50,
                        width: 50,
                        image: AssetImage('assets/images/discount.png'),
                      ),
                      const SizedBox(width: 10),
                      DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange,
                        ),
                        child: AnimatedTextKit(
                          totalRepeatCount: 2,
                          animatedTexts: [
                            TypewriterAnimatedText('Limited Time Offer!'),
                          ],
                        ),
                      ),
                    ],
                  ),
const SizedBox(height: 15),
              ReadMoreText(
                    description,
                    trimLines: 2,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    trimMode: TrimMode.Line,
                    trimCollapsedText: 'Read more',
                    trimExpandedText: ' Show less',
                    lessStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red),
                    moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),

            const SizedBox(height: 6),

          

            const SizedBox(height: 30),

            // ROUND BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
              formatPrice(price),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
                RoundButton(
                  title: "Add to Cart",
                  onPress: () async{
                    final cartItem = CartItemModel(title: title, imageUrl: imageUrl, price: price);
                    await CartService.addToCart(cartItem);
                  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: const [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 12),
        Expanded(child: Text("Item successfully added to cart!")),
      ],
    ),
    backgroundColor: Colors.green.shade600,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 2),
  ),
);

                    // Navigator.push(
                    // context,
                    // MaterialPageRoute(builder: (context) => const BuyNowScreen()),      
    // );
     Navigator.pushNamed(context, AppRoutes.buyNow);
                  },
                  height: 55,
                  width: size.width * 0.6,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
   Widget _buildInfoBox({required IconData icon, required String label, required String sublabel, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                sublabel,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
