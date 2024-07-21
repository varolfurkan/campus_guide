import 'package:campus_guide/bloc/user_bloc.dart';
import 'package:campus_guide/screens/bottom_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPageWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const RegisterPageWidget({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextFormField('Ad*', Icons.perm_identity, firstNameController),
        const SizedBox(height: 10),
        _buildTextFormField('Soyad*', Icons.perm_identity, lastNameController),
        const SizedBox(height: 10),
        _buildTextFormField('E-Posta*', Icons.mail_outline, emailController),
        const SizedBox(height: 10),
        _buildTextFormField('Şifre*', Icons.lock, passwordController, obscureText: true),
        const SizedBox(height: 10),
        _buildTextFormField('Şifre Tekrar*', Icons.lock, confirmPasswordController, obscureText: true),
        const SizedBox(height: 20),
        BlocConsumer<UserCubit, UserState>(
          listener: (context, state) {
            if (state.firebaseUser != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BottomNavigator()),
              );
            } else if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
            }
          },
          builder: (context, state) {
            return state.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (passwordController.text != confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Şifreler eşleşmiyor.')),
                    );
                    return;
                  }
                  String displayName = '${firstNameController.text} ${lastNameController.text}';
                  context.read<UserCubit>().signUpWithEmailAndPassword(
                    emailController.text,
                    passwordController.text,
                    displayName,
                  );
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFF007BFF)),
                minimumSize: WidgetStateProperty.all<Size>(const Size(200, 50)),
              ),
              child: const Text(
                'Kayıt Ol',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextFormField(String labelText, IconData prefixIcon, TextEditingController controller, {bool obscureText = false}) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(),
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(prefixIcon),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Bu alan boş bırakılamaz';
          }
          return null;
        },
      ),
    );
  }
}
