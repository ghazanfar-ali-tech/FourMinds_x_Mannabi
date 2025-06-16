import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mini_shopping_app/models/cart_models.dart';
import 'package:mini_shopping_app/services/cart_services.dart';

class BuyNowScreen extends StatefulWidget {
  const BuyNowScreen({super.key});

  @override
  State<BuyNowScreen> createState() => _BuyNowScreenState();
}

class _BuyNowScreenState extends State<BuyNowScreen> {
  List<CartItemModel> cartItems = [];

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  double getTotalPrice() {
    return cartItems.fold(0.0, (sum, item) => sum + item.price);
  }

  Future<void> loadCart() async {
    final items = await CartService.getCartItems();
    setState(() => cartItems = items);
  }

  @override
  Widget build(BuildContext context) {
    final total = getTotalPrice();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.grey.shade800,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Buy Now',style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,),),
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              await CartService.clearCart();
              setState(() => cartItems = []);
            },
          ),
        ],
        // backgroundColor: Colors.pinkAccent,
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('🛒 Your cart is empty!'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: item.imageUrl.startsWith('http')
                                ? CachedNetworkImage(
                                    imageUrl: item.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const CircularProgressIndicator(),
                                    errorWidget: (_, __, ___) => const Icon(Icons.error),
                                  )
                                : Image.file(
                                    File(item.imageUrl),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.error),
                                  ),
                          ),
                          title: Text(item.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text('\$${item.price.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.grey)),
                          trailing: const Icon(Icons.shopping_cart_checkout_rounded, color: Colors.deepPurple),
                        ),
                      );
                    },
                  ),
                ),
          Container(
  margin: const EdgeInsets.only(bottom: 100), // Moves it slightly up
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: SafeArea( // Ensures it stays above system UI
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pinkAccent,
        padding: const EdgeInsets.symmetric(vertical: 14,horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
     onPressed: () {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Order Placed'),
      content: const Text('Your order has been placed successfully!'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
        
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
},

      icon:  Icon(Icons.check_circle_outline,color: Colors.white,),
      label: Text(
        'Place Order (\$${getTotalPrice().toStringAsFixed(2)})',
        style: const TextStyle(fontSize: 16,color:Colors.white ),
      ),
    ),
  ),
),

              ],
            ),
    );
  }
}
