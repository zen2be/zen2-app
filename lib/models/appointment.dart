import 'package:zen2app/models/treatment.dart';

class Appointment {
  int id;
  DateTime startDate;
  DateTime endDate;
  String title;
  String description;
  bool approved;
  Treatment treatment;
  int patientId;
  int specialistId;
  int scheduledById;

  Appointment(
      {required this.id,
      required this.startDate,
      required this.endDate,
      required this.title,
      required this.description,
      required this.approved,
      required this.treatment,
      required this.patientId,
      required this.scheduledById,
      required this.specialistId});

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
        id: json["id"],
        startDate: DateTime.parse(json["startDate"]),
        endDate: DateTime.parse(json["endDate"]),
        title: json["title"],
        description: json["description"],
        approved: json["approved"],
        treatment: Treatment.fromJsonWithoutspecialist(json["treatment"]),
        patientId: json["patient"]["id"],
        specialistId: json["specialist"]["id"],
        scheduledById: json["scheduledBy"]["id"]);
  }
}
