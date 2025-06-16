import 'package:flutter/material.dart';

Widget buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade500),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }


     List<String> imageList = [
    'https://img.pikbest.com/origin/05/66/81/74tpIkbEsTghn.jpg!w700wp',
  'https://images.pexels.com/photos/325876/pexels-photo-325876.jpeg',
  'https://thumbs.dreamstime.com/b/sale-promotion-banner-cricket-season-illustration-49950785.jpg',
'https://www.dukeindia.com/cdn/shop/files/Banner_2_d986a525-a847-4e44-8da6-9d8b8f7c11e7.jpg?v=1723872360',
'https://c8.alamy.com/comp/2RXBM2E/mid-season-sale-up-to-50-off-sign-in-a-shop-window-displaying-mens-clothing-glasgow-scotland-uk-europe-2RXBM2E.jpg',
'https://www.shutterstock.com/image-photo/sale-sign-on-cloth-store-600nw-436393411.jpg',
  'https://news.lenovo.com/wp-content/uploads/2024/02/0416-1024x683.jpg',
  'https://i.pinimg.com/736x/0a/33/98/0a3398bcbe0297ca8102ea346de7c516.jpg',
  'https://www.watsons.com/media/wysiwyg/C2415NFA_G1_Block_Secondary6.jpg',
  'https://www.thefashionisto.com/wp-content/uploads/2023/08/Bomber-Jacket-Outfits-Men.jpg',
  'https://www.theballs.in/wp-content/uploads/2023/01/Cricket-Shoes-Online-with-50-Off-860x445.jpg',
  'https://as2.ftcdn.net/v2/jpg/05/01/56/19/1000_F_501561996_vICV6nqNAngNZbguqro5cS3a8t00nMjv.jpg',
  'https://i0.wp.com/uchify.com/wp-content/uploads/2024/05/Uchify-Sams-cover-images-53.jpg?resize=1080%2C565&ssl=1',
  'https://www.livemint.com/lm-img/img/2024/06/24/600x338/best_gaming_laptop_1719212951650_1719212965476.jpg',
  //'https://images-eu.ssl-images-amazon.com/images/G/31/img24/Sports/April/Coop/Jaspo/cricket_1242_x_450_px.png'
  //'https://www.hindustantimes.com/ht-img/img/2024/09/04/550x309/pexels-pixabay-276528_1725434095298_1725434103217.jpg'
  ];