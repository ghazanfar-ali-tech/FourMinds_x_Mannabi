import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mini_shopping_app/models/product_model.dart';
import 'package:mini_shopping_app/routes/app_routes.dart';
import 'package:mini_shopping_app/widgets/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';



class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _productNameController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  final _productPriceController = TextEditingController();

  File? _productImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLastProfileData();
  }

  Future<void> _loadLastProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _productNameController.text = prefs.getString('productName') ?? '';
      _productDescriptionController.text = prefs.getString('productDescription') ?? '';
      _productPriceController.text = prefs.getString('productPrice') ?? '';
      final imagePath = prefs.getString('productImagePath');
      if (imagePath != null && File(imagePath).existsSync()) {
        _productImage = File(imagePath);
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(picked.path);
      final savedImage = await File(picked.path).copy('${directory.path}/$fileName');

      setState(() {
        _productImage = savedImage;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('productImagePath', savedImage.path);
    }
  }



  Future<void> _submitProduct() async {
    if (_productNameController.text.trim().isEmpty || _productPriceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Product Name and Price are required."),
      ));
      return;
    }

    final product = ProductModel(
      productName: _productNameController.text.trim(),
      productDescription: _productDescriptionController.text.trim(),
      productPrice: _productPriceController.text.trim(),
      category: selectedValue,
      imagePath: _productImage?.path,
    );

    final prefs = await SharedPreferences.getInstance();
    final existingProfiles = prefs.getStringList('products') ?? [];
    existingProfiles.add(jsonEncode(product.toJson()));
    await prefs.setStringList('products', existingProfiles);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Profile Saved Successfully!"),
    ));

    setState(() {
      _productNameController.clear();
      _productDescriptionController.clear();
      _productPriceController.clear();

      _productImage = null;
    });
  }
final List<String> items = [
   'Electronics',
  'Clothing',
  'Books',
  'Toys',
  'Furniture',
];
String? selectedValue;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Add Product",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      
        foregroundColor: Colors.grey.shade800,),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Center(
                          child: InkWell(
                            onTap: _pickImage,
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.85,
                                height: 190,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [Colors.white, Colors.grey.shade200],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  image: _productImage != null
                                      ? DecorationImage(image: FileImage(_productImage!), fit: BoxFit.cover)
                                      : null,
                                ),
                                child: _productImage == null
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 70,
                                            width: 70,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 8,
                                                  offset: Offset(2, 4),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Image.asset('assets/images/online-shopping.png'),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "Add product picture",
                                            style: TextStyle(color: Colors.grey[700], fontSize: 16),
                                          ),
                                        ],
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),

            ],
          ),
                               
                               Card(
                                color: const Color.fromARGB(255, 236, 235, 235),
                                elevation: 12,
                                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                              Text(
                                                            "Product Details",
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w600,
                                                              color: Colors.grey.shade800,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 16),
                                                          
                                                          // Product Name
                                                          buildModernTextField(
                                                            controller: _productNameController,
                                                            label: "Product Name",
                                                            hint: "Enter product name",
                                                            icon: Icons.shopping_bag_outlined,
                                                            validator: (value) {
                                                              if (value == null || value.trim().isEmpty) {
                                                                return 'Product name is required';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                          const SizedBox(height: 12),
                                  
                                                          // Product Price
                                                          buildModernTextField(
                                                            controller: _productPriceController,
                                                            label: "Product Price",
                                                            hint: "Enter price (e.g., Rs 1000)",
                                                            icon: Icons.attach_money_outlined,
                                                            keyboardType: TextInputType.number,
                                                            validator: (value) {
                                                              if (value == null || value.trim().isEmpty) {
                                                                return 'Product price is required';
                                                              }
                                                              return null;
                                                            },
                                                          ),  SizedBox(height: 10),
                                  _buildCategoryDropdown(),  
                                    const SizedBox(height: 12),
                                                          buildModernTextField(
                                                            controller: _productDescriptionController,
                                                            label: "Product Description",
                                                            hint: "Write a detailed description...",
                                                            icon: Icons.description_outlined,
                                                            maxLines: 3,
                                                          ),
                                                          const SizedBox(height: 24),
                                  
                                                  // Action Buttons
                                                  _buildActionButtons(),
                                  
                                    ],
                                  ),
                                ),
                               ),

                                ]),
      ),
    );
  }
    Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Category",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButton2<String>(
          isExpanded: true,
          underline: const SizedBox(),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            maxHeight: 300,
          ),
          hint: Text(
            'Select a category',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          items: items
              .map((String item) => DropdownMenuItem<String>(
                    value: item,
                    child: Row(
                      children: [
                        Icon(
                          _getCategoryIcon(item),
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          value: selectedValue,
          onChanged: (String? value) {
            setState(() {
              selectedValue = value;
            });
          },
          buttonStyleData: ButtonStyleData(
            height: 56,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.grey.shade50,
            ),
          ),
          iconStyleData: IconStyleData(
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey.shade600,
            ),
            iconSize: 24,
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Electronics':
        return Icons.devices_outlined;
      case 'Clothing':
        return Icons.checkroom_outlined;
      case 'Books':
        return Icons.menu_book_outlined;
      case 'Toys':
        return Icons.toys_outlined;
      case 'Furniture':
        return Icons.chair_outlined;
      case 'Sports & Outdoors':
        return Icons.sports_basketball_outlined;
      case 'Beauty & Health':
        return Icons.spa_outlined;
      case 'Home & Garden':
        return Icons.home_outlined;
      default:
        return Icons.category_outlined;
    }
  }
    Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_outlined),
                      SizedBox(width: 8),
                      Text(
                        "Save Product",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (_) => SavedProductScreen()),
              // );
              Navigator.pushNamed(context, AppRoutes.savedProduct);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue.shade600,
              side: BorderSide(color: Colors.blue.shade600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_outlined),
                SizedBox(width: 8),
                Text(
                  "View All Products",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
               
              ],
            ),
            
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.width * 0.3,)
      ],
    );
  }
}
 