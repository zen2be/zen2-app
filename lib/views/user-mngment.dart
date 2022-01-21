import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zen2app/helpers/helper.dart';
import 'package:zen2app/models/user.dart';
import 'package:zen2app/themes/color.dart';
import 'package:zen2app/views/add_user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserMngment extends StatefulWidget {
  const UserMngment({Key? key}) : super(key: key);

  @override
  State<UserMngment> createState() => _UserMngmentState();
}

class _UserMngmentState extends State<UserMngment> {
  late Future<List<User>> _patients;
  late Future<List<User>> _specialists;
  late Future<String> _role;
  final String apiUrl = dotenv.get('API_URL', fallback: 'NOT FOUND');
  final storage = const FlutterSecureStorage();
  final notImplementedSnackBar =
      const SnackBar(content: Text('Not implemented yet'));
  final patientDeletedSnackBar =
      const SnackBar(content: Text('Patient successfully deleted'));
  final somethingWentWrongSnackBar =
      const SnackBar(content: Text('Something went wrong, try again later'));

  Future<List<User>> getPatients() async {
    debugPrint('get patients');
    String? accessToken = await storage.read(key: 'accessToken');
    List<User> tempUsers = [];
    if (accessToken != null) {
      final response =
          await http.get(Uri.parse(apiUrl + '/patients'), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + accessToken
      });

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        for (var i = 0; i < body.length; i++) {
          // debugPrint(body[i].toString());
          tempUsers.add(User.fromJson(body[i]));
        }
      } else {
        debugPrint(response.body);
      }
    }
    return tempUsers;
  }

  Future<List<User>> getSpecialists() async {
    debugPrint('get specialists');
    String? accessToken = await storage.read(key: 'accessToken');
    List<User> tempUsers = [];
    if (accessToken != null) {
      final response =
          await http.get(Uri.parse(apiUrl + '/specialists'), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + accessToken
      });

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        for (var i = 0; i < body.length; i++) {
          // debugPrint(body[i].toString());
          tempUsers.add(User.fromJson(body[i]));
        }
      } else {
        debugPrint(response.body);
      }
    }
    return tempUsers;
  }

  Future<String> getRole() async {
    debugPrint('get role');
    String? accessToken = await storage.read(key: 'accessToken');
    String role = '';
    if (accessToken != null) {
      final response =
          await http.get(Uri.parse(apiUrl + '/auth/profile'), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + accessToken
      });

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);

        role = body['role'];
      } else {
        debugPrint(response.body);
      }
    }
    return role;
  }

  void deletePatient(User currentPatient) async {
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null) {
      final response = await http.delete(
          Uri.parse(apiUrl + '/patients/' + currentPatient.id.toString()),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ' + accessToken
          });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(patientDeletedSnackBar);
        setState(() {});
      } else {
        debugPrint(response.body);
        ScaffoldMessenger.of(context).showSnackBar(somethingWentWrongSnackBar);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _role = getRole();
    _patients = getPatients();
    _specialists = getSpecialists();
  }

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
      body: FutureBuilder(
          future: Future.wait([_role, _patients, _specialists]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final role = snapshot.data![0];
              final patients = snapshot.data![1];
              debugPrint(role);
              debugPrint(patients.toString());
              if (role == 'admin') {
              } else if (role == 'specialist') {
                return SafeArea(
                    child: ListView.builder(
                        itemCount: patients.length,
                        itemBuilder: (context, index) {
                          debugPrint(patients[index].toString());
                          User currentPatient = patients[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                    currentPatient.firstName[0] +
                                        currentPatient.lastName[0],
                                    style: const TextStyle(
                                        color: MyTheme.lightGray)),
                                backgroundColor: MyTheme.darkGray,
                              ),
                              title: Text(currentPatient.firstName +
                                  ' ' +
                                  currentPatient.lastName),
                              subtitle: Text(currentPatient.tel),
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
                                                leading: const Icon(
                                                    Icons.person_remove),
                                                title: const Text(
                                                    'Delete patient'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  showDialog<String>(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        AlertDialog(
                                                      title: const Text(
                                                          'Warning!'),
                                                      content: const Text(
                                                          'Are you sure you want to delete this patient?'),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  'Cancel'),
                                                          child: const Text(
                                                              'Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            deletePatient(
                                                                currentPatient);
                                                            Navigator.pop(
                                                                context, 'OK');
                                                          },
                                                          child:
                                                              const Text('OK'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                            ListTile(
                                                leading: const Icon(Icons.call),
                                                title:
                                                    const Text('Call patient'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                          notImplementedSnackBar);
                                                }),
                                          ]),
                                          decoration: const BoxDecoration(
                                              color: MyTheme.lightGray,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight:
                                                      Radius.circular(10))),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        }));
              }
            }
            return const Center(child: CircularProgressIndicator());
          }),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddUser()));
          },
          backgroundColor: MyTheme.yellow,
          icon: const Icon(Icons.person_add),
          label: const Text('patient')),
    );
  }
}
