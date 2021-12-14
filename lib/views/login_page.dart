import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import '../themes/color.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final unvalidEmailSnackBar =
      const SnackBar(content: Text('Enter a valid email'));
  final unValidLoginSnackBar = const SnackBar(
      content: Text('These credentials do not match our records'));
  final unValidRoleSnackBar = const SnackBar(
      content: Text('This app is only for specialists or admins'));
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    final inputEmail = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            hintText: 'Email',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );

    final inputPassword = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: passwordController,
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        decoration: InputDecoration(
            hintText: 'Password',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );

    final buttonLogin = Padding(
        padding: const EdgeInsets.only(bottom: 5, top: 30),
        child: ElevatedButton(
            child: const Text('Login'),
            onPressed: () async {
              if (EmailValidator.validate(emailController.text)) {
                // email valid
                var result = await http.post(
                    Uri.parse('http://192.168.0.7:3000/auth/login'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Accept': 'application/json'
                    },
                    body: json.encode({
                      "email": emailController.text,
                      "password": passwordController.text
                    }));
                if (result.statusCode == 200) {
                  // save access token
                  Map<String, dynamic> body = jsonDecode(result.body);
                  await storage.write(
                      key: 'accessToken', value: body['access_token']);
                  String? accessToken = await storage.read(key: 'accessToken');
                  if (accessToken != null) {
                    // check if specialist or admin
                    var profileRes = await http.get(
                        Uri.parse('http://192.168.0.7:3000/auth/profile'),
                        headers: {
                          'Content-Type': 'application/json',
                          'Accept': 'application/json',
                          'Authorization': 'Bearer ' + accessToken
                        });
                    Map<String, dynamic> profile = jsonDecode(profileRes.body);
                    var role = profile['role'];
                    if (role == 'patient') {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(unValidRoleSnackBar);
                      await storage.delete(key: 'accessToken');
                    } else {
                      // redirect to home
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(unValidLoginSnackBar);
                }
              } else {
                // email not valid
                ScaffoldMessenger.of(context)
                    .showSnackBar(unvalidEmailSnackBar);
              }
            }));

    final buttonForgotPassword = TextButton(
        child: const Text(
          'Reset',
          style: TextStyle(
              color: MyTheme.yellow, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        onPressed: () => {
              // forgot password screen
            });

    return Scaffold(
        body: Center(
            child: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      children: <Widget>[
        const Text(
          'Welcome to',
          style: TextStyle(
              color: MyTheme.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Zen2',
          style: TextStyle(
              color: MyTheme.blue, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 80, top: 20),
          child: Row(
            children: const <Widget>[
              Text(
                'Login to see your ',
                style: TextStyle(
                    color: MyTheme.gray,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'appointments',
                style: TextStyle(
                    color: MyTheme.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        inputEmail,
        inputPassword,
        Row(
          children: <Widget>[
            const Text(
              'Forgot password?',
              style: TextStyle(
                  color: MyTheme.gray,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            buttonForgotPassword,
          ],
        ),
        buttonLogin,
      ],
    )));
  }
}
