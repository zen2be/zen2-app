import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zen2app/helpers/helper.dart';
import 'package:zen2app/models/appointment.dart';
import 'package:zen2app/models/treatment.dart';
import 'package:zen2app/models/user.dart';
import 'package:zen2app/themes/color.dart';
import 'package:http/http.dart' as http;

class Appointments extends StatefulWidget {
  const Appointments({Key? key}) : super(key: key);

  @override
  State<Appointments> createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final _addAppointmentForm = GlobalKey<FormState>();

  CalendarFormat format = CalendarFormat.month;

  late Future<List<Treatment>> _treatments;
  late Future<List<User>> _patients;
  late Future<List<Appointment>> _appointments;

  int treatmentsDropdownValue = 1;
  int patientDropdownValue = 1;

  final String apiUrl = dotenv.get('API_URL', fallback: 'NOT FOUND');
  final storage = const FlutterSecureStorage();

  final deletedSuccessfullySnackBar =
      const SnackBar(content: Text('Appointment successfully deleted'));
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

  Future<List<Appointment>> getAppointments() async {
    String? accessToken = await storage.read(key: 'accessToken');
    List<Appointment> tempTreatments = [];
    if (accessToken != null) {
      final response =
          await http.get(Uri.parse(apiUrl + '/appointments'), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + accessToken
      });

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        for (var i = 0; i < body.length; i++) {
          // debugPrint(body[i].toString());
          tempTreatments.add(Appointment.fromJson(body[i]));
        }
      } else {
        debugPrint(response.body);
      }
    }
    return tempTreatments;
  }

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
  void initState() {
    super.initState();
    _treatments = getTreatments();
    _patients = getPatients();
    _appointments = getAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zen2 - Appointments'),
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
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Column(
          children: [
            FutureBuilder(
                future: _appointments,
                builder: (context, AsyncSnapshot<List<Appointment>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    final appointments = snapshot.data!;
                    print(appointments);
                    return TableCalendar(
                      // source: https://www.youtube.com/watch?v=HKuzPQUV21Y
                      focusedDay: _focusedDay,
                      firstDay: DateTime(1990),
                      lastDay: DateTime(2050),
                      calendarFormat: format,
                      onFormatChanged: (CalendarFormat _format) {
                        setState(() {
                          format = _format;
                        });
                      },
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      onDaySelected: (DateTime selectDay, DateTime focusDay) {
                        setState(() {
                          _selectedDay = selectDay;
                          _focusedDay = focusDay;
                        });
                        print(_focusedDay);
                      },
                      eventLoader: (date) {
                        List<Appointment> tempApp = [];
                        for (var app in appointments) {
                          if (app.startDate.year == date.year &&
                              app.startDate.month == date.month &&
                              app.startDate.day == date.day) {
                            // same date
                            tempApp.add(app);
                          }
                        }

                        return tempApp;
                      },
                      calendarStyle: CalendarStyle(
                        isTodayHighlighted: true,
                        todayDecoration: BoxDecoration(
                            color: MyTheme.gray,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(5.0)),
                        todayTextStyle: const TextStyle(color: MyTheme.black),
                        selectedDecoration: BoxDecoration(
                            color: MyTheme.blue,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(5.0)),
                        selectedTextStyle:
                            const TextStyle(color: MyTheme.lightGray),
                        defaultDecoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(5.0)),
                        weekendDecoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                      selectedDayPredicate: (DateTime date) {
                        return isSameDay(_selectedDay, date);
                      },
                      headerStyle: const HeaderStyle(
                          titleCentered: true, formatButtonShowsNext: false),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                }),
            FutureBuilder(
                future: _appointments,
                builder: (context, AsyncSnapshot<List<Appointment>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    final appointments = snapshot.data!;

                    List<Appointment> tempApp = [];
                    for (var app in appointments) {
                      if (app.startDate.year == _selectedDay.year &&
                          app.startDate.month == _selectedDay.month &&
                          app.startDate.day == _selectedDay.day) {
                        // same date
                        tempApp.add(app);
                      }
                    }
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: tempApp.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                                title: Text(tempApp[index].title),
                                subtitle: Text(tempApp[index].treatment.name),
                                trailing: IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () => showModalBottomSheet(
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
                                                              'Delete appointment'),
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
                                                                                'Are you sure you want to delete this appointment?'),
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
                                                                              deleteAppointment(tempApp[index]);
                                                                              Navigator.pop(context, 'OK');
                                                                              setState(() {});
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
                                        }))),
                          );
                        });
                  }
                  return const Center(child: CircularProgressIndicator());
                })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) => Container(
                    color: const Color(0xFF737373),
                    height: 600,
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 8.0),
                              child: Text('Add appointment',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: MyTheme.blue,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Row(children: [
                              Flexible(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: TextField(
                                      controller: startTimeController,
                                      readOnly: true,
                                      onTap: _selectStartTime,
                                      decoration: InputDecoration(
                                          label: const Text('Start time'),
                                          hintText: startTime.format(context),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 25, vertical: 15),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)))),
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: TextField(
                                      controller: endTimeController,
                                      readOnly: true,
                                      onTap: _selectEndTime,
                                      decoration: InputDecoration(
                                          label: const Text('End time'),
                                          hintText: endTime.format(context),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 25, vertical: 15),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)))),
                                ),
                              ),
                            ]),
                            Form(
                                key: _addAppointmentForm,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: TextFormField(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter some text';
                                            }
                                            return null;
                                          },
                                          controller: nameController,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                              hintText: 'Name',
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 25,
                                                      vertical: 15),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)))),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: TextFormField(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter some text';
                                            }
                                            return null;
                                          },
                                          controller: descriptionController,
                                          keyboardType: TextInputType.multiline,
                                          maxLines: 5,
                                          decoration: InputDecoration(
                                              hintText: 'Description',
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 25,
                                                      vertical: 15),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)))),
                                    ),
                                  ],
                                )),
                            FutureBuilder(
                                future: _treatments,
                                builder: (context,
                                    AsyncSnapshot<List<Treatment>> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    final treatments = snapshot.data;
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 10.0, 0.0, 10.0),
                                      child: DropdownButton<String>(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          value: treatments![0].name,
                                          icon:
                                              const Icon(Icons.arrow_downward),
                                          elevation: 16,
                                          onChanged: (String? newValue) {
                                            for (var t in treatments) {
                                              if (t.name == newValue) {
                                                setState(() {
                                                  treatmentsDropdownValue =
                                                      t.id;
                                                });
                                              }
                                            }
                                          },
                                          items: treatments
                                              .map<DropdownMenuItem<String>>(
                                                  (Treatment value) {
                                            return DropdownMenuItem<String>(
                                              value: value.name,
                                              child: Text(value.name),
                                            );
                                          }).toList()),
                                    );
                                  }
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }),
                            FutureBuilder(
                                future: _patients,
                                builder: (context,
                                    AsyncSnapshot<List<User>> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    final patients = snapshot.data;
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 10.0, 0.0, 10.0),
                                      child: DropdownButton<String>(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          value: patients![0].firstName,
                                          icon:
                                              const Icon(Icons.arrow_downward),
                                          elevation: 16,
                                          onChanged: (String? newValue) {
                                            for (var t in patients) {
                                              if (t.firstName == newValue) {
                                                setState(() {
                                                  patientDropdownValue = t.id;
                                                });
                                              }
                                            }
                                          },
                                          items: patients
                                              .map<DropdownMenuItem<String>>(
                                                  (User value) {
                                            return DropdownMenuItem<String>(
                                              value: value.firstName,
                                              child: Text(value.firstName),
                                            );
                                          }).toList()),
                                    );
                                  }
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }),
                            Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 5, top: 30),
                                child: ElevatedButton(
                                    child: const Text('Create new treatment'),
                                    onPressed: () async {
                                      if (_addAppointmentForm.currentState!
                                          .validate()) {
                                        String? accessToken = await storage
                                            .read(key: 'accessToken');
                                        if (accessToken != null) {
                                          var profileRes = await http.get(
                                              Uri.parse(
                                                  apiUrl + '/auth/profile'),
                                              headers: {
                                                'Content-Type':
                                                    'application/json',
                                                'Accept': 'application/json',
                                                'Authorization':
                                                    'Bearer ' + accessToken
                                              });
                                          Map<String, dynamic> profile =
                                              jsonDecode(profileRes.body);
                                          debugPrint(profile['id'].toString());
                                          final response = await http.post(
                                              Uri.parse(
                                                  apiUrl + '/appointments'),
                                              headers: {
                                                'Content-Type':
                                                    'application/json',
                                                'Accept': 'application/json',
                                                'Authorization':
                                                    'Bearer ' + accessToken
                                              },
                                              body: json.encode({
                                                "startDate": _focusedDay
                                                    .toString()
                                                    .replaceAll(
                                                        ' 00:00:00.000Z',
                                                        'T' +
                                                            startTime.format(
                                                                context) +
                                                            ':00.000Z'),
                                                "endDate": _focusedDay
                                                    .toString()
                                                    .replaceAll(
                                                        ' 00:00:00.000Z',
                                                        'T' +
                                                            endTime.format(
                                                                context) +
                                                            ':00.000Z'),
                                                "title": nameController.text,
                                                "description":
                                                    descriptionController.text,
                                                "treatment": {
                                                  "id": treatmentsDropdownValue
                                                },
                                                "patient": {
                                                  "id": patientDropdownValue
                                                },
                                                "specialist": {
                                                  "id": profile['id']
                                                },
                                                "scheduledBy": {
                                                  "id": profile['id']
                                                }
                                              }));
                                          if (response.statusCode == 201) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Appointment successfully created')),
                                            );
                                            setState(() {});
                                          } else {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
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
                        ),
                        decoration: const BoxDecoration(
                            color: MyTheme.lightGray,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10)))),
                  )),
          backgroundColor: MyTheme.yellow,
          icon: const Icon(Icons.add),
          label: const Text('appointment')),
    );
  }

  void deleteAppointment(Appointment tempApp) async {
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null) {
      final response = await http.delete(
          Uri.parse(apiUrl + '/appointments/' + tempApp.id.toString()),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ' + accessToken
          });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(deletedSuccessfullySnackBar);
      } else {
        debugPrint(response.body);
        ScaffoldMessenger.of(context).showSnackBar(somethingWentWrongSnackBar);
      }
    }
  }
}
