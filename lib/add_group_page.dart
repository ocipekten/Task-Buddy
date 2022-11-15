import 'package:flutter/material.dart';
import 'package:taskbuddy/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'validator.dart';

class AddGroupPage extends StatefulWidget {
  const AddGroupPage({Key? key, required this.email, required this.notifyParent}) : super(key: key);
  final String email;
  final Function() notifyParent;
  @override
  _AddGroupPageState createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  final _groupFormKey = GlobalKey<FormState>();
  
  final firestoreInstance = FirebaseFirestore.instance;

  final _nameTextController = TextEditingController();
  final _focusName = FocusNode();

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add New Group'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _groupFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _nameTextController,
                  focusNode: _focusName,
                  validator: (value) => Validator.validateName(name: _nameTextController.text),
                  decoration: getInputDecoration('Group name'),
                ),
                getCreateGroupButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget getCreateGroupButton() {
    return _isProcessing
        ? const CircularProgressIndicator()
        : ElevatedButton(
            onPressed: () async {
              setState(() {
                _isProcessing = false;
              });

              _focusName.unfocus();

              User? firebaseUser =  FirebaseAuth.instance.currentUser;

              String groupName = _nameTextController.text;
              List<String> members = [widget.email];
              List<dynamic> empty = [0];
              CollectionReference groups = firestoreInstance.collection('group');
              await groups.add(
                  {
                  'groupName' : groupName,
                    'members' : members,
                    'points' : empty,
                }
              ).then((value) async
              {
                //value.update({'groupId' : value.id.toString()});
                await firestoreInstance.collection('user').doc(firebaseUser?.uid).get().then((value2) async {
                  await firestoreInstance.collection('user').doc(firebaseUser?.uid).update({'groups': FieldValue.arrayUnion([value])});
                });
              });

              // CollectionReference groups = firestoreInstance.collection('group');
              // groups.add(
              //     {
              //     'groupName' : groupName,
              //       'members' : members,
              //   }
              // ).then((value) =>
              // {
              //   firestoreInstance.collection('group').doc(value.id).collection('Tasks').add(
              //     {
              //       'title' : "My First Task",
              //       'details' : "You can add your new tasks from here!",
              //       'points' : 10,
              //       'creator': "Task Buddy Team",
              //       'isDone' : false,
              //       'whoDidIt' : "",
              //     }),
              //   firestoreInstance.collection('user').doc(firebaseUser?.uid).get().then((value2) => {
              //     firestoreInstance.collection('user').doc(firebaseUser?.uid).update({'groups': FieldValue.arrayUnion([value])})
              //   })
              // });
              widget.notifyParent();
              Navigator.of(context).pop();
              

              // firestoreInstance.collection('group').doc(firebaseUser?.uid).update({
              //   'groups' : FieldValue.arrayUnion([_nameTextController.text]),
              // }).then((_){
              //   print('success!');
              // });
            },
            child: const Text('Create'));
  }
}
