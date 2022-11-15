import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskbuddy/add_group_page.dart';
import 'package:taskbuddy/themes.dart';
import 'data_structures.dart';
import 'login_page.dart';
import 'overview.dart';
import 'tasks.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.user}) : super(key: key);
  static String routeName = 'mainPage';
  final User user;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  Group? selectedGroup;
  List<Group>? groups;
  List<Task>? tasks;
  final firestoreInstance = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getGroups(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              groups = snapshot.data;
              if (groups!.isNotEmpty){
                selectedGroup ??= groups![0];
              }
              return FutureBuilder(
                  future: getTasks(),
                  builder: (BuildContext context, AsyncSnapshot snapshot2) {
                    switch (snapshot2.connectionState) {
                      case ConnectionState.waiting:
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      case ConnectionState.done:
                        if (selectedGroup != null){
                          tasks = snapshot2.data;
                        }
                        return getPage();
                      default:
                        return Container();
                    }
                  });
            default:
              return Container();
          }
        });
  }

  SafeArea getPage() {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TaskBuddy'),
          centerTitle: true,
        ),
        bottomNavigationBar: getNavigationBar(),
        drawer: getDrawer(),
        body: getView(),
      ),
    );
  }

  void refresh(){
    setState(() {
      print('refreshed!');
    });
  }

  BottomNavigationBar getNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: (value) async
      {
        setState(() => _currentIndex = value);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Overview'),
        BottomNavigationBarItem(icon: Icon(Icons.add_task), label: 'Tasks'),
        //BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Settings'),
      ],
    );
  }

  Widget getView() {
    switch (_currentIndex) {
      case 0:
        {
          if (selectedGroup != null){
            return Overview(
              group: selectedGroup!,
              //members: getMembers(selectedGroup),
            );
          }
          else {
            return Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "You have no groups! Click on ",
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
            );
          }
        }
      case 1:
        {
          if (selectedGroup != null){
            return Tasks(tasks: tasks, group: selectedGroup!, notifyParent: refresh,);
          }
          else {
            return Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "You have no groups! Click on ",
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
            );
          }
        }
      // case 2:
      //   {
      //     return Container();
      //   }

      default:
        {
          return Container();
        }
    }
  }

  Drawer getDrawer() {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${widget.user.displayName!} (${widget.user.email})',
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Groups',
          ),
        ),
        ListView.builder(
          itemCount: groups!.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(groups![index].name),
              onTap: () {
                setState(() {
                  selectedGroup = groups![index];
                });
              },
            );
          },
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
        ),
        ListTile(
          leading: const Icon(Icons.add),
          title: const Text('Add New Group'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddGroupPage(email: widget.user.email!, notifyParent: refresh,)));
          },
        ),
        const Divider(
          height: 1,
          thickness: 1,
        ),
        // const ListTile(
        //   leading: Icon(Icons.settings),
        //   title: Text('Settings'),
        // ),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('Logout'),
          onTap: () => logout(),
        ),
        // const ListTile(
        //   leading: Icon(Icons.info_outline),
        //   title: Text('Info'),
        // )
      ],
    ));
  }

  Future<List<Group>> getGroups() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    List<Group> groups = [];

    await firestoreInstance.collection('user').doc(firebaseUser?.uid).get().then((snapshot) async {
      List<dynamic> data = await snapshot.data()?['groups'];
      for (DocumentReference ref in data) {
        await ref.get().then<dynamic>((snapshot) async {
          List<String> members = [];
          List<int> points = [];
          String name;
          name = await (snapshot.data() as Map<String, dynamic>)['groupName'];
          members = await (snapshot.data() as Map<String, dynamic>)['members'].cast<String>();
          points = await (snapshot.data() as Map<String, dynamic>)['points'].cast<int>();
          Group group = Group(name, members, points, ref.id);
          groups.add(group);
        });
      }
    });

    return groups;
  }
  getMembers(Group? selectedGroup) {}

  Future<List<Task>> getTasks() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    List<Task> tasks = [];

    if (selectedGroup == null){
      return tasks;
    }
    await firestoreInstance.collection('group').doc(selectedGroup?.id).collection('Tasks').get().then((value)
    {
      for( dynamic x in value.docs)
      {
        Task task = Task(x.get("title"), x.get("points"), x.get("creator"), x.get("details"), x.get("isDone"), x.get("id"), x.get("whoDidIt"));
        tasks.add(task);
      }
    });
    return tasks;
  }


  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), ModalRoute.withName(LoginPage.routeName));
  }


}
