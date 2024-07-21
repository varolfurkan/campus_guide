import 'package:flutter/material.dart';
import '../widgets/login_widget.dart';
import '../widgets/register_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final Widget img = Image.asset(
    'img/icons/splash_icon.png',
  );
  bool isRegisterSelected = false;

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(width: 240, height: 240, child: img),
                      const SizedBox(height: 15),
                      const Text(
                        'Hoşgeldiniz',
                        style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold, color: Color(0xFF007BFF)),
                      ),
                      const SizedBox(height: 26),
                      ToggleButtons(
                        borderRadius: BorderRadius.circular(30),
                        fillColor: Colors.grey.shade300,
                        selectedColor: const Color(0xFF007BFF),
                        color: Colors.grey.shade700,
                        constraints: BoxConstraints(
                          minHeight: 50,
                          minWidth: size / 4.5,
                        ),
                        isSelected: [!isRegisterSelected, isRegisterSelected],
                        onPressed: (int index) {
                          setState(() {
                            isRegisterSelected = index == 1;
                          });
                        },
                        children: const [
                          Text('Giriş yap',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Kayıt ol',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 25),
                      if (isRegisterSelected)
                        RegisterPageWidget(
                          formKey: _formKey,
                          firstNameController: _firstNameController,
                          lastNameController: _lastNameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                        )
                      else
                        LoginPageWidget(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
