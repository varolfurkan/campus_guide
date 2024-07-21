import 'package:campus_guide/bloc/admin_bloc.dart';
import 'package:campus_guide/bloc/user_bloc.dart';
import 'package:campus_guide/screens/bottom_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPageWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginPageWidget({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextFormField('E-Posta Adresi', Icons.mail_outline, emailController),
        const SizedBox(height: 10),
        _buildTextFormField('Şifre', Icons.lock_outline, passwordController, obscureText: true),
        const SizedBox(height: 20),
        BlocConsumer<UserCubit, UserState>(
          listener: (context, state) {
            if (state.firebaseUser != null && !state.isAdmin) {
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
                  context.read<UserCubit>().signInWithEmailAndPassword(
                    emailController.text,
                    passwordController.text,
                  );
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                    const Color(0xFF007BFF)),
                minimumSize: WidgetStateProperty.all<Size>(const Size(200, 50)),
              ),
              child: const Text(
                'Giriş Yap',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 50.0, right: 50, top: 20, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 1,
                  color: Colors.black,
                ),
              ),
              const Text(
                'Ya da',
                style: TextStyle(fontSize: 24),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 1,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _showAdminLoginDialog(context);
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFF007BFF)),
            minimumSize: WidgetStateProperty.all<Size>(const Size(200, 50)),
          ),
          child: const Text(
            'Admin Girişi',
            style: TextStyle(color: Colors.white),
          ),
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

  void _showAdminLoginDialog(BuildContext context) {
    final adminEmailController = TextEditingController();
    final adminPasswordController = TextEditingController();
    final adminFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Admin Girişi'),
          content: Form(
            key: adminFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextFormField('E-Posta Adresi', Icons.mail_outline, adminEmailController),
                const SizedBox(height: 10),
                _buildTextFormField('Şifre', Icons.lock_outline, adminPasswordController, obscureText: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            BlocConsumer<AdminCubit, AdminState>(
              listener: (context, state) {
                if (state.isAdmin) {
                  Navigator.pop(context);
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
                    if (adminFormKey.currentState!.validate()) {
                      context.read<AdminCubit>().signInAsAdmin(
                        adminEmailController.text,
                        adminPasswordController.text,
                      );
                    }
                  },
                  child: const Text('Giriş Yap'),
                );
              },
            ),
          ],
        );
      },
    );
  }

}
