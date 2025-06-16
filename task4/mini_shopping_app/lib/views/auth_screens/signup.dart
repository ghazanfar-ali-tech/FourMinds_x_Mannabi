
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mini_shopping_app/routes/app_routes.dart';
import 'package:mini_shopping_app/views/auth_screens/login_screen.dart';

import 'package:mini_shopping_app/widgets/round_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool loading = false;


  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    countryController.dispose();
    usernameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      
      body: 
     SizedBox(
          height: screenHeight,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
  width: MediaQuery.sizeOf(context).width,
  height: MediaQuery.sizeOf(context).height * 0.5,
  decoration: const BoxDecoration(
  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
   gradient: LinearGradient(
    colors: [Color(0xFF6DD5FA), Color.fromARGB(255, 15, 68, 104)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),


),

  child: Center(
    child: SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.7, 
      height: MediaQuery.sizeOf(context).height * 0.7, 
      child: Lottie.network('https://lottie.host/2b86d691-624a-4961-8c51-048ec0c90603/9tT385zTnP.json'),
    ),
  ),
),
 Positioned(
                      top: 325,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: 
                     Center(
                      /////////////////////////
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
           decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
        
        
                ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height*0.03,),
                      _buildTextField(
                        controller: usernameController,
                        hintText: 'Username',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: emailController,
                        hintText: 'Email',
                        icon: Icons.email_outlined,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: passwordController,
                        hintText: 'Password',
                        icon: Icons.lock_clock_outlined,
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: countryController,
                        hintText: 'Country',
                        icon: Icons.flag_outlined,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter country';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                RoundButton(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.13,
                  
                  gradient: const LinearGradient(
              colors: [Colors.blueAccent, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
          ),
                  title: 'Sign Up',
                  loading: loading,
                  onPress: () async{
                    if (_formKey.currentState!.validate()) {
    setState(() {
      loading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', usernameController.text.trim());
    await prefs.setString('email', emailController.text.trim());
    await prefs.setString('country', countryController.text.trim());

    setState(() {
      loading = false;
    });
                   // Navigator.push(context, MaterialPageRoute(builder:(context)=> LoginScreen()));
                    Navigator.pushNamed(context, AppRoutes.login);
                    
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                       // Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: const Text('Login',style: TextStyle(color: Color.fromARGB(255, 72, 5, 255),fontWeight: FontWeight.bold,fontSize: 15)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
   
    ),
                  ],
                ),
              ),
            ],
          ),
        ),
     );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
       decoration: InputDecoration(
  prefixIcon: Icon(icon),
  hintText: hintText,
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12), // ✅ Add this line
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(15.0),
    borderSide: const BorderSide(color: Colors.blue),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: const BorderSide(color: Colors.grey),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: const BorderSide(color: Colors.blue), // Error border styling
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: const BorderSide(color: Colors.blue),
  ),
), validator: validator,
    );
  }
}
