import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zen2app/helpers/helper.dart';
import 'package:zen2app/models/expansion_item.dart';
import 'package:zen2app/models/timeslot.dart';
import 'package:zen2app/themes/color.dart';
import 'package:http/http.dart' as http;
import 'package:zen2app/utils.dart';
import 'package:zen2app/views/add_timeslot.dart';
import 'package:time_range/time_range.dart';

class Settings extends StatefulWidget {
  static _SettingsState? of(BuildContext context) =>
      context.findAncestorStateOfType<_SettingsState>();
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

Future<List<Timeslot>> timeslots = getTimeslots();

final String apiUrl = dotenv.get('API_URL', fallback: 'NOT FOUND');
const storage = FlutterSecureStorage();
Future<List<Timeslot>> getTimeslots() async {
  String? accessToken = await storage.read(key: 'accessToken');
  List<Timeslot> timeslots = [];
  if (accessToken != null) {
    final response = await http.get(Uri.parse(apiUrl + '/timeslots'), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + accessToken
    });
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<dynamic> body = jsonDecode(response.body);
      for (var i = 0; i < body.length; i++) {
        // debugPrint(body[i].toString());
        timeslots.add(Timeslot.fromJson(body[i]));
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load timeslots');
    }
  }
  return timeslots;
}

// List<DataColumn> getColumns(List<String> columns) {
//   return columns.map((String column) {
//     return DataColumn(
//       label: Text(column),
//     );
//   }).toList();
// }

// List<DataRow> getRows(List<Timeslot> timeslots, context) {
//   return timeslots.map((Timeslot timeslot) {
//     final cells = [timeslot.startTime, timeslot.endTime];
//     return DataRow(
//         cells: Utils.modelBuilder(cells, (index, cell) {
//       return DataCell(Text('$cell'), showEditIcon: true, onTap: () {
//         switch (index) {
//           case 0:
//             editStartTime(timeslot, context);
//             break;
//           case 1:
//             editEndTime(timeslot, context);
//             break;
//           default:
//         }
//       });
//     }));
//   }).toList();
// }

TimeOfDay selectedTime = TimeOfDay.now();
Future editStartTime(Timeslot timeslot, context) async {
  String? accessToken = await storage.read(key: 'accessToken');
  final TimeOfDay? timeOfDay = await showTimePicker(
    context: context,
    initialTime: selectedTime,
    initialEntryMode: TimePickerEntryMode.dial,
  );

  if (accessToken != null && timeOfDay != null) {
    final response = await http.patch(
        Uri.parse(apiUrl + '/timeslots/' + timeslot.id.toString()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ' + accessToken
        },
        body: json.encode({
          "startTime": timeOfDay.format(context),
          "endTime": timeslot.endTime
        }));
    debugPrint(response.body);
  }
}

Future editEndTime(Timeslot timeslot, context) async {
  String? accessToken = await storage.read(key: 'accessToken');
  final TimeOfDay? timeOfDay = await showTimePicker(
    context: context,
    initialTime: selectedTime,
    initialEntryMode: TimePickerEntryMode.dial,
  );

  if (accessToken != null && timeOfDay != null) {
    final response = await http.patch(
        Uri.parse(apiUrl + '/timeslots/' + timeslot.id.toString()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ' + accessToken
        },
        body: json.encode({
          "startTime": timeslot.startTime,
          "endTime": timeOfDay.format(context)
        }));
    debugPrint(response.body);
  }
}

final _columns = ['Start time', 'End time'];

