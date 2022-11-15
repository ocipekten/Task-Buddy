import 'package:cloud_firestore/cloud_firestore.dart';
class Group {
  final String name;
  List<String> members;
  final String id;
  List<int> points;
  Group(this.name, this.members, this.points, this.id);
}

class Person {
  final String name;
  final int points;

  Person(this.name, this.points);
}

class Task {
  final String title;
  final int points;
  //final DateTime dateTime;
  final String creator;
  String details;
  bool isDone;
  String id;
  String whoDidIt;

  Task(this.title, this.points, this.creator, this.details, this.isDone, this.id, this.whoDidIt);
}

