import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AddTreatment extends StatefulWidget {
  const AddTreatment({Key? key}) : super(key: key);

  @override
  _AddTreatmentState createState() => _AddTreatmentState();
}

class _AddTreatmentState extends State<AddTreatment> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  final _addTreatmentForm = GlobalKey<FormState>();

  final String apiUrl = dotenv.get('API_URL', fallback: 'NOT FOUND');
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Zen2 - Add treatment'),
        ),
        body: Form(
            key: _addTreatmentForm,
            child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 10.0),
                    child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        controller: nameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            hintText: 'Name',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)))),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        controller: descriptionController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 8,
                        decoration: InputDecoration(
                            hintText: 'Description',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)))),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: 'Duration',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)))),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: 'Price',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)))),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 5, top: 30),
                      child: ElevatedButton(
                          child: const Text('Create new treatment'),
                          onPressed: () async {
                            if (_addTreatmentForm.currentState!.validate()) {
                              String? accessToken =
                                  await storage.read(key: 'accessToken');
                              if (accessToken != null) {
                                var profileRes = await http.get(
                                    Uri.parse(apiUrl + '/auth/profile'),
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'Accept': 'application/json',
                                      'Authorization': 'Bearer ' + accessToken
                                    });
                                Map<String, dynamic> profile =
                                    jsonDecode(profileRes.body);
                                debugPrint(profile['id'].toString());
                                final response = await http.post(
                                    Uri.parse(apiUrl + '/treatments'),
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'Accept': 'application/json',
                                      'Authorization': 'Bearer ' + accessToken
                                    },
                                    body: json.encode({
                                      "name": nameController.text,
                                      "description": descriptionController.text,
                                      "duration":
                                          int.parse(durationController.text),
                                      "price": int.parse(priceController.text),
                                      "specialist": {"id": profile['id']}
                                    }));
                                if (response.statusCode == 201) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Treatment successfully created')),
                                  );
                                } else {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Something went wrong, try again later')),
                                  );
                                }
                                debugPrint(response.body);
                              }
                            }
                          }))
                ])));
  }
}
