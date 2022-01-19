import 'package:flutter/material.dart';
import 'package:zen2app/helpers/helper.dart';
import 'package:zen2app/themes/color.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zen2 - Home'),
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
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(3.0),
          children: <Widget>[
            makeDashboardItem("Schedule an appointment", Icons.schedule),
            makeDashboardItem("Create new user", Icons.person_add),
            makeDashboardItem("Pending appointments", Icons.schedule_send),
            makeDashboardItem("Edit timeslots", Icons.event_note),
          ],
        ),
      ),
    );
  }

  Card makeDashboardItem(String title, IconData icon) {
    return Card(
        elevation: 1.0,
        margin: const EdgeInsets.all(8.0),
        child: Container(
          decoration: const BoxDecoration(color: MyTheme.lightGray),
          child: InkWell(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                const SizedBox(height: 50.0),
                Center(
                    child: Icon(
                  icon,
                  size: 40.0,
                  color: MyTheme.black,
                )),
                const SizedBox(height: 20.0),
                Center(
                  child: Text(title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14.0, color: MyTheme.black)),
                )
              ],
            ),
          ),
        ));
  }
}
