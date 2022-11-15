import 'package:flutter/material.dart';
import 'data_structures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({Key? key, required this.task, required this.group, required this.notifyParent}) : super(key: key);
  final Task task;
  final Group group;
  final Function() notifyParent;
  @override
  _TaskCardState createState() => _TaskCardState();
}


class _TaskCardState extends State<TaskCard> {
  bool isExpanded = false;
  final firestoreInstance = FirebaseFirestore.instance;
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return getTaskCard(widget.task);
  }

  Future<List<dynamic>> getPoints() async{
    List<dynamic> points = [];
    await firestoreInstance.collection('group').doc(widget.group.id).get().then((value) async
    {
      points = await value.data()?['points'];
      print(points);
    });
    return points;
  }

  ExpandableCardContainer getTaskCard(Task task) {
    Card collapsedCard = Card(
      child: InkWell(
        splashColor: Colors.amber,
        child: Column(
          children: [
            ListTile(
              leading: Checkbox(
                onChanged: (value) async
                {
                  setState(() {

                  });
                  task.isDone = value!;
                  List<dynamic> points = await getPoints();
                  firestoreInstance.collection('group').doc(widget.group.id).collection('Tasks').doc(widget.task.id).update(
                      {
                        'isDone' : value, 'whoDidIt' : firebaseUser?.email.toString()
                      });
                  if(task.isDone){
                    points[widget.group.members.indexOf(task.whoDidIt)] += task.points;

                  }else{
                    points[widget.group.members.indexOf(task.whoDidIt)] -= task.points;
                  }
                  firestoreInstance.collection('group').doc(widget.group.id).update(
                    {
                    "points" : points
                    });
                  setState(() {

                  });


                  },
                value: task.isDone,
              ),
              title: Text(task.title),
              trailing: Text(task.points.toString()),
              subtitle: task.isDone ? Text("Added by: ${task.creator}  Completed by: ${task.whoDidIt}") : Text("Added by: ${task.creator}"),
            ),
          ],
        ),
        onTap: () => {
          setState(() => { isExpanded = !isExpanded })
        },
      ),
    );

    Card expandedCard = Card(
      child: InkWell(
        splashColor: Colors.amber,
        child: Column(
          children: [
            ListTile(
              leading: Checkbox(
                onChanged: (value) =>
                {task.isDone = value!, setState(() => {})},
                value: task.isDone,
              ),
              title: Text(task.title),
              trailing: Text(task.points.toString()),
              subtitle: task.isDone ? Text("Added by: ${task.creator}  Completed by: ${task.whoDidIt}") : Text("Added by: ${task.creator}"),
            ),
            const Padding(
              padding: EdgeInsets.all(15),
            ),
            // Text(task.dateTime.toString()),
            const Padding(
              padding: EdgeInsets.all(15),
            ),
            Text(task.details),
            const Padding(
              padding: EdgeInsets.all(15),
            ),
          ],
        ),
        onTap: () => {
          setState(() => { isExpanded = !isExpanded })
        },
      ),
    );

    return ExpandableCardContainer(
        isExpanded: isExpanded,
        collapsedChild: collapsedCard,
        expandedChild: expandedCard);
  }
}


class ExpandableCardContainer extends StatefulWidget {
  const ExpandableCardContainer(
      {Key? key,
        required this.isExpanded,
        required this.collapsedChild,
        required this.expandedChild})
      : super(key: key);

  final bool isExpanded;
  final Widget collapsedChild;
  final Widget expandedChild;

  @override
  _ExpandableCardContainerState createState() =>
      _ExpandableCardContainerState();
}

class _ExpandableCardContainerState extends State<ExpandableCardContainer> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      child: widget.isExpanded ? widget.expandedChild : widget.collapsedChild,

    );
  }
}