final _defaultTimeRange = TimeRangeResult(
  TimeOfDay.now(),
  TimeOfDay.now(),
);
TimeRangeResult? _timeRange;

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
    _timeRange = _defaultTimeRange;
  }

  List<ExpansionItem> items = <ExpansionItem>[
    ExpansionItem(
        title: "Monday",
        icon: const Icon(Icons.event_note),
        body: FutureBuilder<List<Timeslot>>(
            future: timeslots,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                debugPrint('werkt');
                List<Timeslot> mondays =
                    snapshot.data!.where((x) => x.day == 'monday').toList();
                debugPrint('werkt');
                for (var timeslot in mondays) {
                  return ListTile(
                      title:
                          Text(timeslot.startTime + ' - ' + timeslot.endTime),
                      trailing: IconButton(
                          onPressed: () => null,
                          icon: const Icon(Icons.delete)),
                      onTap: () => TimeRange(
                            fromTitle: const Text(
                              'FROM',
                              style: TextStyle(
                                fontSize: 14,
                                color: MyTheme.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            toTitle: const Text(
                              'TO',
                              style: TextStyle(
                                fontSize: 14,
                                color: MyTheme.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.normal,
                              color: MyTheme.black,
                            ),
                            activeTextStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: MyTheme.yellow,
                            ),
                            borderColor: MyTheme.black,
                            activeBorderColor: MyTheme.black,
                            backgroundColor: Colors.transparent,
                            activeBackgroundColor: MyTheme.black,
                            firstTime: const TimeOfDay(hour: 8, minute: 00),
                            lastTime: const TimeOfDay(hour: 20, minute: 00),
                            initialRange: _timeRange,
                            timeStep: 10,
                            timeBlock: 30,
                            onRangeCompleted: (range) => Settings.of(context)!
                                .setState(() => _timeRange = range),
                          ));
                }
                // return DataTable(
                //   columns: getColumns(_columns),
                //   rows: getRows(
                //       snapshot.data!.where((x) => x.day == 'monday').toList(),
                //       context),
                // );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            })),
    ExpansionItem(
        title: "Tuesday",
        icon: const Icon(Icons.event_note),
        body: FutureBuilder<List<Timeslot>>(
            future: timeslots,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // return DataTable(
                //   columns: getColumns(_columns),
                //   rows: getRows(
                //       snapshot.data!.where((x) => x.day == 'tuesday').toList(),
                //       context),
                // );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            })),
    ExpansionItem(
        title: "Wednesday",
        icon: const Icon(Icons.event_note),
        body: FutureBuilder<List<Timeslot>>(
            future: timeslots,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // return DataTable(
                //   columns: getColumns(_columns),
                //   rows: getRows(
                //       snapshot.data!
                //           .where((x) => x.day == 'wednesday')
                //           .toList(),
                //       context),
                // );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            })),
    ExpansionItem(
        title: "Thursday",
        icon: const Icon(Icons.event_note),
        body: FutureBuilder<List<Timeslot>>(
            future: timeslots,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // return DataTable(
                //   columns: getColumns(_columns),
                //   rows: getRows(
                //       snapshot.data!.where((x) => x.day == 'thursday').toList(),
                //       context),
                // );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            })),
    ExpansionItem(
        title: "Friday",
        icon: const Icon(Icons.event_note),
        body: FutureBuilder<List<Timeslot>>(
            future: timeslots,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // return DataTable(
                //   columns: getColumns(_columns),
                //   rows: getRows(
                //       snapshot.data!.where((x) => x.day == 'friday').toList(),
                //       context),
                // );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            })),
    ExpansionItem(
        title: "Saturday",
        icon: const Icon(Icons.event_note),
        body: FutureBuilder<List<Timeslot>>(
            future: timeslots,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // return DataTable(
                //   columns: getColumns(_columns),
                //   rows: getRows(
                //       snapshot.data!.where((x) => x.day == 'saturday').toList(),
                //       context),
                // );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            })),
    ExpansionItem(
        title: "Sunday",
        icon: const Icon(Icons.event_note),
        body: FutureBuilder<List<Timeslot>>(
            future: timeslots,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // return DataTable(
                //   columns: getColumns(_columns),
                //   rows: getRows(
                //       snapshot.data!.where((x) => x.day == 'sunday').toList(),
                //       context),
                // );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            })),
  ];

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
        body: TabBarView(children: [
          Scaffold(
            body: ListView(children: [
              ExpansionPanelList(
                  expansionCallback: (index, isExpanded) {
                    setState(() {
                      items[index].isExpanded = !items[index].isExpanded;
                    });
                  },
                  children: items.map((ExpansionItem item) {
                    return ExpansionPanel(
                        headerBuilder: (context, isExpanded) {
                          return ListTile(
                              leading: item.icon, title: Text(item.title));
                        },
                        isExpanded: item.isExpanded,
                        body: item.body);
                  }).toList())
            ]),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddTimeslot()));
              },
              backgroundColor: MyTheme.yellow,
              child: const Icon(Icons.add),
            ),
          ),
          const Center(child: Text('test'))
        ]),
      ),
    );
  }
}
