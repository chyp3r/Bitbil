import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'constants/roots.dart';
import 'firebase_options.dart';
import 'pages/main_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/welcome_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      initialRoute: Roots.welcome,
      routes: {
        Roots.home: (context) => MainScreen(),
        Roots.login: (context) => LoginPage(),
        Roots.register: (context) => RegisterPage(),
        Roots.welcome: (context) => WelcomePage(),
      },
    );
  }
}
