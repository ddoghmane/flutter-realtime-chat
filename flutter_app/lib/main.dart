import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/login_page.dart';
import 'pages/chat_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final loggedIn = prefs.getBool('loggedIn') ?? false;

  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;

  const MyApp({
    super.key,
    required this.loggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Realtime Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: loggedIn
          ? const ChatPage()
          : const LoginPage(),
    );
  }
}
