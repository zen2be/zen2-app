import 'package:flutter/material.dart';
import 'package:zen2app/themes/color.dart';
import 'package:zen2app/views/dashboard.dart';
import 'package:zen2app/views/settings.dart';
import 'package:zen2app/views/user-mngment.dart';

import 'appointments.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List _children = [
    const Dashboard(),
    const Appointments(),
    const UserMngment(),
    const Settings()
  ];
  void _onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 30,
        selectedItemColor: MyTheme.blue,
        unselectedItemColor: MyTheme.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onTapped,
        currentIndex: _selectedIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.date_range),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Manage users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
