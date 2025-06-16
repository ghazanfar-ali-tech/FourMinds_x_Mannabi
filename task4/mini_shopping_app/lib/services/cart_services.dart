import 'dart:convert';
import 'package:mini_shopping_app/models/cart_models.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CartService {
  static const String _cartKey = 'cart_items';

  static Future<void> addToCart(CartItemModel item) async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getStringList(_cartKey) ?? [];
    cartData.add(jsonEncode(item.toJson()));
    await prefs.setStringList(_cartKey, cartData);
  }

  static Future<List<CartItemModel>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getStringList(_cartKey) ?? [];
    return cartData.map((e) => CartItemModel.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
