import 'dart:convert';

class Treatment {
  int id;
  String name;
  String description;
  int duration;
  int price;
  int specialistId;

  Treatment(
      {required this.id,
      required this.name,
      required this.description,
      required this.duration,
      required this.price,
      required this.specialistId});

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      duration: json['duration'],
      price: json['price'],
      specialistId: json['specialist']['id'],
    );
  }
}
