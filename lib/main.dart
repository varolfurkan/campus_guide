import 'package:campus_guide/bloc/admin_bloc.dart';
import 'package:campus_guide/bloc/user_bloc.dart';
import 'package:campus_guide/firebase_options.dart';
import 'package:campus_guide/screens/bottom_navigator.dart';
import 'package:campus_guide/screens/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/find_locale.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await findSystemLocale().then((locale) {
    Intl.defaultLocale = locale;
    return initializeDateFormatting(locale, null);
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserCubit>(
          create: (context) => UserCubit(),
        ),
        BlocProvider<AdminCubit>(
          create: (context) => AdminCubit(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF007BFF),
          useMaterial3: true,
        ),
        home: const CheckOnboarding(),
      ),
    );
  }
}

class CheckOnboarding extends StatelessWidget {
  const CheckOnboarding({super.key});

  Future<bool> _isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstTime = prefs.getBool('isFirstTime');
    return isFirstTime ?? true;
  }

  @override
  Widget build(BuildContext context) {
    context.read<UserCubit>().getCurrentUser();
    context.read<AdminCubit>().getCurrentAdmin();
    return FutureBuilder<bool>(
      future: _isFirstTime(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data == true) {
          return const OnboardingScreen();
        } else {
          return const BottomNavigator();
        }
      },
    );
  }
}


