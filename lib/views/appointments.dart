import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zen2app/helpers/helper.dart';
import 'package:zen2app/themes/color.dart';
import 'package:zen2app/views/add_appointment.dart';

class Appointments extends StatefulWidget {
  const Appointments({Key? key}) : super(key: key);

  @override
  State<Appointments> createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  CalendarFormat format = CalendarFormat.month;
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
        child: TableCalendar(
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
            selectedTextStyle: const TextStyle(color: MyTheme.lightGray),
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddAppointment()));
        },
        backgroundColor: MyTheme.yellow,
        child: const Icon(Icons.schedule_send),
      ),
    );
  }
}
