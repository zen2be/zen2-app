import 'package:flutter/material.dart';
import 'package:zen2app/helpers/helper.dart';
import 'package:zen2app/themes/color.dart';
import 'package:zen2app/views/timeslots.dart';
import 'package:zen2app/views/treatments.dart';

class Settings extends StatefulWidget {
  static _SettingsState? of(BuildContext context) =>
      context.findAncestorStateOfType<_SettingsState>();
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
            bottom: const TabBar(tabs: [
              Tab(
                  text: 'Timeslots',
                  icon: Icon(Icons.event_note, color: MyTheme.blue)),
              Tab(
                  text: 'Treatments',
                  icon: Icon(Icons.healing, color: MyTheme.blue)),
            ])),
        body: const TabBarView(children: [Timeslots(), Treatments()]),
      ),
    );
  }
}
