import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AddTimeslot extends StatefulWidget {
  const AddTimeslot({Key? key}) : super(key: key);

  @override
  State<AddTimeslot> createState() => _AddTimeslotState();
}

class _AddTimeslotState extends State<AddTimeslot> {
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();
  String dropdownValue = 'monday';

  final String apiUrl = dotenv.get('API_URL', fallback: 'NOT FOUND');
  final storage = const FlutterSecureStorage();

  void _selectStartTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: startTime,
    );
    if (newTime != null) {
      setState(() {
        startTimeController.text = newTime.format(context);
        startTime = newTime;
      });
    }
  }

  void _selectEndTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: endTime,
    );
    if (newTime != null) {
      setState(() {
        endTimeController.text = newTime.format(context);
        endTime = newTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Zen2 - Add timeslot'),
        ),
        body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 10.0),
                child: DropdownButton<String>(
                    borderRadius: BorderRadius.circular(10),
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    items: <String>[
                      'monday',
                      'tuesday',
                      'wednesday',
                      'thursday',
                      'friday',
                      'saturday',
                      'sunday'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList()),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                    controller: startTimeController,
                    readOnly: true,
                    onTap: _selectStartTime,
                    decoration: InputDecoration(
                        label: const Text('Start time'),
                        hintText: startTime.format(context),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)))),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                    controller: endTimeController,
                    readOnly: true,
                    onTap: _selectEndTime,
                    decoration: InputDecoration(
                        label: const Text('End time'),
                        hintText: endTime.format(context),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)))),
              ),
              Padding(
                  padding: const EdgeInsets.only(bottom: 5, top: 30),
                  child: ElevatedButton(
                      child: const Text('Create new timeslot'),
                      onPressed: () async {
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
                          final response =
                              await http.post(Uri.parse(apiUrl + '/timeslots'),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'Accept': 'application/json',
                                    'Authorization': 'Bearer ' + accessToken
                                  },
                                  body: json.encode({
                                    "day": dropdownValue,
                                    "startTime": startTime.format(context),
                                    "endTime": endTime.format(context),
                                    "specialist": {"id": profile['id']}
                                  }));
                          if (response.statusCode == 201) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Timeslot successfully created')),
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
                      }))
            ]));
  }
}
