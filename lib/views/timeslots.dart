import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zen2app/models/expansion_item.dart';
import 'package:zen2app/models/timeslot.dart';
import 'package:zen2app/themes/color.dart';
import 'package:http/http.dart' as http;

import 'add_timeslot.dart';

final weekdays = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday'
];
List<ExpansionItem> generateItems() {
  return List<ExpansionItem>.generate(weekdays.length, (int index) {
    return ExpansionItem(
      title: weekdays[index],
      icon: const Icon(Icons.event_note),
    );
  });
}

class Timeslots extends StatefulWidget {
  const Timeslots({Key? key}) : super(key: key);

  @override
  _TimeslotsState createState() => _TimeslotsState();
}

class _TimeslotsState extends State<Timeslots> {
  final List<ExpansionItem> _data = generateItems();
  late Future<List<Timeslot>> _timeslotsMonday;
  late Future<List<Timeslot>> _timeslotsTuesday;
  late Future<List<Timeslot>> _timeslotsWednesday;
  late Future<List<Timeslot>> _timeslotsThursday;
  late Future<List<Timeslot>> _timeslotsFriday;
  late Future<List<Timeslot>> _timeslotsSaturday;
  late Future<List<Timeslot>> _timeslotsSunday;

  final String apiUrl = dotenv.get('API_URL', fallback: 'NOT FOUND');
  final storage = const FlutterSecureStorage();

  final deletedSuccessfullySnackBar =
      const SnackBar(content: Text('Timeslot successfully deleted'));
  final somethingWentWrongSnackBar =
      const SnackBar(content: Text('Something went wrong, try again later'));

  Future<List<Timeslot>> getTimeslotsByDay(String day) async {
    String? accessToken = await storage.read(key: 'accessToken');
    List<Timeslot> tempTimeslots = [];
    if (accessToken != null) {
      final response =
          await http.get(Uri.parse(apiUrl + '/timeslots'), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + accessToken
      });

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        for (var i = 0; i < body.length; i++) {
          // debugPrint(body[i].toString());
          if (body[i]['day'] == day) {
            tempTimeslots.add(Timeslot.fromJson(body[i]));
          }
        }
      } else {
        debugPrint(response.body);
      }
    }
    return tempTimeslots;
  }

  Widget getRightFutureBuild(Future<List<Timeslot>> ftimeslots) {
    return FutureBuilder(
        future: ftimeslots,
        builder: (context, AsyncSnapshot<List<Timeslot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final timeslots = snapshot.data;
            debugPrint(timeslots.toString());
            return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: timeslots!.length,
                itemBuilder: (context, index) {
                  Timeslot currentTimeslot = timeslots[index];
                  return ListTile(
                      title: Text(currentTimeslot.startTime +
                          ' - ' +
                          currentTimeslot.endTime),
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
                                      child: Column(children: <Widget>[
                                        ListTile(
                                            leading: const Icon(Icons.delete),
                                            title:
                                                const Text('Delete timeslot'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              showDialog<String>(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                          title: const Text(
                                                              'Warning!'),
                                                          content: const Text(
                                                              'Are you sure you want to delete this timeslot?'),
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
                                                                deleteTimeslot(
                                                                    currentTimeslot);
                                                                Navigator.pop(
                                                                    context,
                                                                    'OK');
                                                              },
                                                              child: const Text(
                                                                  'OK'),
                                                            ),
                                                          ]));
                                            }),
                                      ]),
                                      decoration: const BoxDecoration(
                                          color: MyTheme.lightGray,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10))),
                                    ));
                              });
                        },
                      ));
                });
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  Widget renderBodyPerDay(String day) {
    switch (day) {
      case 'monday':
        return getRightFutureBuild(_timeslotsMonday);
        break;
      case 'tuesday':
        return getRightFutureBuild(_timeslotsTuesday);
        break;
      case 'wednesday':
        return getRightFutureBuild(_timeslotsWednesday);
        break;
      case 'thursday':
        return getRightFutureBuild(_timeslotsThursday);
        break;
      case 'friday':
        return getRightFutureBuild(_timeslotsFriday);
        break;
      case 'saturday':
        return getRightFutureBuild(_timeslotsSaturday);
        break;
      case 'sunday':
        return getRightFutureBuild(_timeslotsSunday);
        break;
      default:
        return const Center(
            child: Text('Something went wrong, try again later'));
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _timeslotsMonday = getTimeslotsByDay('monday');
    _timeslotsTuesday = getTimeslotsByDay('tuesday');
    _timeslotsWednesday = getTimeslotsByDay('wednesday');
    _timeslotsThursday = getTimeslotsByDay('thursday');
    _timeslotsFriday = getTimeslotsByDay('friday');
    _timeslotsSaturday = getTimeslotsByDay('saturday');
    _timeslotsSunday = getTimeslotsByDay('sunday');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Container(
        child: _buildPanel(),
      )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddTimeslot()));
        },
        backgroundColor: MyTheme.yellow,
        label: const Text('timeslot'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = !isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((ExpansionItem item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(item.title),
            );
          },
          body: renderBodyPerDay(item.title),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }

  void deleteTimeslot(Timeslot currentTimeslot) async {
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null) {
      final response = await http.delete(
          Uri.parse(apiUrl + '/timeslots/' + currentTimeslot.id.toString()),
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
