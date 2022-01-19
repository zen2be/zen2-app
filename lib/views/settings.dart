import 'package:flutter/material.dart';
import 'package:zen2app/helpers/helper.dart';
import 'package:zen2app/themes/color.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zen2 - Settings'),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout, color: MyTheme.black),
            tooltip: 'Log out',
            onPressed: () async => {
              await Helper.logout(),
              Navigator.pushReplacementNamed(
                context,
                '/login',
              )
            },
          ),
        ],
      ),
    );
  }
}
