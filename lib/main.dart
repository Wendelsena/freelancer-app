import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freela_app/core/firebase/firebase_config.dart';
import 'package:freela_app/features/auth/bloc/auth_bloc.dart';
import 'package:freela_app/features/auth/views/login_screen.dart';
import 'package:freela_app/features/auth/views/signup_screen.dart';
import 'package:freela_app/features/home/views/home_screen.dart'; // Importação adicionada

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
      ],
      child: MaterialApp(
        title: 'Freelancer Connect',
        debugShowCheckedModeBanner: false,
        theme: _buildAppTheme(),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignUpScreen(),
          '/home': (context) => HomeScreen()
        },
        
      ),
      
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      primaryColor: const Color(0xFF2A5298),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: const Color(0xFFF5F5F5),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}