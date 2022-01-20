class Timeslot {
  int id;
  String day;
  String startTime;
  String endTime;

  Timeslot({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory Timeslot.fromJson(Map<String, dynamic> json) {
    return Timeslot(
      id: json['id'],
      day: json['day'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}
