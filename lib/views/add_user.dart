import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AddUser extends StatefulWidget {
  const AddUser({Key? key}) : super(key: key);

  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController telController = TextEditingController();

  final _addUserForm = GlobalKey<FormState>();

  final String apiUrl = dotenv.get('API_URL', fallback: 'NOT FOUND');
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zen2 - Add user'),
      ),
      body: Form(
          key: _addUserForm,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    controller: firstNameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        hintText: 'First name',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)))),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    controller: lastNameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        hintText: 'Last name',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)))),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        hintText: 'Email',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)))),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    controller: passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                        hintText: 'Password',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)))),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    controller: telController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        hintText: 'Tel',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)))),
              ),
              Padding(
                  padding: const EdgeInsets.only(bottom: 5, top: 30),
                  child: ElevatedButton(
                      child: const Text('Create new patient'),
                      onPressed: () async {
                        if (_addUserForm.currentState!.validate()) {
                          String? accessToken =
                              await storage.read(key: 'accessToken');
                          if (accessToken != null) {
                            final response =
                                await http.post(Uri.parse(apiUrl + '/users'),
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'Accept': 'application/json',
                                      'Authorization': 'Bearer ' + accessToken
                                    },
                                    body: json.encode({
                                      "firstName": firstNameController.text,
                                      "lastName": lastNameController.text,
                                      "email": emailController.text,
                                      "password": passwordController.text,
                                      "tel": telController.text,
                                    }));
                            if (response.statusCode == 201) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('User successfully created')),
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
            ],
          )),
    );
  }
}
