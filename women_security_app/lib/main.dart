import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_security_app/child/bottom_page.dart';
import 'package:women_security_app/child/child_login_screen.dart';
import 'package:women_security_app/db/share_pref.dart';
import 'package:women_security_app/parent/parent_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MySharedPreference.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = true;
  Widget? homeScreen;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    String? userType = await MySharedPreference.getUserType();
    if (mounted) {
      setState(() {
        isLoading = false;
        if (userType == "Child") {
          // Child user logged in
          homeScreen = BottomPage();
        } else if (userType == "Parent") {
          // Parent user logged in
          homeScreen = ParentHomeScreen();
        } else {
          // Not logged in or unknown user type
          homeScreen = LoginScreen();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.firaSansTextTheme(
          Theme.of(context).textTheme,
        ),
        primarySwatch: Colors.blue,
      ),
      home: isLoading ? SplashScreen() : homeScreen ?? LoginScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
