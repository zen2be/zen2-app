import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zen2app/views/home_page.dart';
import 'themes/color.dart';
import 'views/login_page.dart';
import 'globals.dart' as globals;

Future<void> main() async {
  await dotenv.load();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  globals.status = prefs.getBool('isLoggedIn') ?? false;
  print(prefs.getBool('isLoggedIn'));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(
              color: MyTheme.black,
            ),
            color: MyTheme.lightGray,
            titleTextStyle: TextStyle(
                color: MyTheme.blue, fontWeight: FontWeight.bold, fontSize: 20),
            toolbarTextStyle: TextStyle(color: MyTheme.black)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: MyTheme.blue,
            textStyle: const TextStyle(
                color: MyTheme.lightGray,
                fontSize: 18,
                fontWeight: FontWeight.bold),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
      home: globals.status == false ? const LoginPage() : const HomePage(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => const HomePage(),
        '/login': (BuildContext context) => const LoginPage(),
      },
    );
  }
}
