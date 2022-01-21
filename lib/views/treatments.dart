import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zen2app/models/treatment.dart';
import 'package:http/http.dart' as http;
import 'package:zen2app/themes/color.dart';

import 'add_treatment.dart';

class Treatments extends StatefulWidget {
  const Treatments({Key? key}) : super(key: key);

  @override
  _TreatmentsState createState() => _TreatmentsState();
}

class _TreatmentsState extends State<Treatments> {
  late Future<List<Treatment>> _treatments;

  final String apiUrl = dotenv.get('API_URL', fallback: 'NOT FOUND');
  final storage = const FlutterSecureStorage();

  final deletedSuccessfullySnackBar =
      const SnackBar(content: Text('Treatment successfully deleted'));
  final somethingWentWrongSnackBar =
      const SnackBar(content: Text('Something went wrong, try again later'));

  Future<List<Treatment>> getTreatments() async {
    String? accessToken = await storage.read(key: 'accessToken');
    List<Treatment> tempTreatments = [];
    if (accessToken != null) {
      final response =
          await http.get(Uri.parse(apiUrl + '/treatments'), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + accessToken
      });

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        for (var i = 0; i < body.length; i++) {
          // debugPrint(body[i].toString());
          tempTreatments.add(Treatment.fromJson(body[i]));
        }
      } else {
        debugPrint(response.body);
      }
    }
    return tempTreatments;
  }

  @override
  void initState() {
    super.initState();
    _treatments = getTreatments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _treatments,
          builder: (context, AsyncSnapshot<List<Treatment>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final treatments = snapshot.data;
              debugPrint(treatments.toString());
              return SafeArea(
                child: ListView.builder(
                    itemCount: treatments!.length,
                    itemBuilder: (context, index) {
                      Treatment currentTreatment = treatments[index];
                      return Card(
                          child: ListTile(
                              leading: const Icon(Icons.healing),
                              title: Text(currentTreatment.name),
                              trailing: IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                              color: const Color(0xFF737373),
                                              height: 200,
                                              child: Container(
                                                child: Column(
                                                    children: <Widget>[
                                                      ListTile(
                                                          leading: const Icon(
                                                              Icons.delete),
                                                          title: const Text(
                                                              'Delete treatment'),
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            showDialog<String>(
                                                                context:
                                                                    context,
                                                                builder: (context) =>
                                                                    AlertDialog(
                                                                        title: const Text(
                                                                            'Warning!'),
                                                                        content:
                                                                            const Text(
                                                                                'Are you sure you want to delete this treatment?'),
                                                                        actions: <
                                                                            Widget>[
                                                                          TextButton(
                                                                            onPressed: () =>
                                                                                Navigator.pop(context, 'Cancel'),
                                                                            child:
                                                                                const Text('Cancel'),
                                                                          ),
                                                                          TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              deleteTreatment(currentTreatment);
                                                                              Navigator.pop(context, 'OK');
                                                                            },
                                                                            child:
                                                                                const Text('OK'),
                                                                          ),
                                                                        ]));
                                                          }),
                                                    ]),
                                                decoration: const BoxDecoration(
                                                    color: MyTheme.lightGray,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft: Radius
                                                                .circular(10),
                                                            topRight:
                                                                Radius.circular(
                                                                    10))),
                                              ));
                                        });
                                  })));
                    }),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddTreatment()));
        },
        backgroundColor: MyTheme.yellow,
        label: const Text('treatment'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void deleteTreatment(Treatment currentTreatment) async {
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null) {
      final response = await http.delete(
          Uri.parse(apiUrl + '/treatments/' + currentTreatment.id.toString()),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ' + accessToken
          });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(deletedSuccessfullySnackBar);
        setState(() {});
      } else {
        debugPrint(response.body);
        ScaffoldMessenger.of(context).showSnackBar(somethingWentWrongSnackBar);
      }
    }
  }
}
