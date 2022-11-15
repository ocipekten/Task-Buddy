import 'package:flutter/material.dart';
import 'data_structures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Overview extends StatefulWidget {
  //const Overview({Key? key, required this.group, required this.members}) : super(key: key);
  const Overview({Key? key, required this.group}) : super(key: key);
  final Group group;
  //final List<Person> members;
  @override
  _OverviewState createState() => _OverviewState();

}

class _OverviewState extends State<Overview> {
  final TextEditingController _controller = TextEditingController();
  final firestoreInstance = FirebaseFirestore.instance;
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  String _infoText = "";

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Padding(padding: EdgeInsets.all(10)),
      Text(widget.group.name),
      Expanded(
        child: getMemberList(widget.group) //getPersonList(widget.group.name),
      ),
      ElevatedButton(
          onPressed: () => invitePerson(), child: const Text('Invite Person')),
    ]);
  }
  ListView getMemberList(Group group)
  {
    List<Person> members = [];
    for(int i = 0; i < group.members.length; i++)
    {
      members.add(Person(group.members[i], group.points[i]));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children:[
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(_infoText, style: const TextStyle(color: Colors.red))],),
        for (Person member in members)
          ListTile(
            title: Text(member.name),
            trailing: Text(member.points.toString()),
          ),

      ]
    );
  }
  ListView getPersonList(List<Person> people) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (Person person in people)
          ListTile(
            title: Text(person.name),
            trailing: Text(person.points.toString()),
          ),
      ],
    );
  }

  void invitePerson() {
    showDialog<void>(context: context, builder: (context) => inviteDialog());
  }

  AlertDialog inviteDialog() {
    return AlertDialog(
      title: const Text('Add New Person'),
      contentPadding: const EdgeInsets.all(15),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'email',
            border: OutlineInputBorder(),
          ),
        ),
        const Padding(padding: EdgeInsets.all(5)),
      ]),
      actions: [
        OutlinedButton(
          onPressed: () {
            setState(() {
              _infoText = "";
            });

            addPersonToGroup(_controller.text);
            Navigator.pop(context);

          },
          child: const Text('Add User')
        ),
        OutlinedButton(
          onPressed: () {
            setState(() {
              _infoText = "";
            });
            Navigator.pop(context);
            },
          child: const Text('Exit'),

        ),
      ],
    );
  }

  void addPersonToGroup(String name) async {
    //widget.group.members.add(Person(name, 0));
    DocumentSnapshot? groups;
    String _infotext = "";
    var xd;
    await firestoreInstance.collection('user').where('email', isEqualTo: name).get().then((value) async
    {
      xd = value;
      groups = await firestoreInstance.collection('group').doc(widget.group.id).get();
      if (value.docs.isNotEmpty){
        await firestoreInstance.collection('user').doc(value.docs.first.id).update({'groups': FieldValue.arrayUnion([groups?.reference])});
      }
    });
    if(xd.docs.isNotEmpty)
    {
      if(widget.group.members.contains(name))
      {
        _infotext = "User already exists in this group";
      }else{
        widget.group.members.add(name);
        widget.group.points.add(0);
        await firestoreInstance.collection('group').doc(widget.group.id).update(
            {
              'members' : widget.group.members,
              'points' : widget.group.points
            }
        );
        _infotext = "User has been added successfully!";
      }

    }else{
      _infotext = "User does not exist";
    }
    setState(() {
      _infoText = _infotext;
    });
  }
}
