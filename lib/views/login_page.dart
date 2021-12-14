import 'package:flutter/material.dart';
import '../themes/color.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final inputEmail = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
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
        keyboardType: TextInputType.emailAddress,
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
        child: ElevatedButton(child: const Text('Login'), onPressed: () => {}));
    final buttonForgotPassword = TextButton(
        child: const Text(
          'Reset',
          style: TextStyle(
              color: MyTheme.yellow, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        onPressed: () => {});
    final buttonRegister = TextButton(
        child: const Text(
          'register',
          style: TextStyle(
              color: MyTheme.yellow, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        onPressed: () => {});
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
        Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Or',
                      style: TextStyle(
                          color: MyTheme.gray,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    buttonRegister,
                  ])),
        )
      ],
    )));
  }
}
