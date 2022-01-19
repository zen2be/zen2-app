import 'package:flutter/material.dart';
import 'package:zen2app/helpers/helper.dart';
import 'package:zen2app/themes/color.dart';
import 'package:zen2app/views/add_user.dart';

class UserMngment extends StatelessWidget {
  const UserMngment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zen2 - Manage users'),
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
      body: Card(
        child: ListTile(
          leading: const CircleAvatar(
            child: Text('TV', style: TextStyle(color: MyTheme.lightGray)),
            backgroundColor: MyTheme.darkGray,
          ),
          title: const Text('Person 1'),
          subtitle: const Text('0442860978'),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                // source: https://www.youtube.com/watch?v=_y40_iamKAc&t=226s
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    color: const Color(0xFF737373),
                    height: 200,
                    child: Container(
                      child: Column(children: <Widget>[
                        ListTile(
                            leading: const Icon(Icons.person_remove),
                            title: const Text('Delete user'),
                            onTap: () {}),
                        ListTile(
                            leading: const Icon(Icons.manage_accounts),
                            title: const Text('Edit user'),
                            onTap: () {}),
                        ListTile(
                            leading: const Icon(Icons.call),
                            title: const Text('Call user'),
                            onTap: () {}),
                      ]),
                      decoration: const BoxDecoration(
                          color: MyTheme.lightGray,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10))),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddUser()));
        },
        backgroundColor: MyTheme.yellow,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
