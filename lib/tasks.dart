import 'package:flutter/material.dart';
import 'package:taskbuddy/themes.dart';
import 'task_card.dart';
import 'data_structures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Tasks extends StatefulWidget {
  const Tasks({Key? key, required this.tasks, required this.group, required this.notifyParent}) : super(key: key);
  final Group group;
  final List<Task>? tasks;
  final Function() notifyParent;
  @override
  _TasksState createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  final firestoreInstance = FirebaseFirestore.instance;
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (widget.tasks!.isNotEmpty) {
      return Column(children: [
        Expanded(
          child: getTaskList(widget.tasks),
        ),
        getAddTaskButton(),
      ]);
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "You have no tasks! Click on ",
                  style: getTextStyle(),
                ),
                WidgetSpan(
                  child: const Icon(Icons.menu, size: 20),
                  style: getTextStyle(),
                ),
                TextSpan(
                  text: " to add a group.",
                  style: getTextStyle(),
                ),
              ],
            ),
          ),
          getAddTaskButton(),
        ],
      );
    }

    ;
  }

  void refresh(){
    //widget.notifyParent();
    setState(() {

    });
  }

  ListView getTaskList(List<Task>? tasks) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (Task task in tasks ?? []) TaskCard(task: task, group: widget.group, notifyParent: refresh,),
      ],
    );
  }

  ElevatedButton getAddTaskButton() {
    return ElevatedButton(onPressed: () => {addTask()}, child: Text('Add New Task'));
  }

  void addTask() {
    showDialog<void>(context: context, builder: (context) => addTaskDialog());
  }

  void addTaskPls(String title, String details, int points) {}

  AlertDialog addTaskDialog() {
    TextEditingController _titleTextController = TextEditingController();
    TextEditingController _detailsTextController = TextEditingController();
    TextEditingController _pointsTextController = TextEditingController();

    DateTime? date = DateTime.now();
    return AlertDialog(
      title: const Text('Add New Task'),
      contentPadding: const EdgeInsets.all(15),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(
          controller: _titleTextController,
          decoration: const InputDecoration(
            labelText: 'title',
            border: OutlineInputBorder(),
          ),
        ),
        const Padding(padding: EdgeInsets.all(5)),
        TextFormField(
          controller: _detailsTextController,
          decoration: const InputDecoration(
            labelText: 'details',
            border: OutlineInputBorder(),
          ),
        ),
        const Padding(padding: EdgeInsets.all(5)),
        TextFormField(
          keyboardType: TextInputType.number,
          controller: _pointsTextController,
          decoration: const InputDecoration(
            labelText: 'points',
            border: OutlineInputBorder(),
          ),
        ),
        // Text(date.toString()),
        // OutlinedButton(
        //     onPressed: () async =>
        //     {
        //       date = await showDatePicker(
        //       context: context,
        //       initialDate: DateTime(2020, 11, 17),
        //       firstDate: DateTime(2017, 1),
        //       lastDate: DateTime(2022, 7),
        //       helpText: 'Select a date',
        //       ),
        //       setState(() {
        //
        //       }),
        //     },
        //     child: const Text('Add Date')
        // ),
      ]),
      actions: [
        OutlinedButton(
            onPressed: () async {
              CollectionReference groups = firestoreInstance.collection('group').doc(widget.group.id).collection('Tasks');
              await groups.add({
                'title': _titleTextController.text,
                'details': _detailsTextController.text,
                'points': int.parse(_pointsTextController.text),
                'creator': firebaseUser?.displayName.toString(),
                'isDone': false,
                'whoDidIt': "",
              }).then((value) => value.update({'id': value.id.toString()}));
              widget.notifyParent();
              Navigator.pop(context);
            },
            child: const Text('Add')),
        OutlinedButton(onPressed: () => {Navigator.pop(context)}, child: const Text('Exit')),
      ],
    );
  }
}
