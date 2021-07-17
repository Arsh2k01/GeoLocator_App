import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:restart_app/Search.dart';
import 'package:restart_app/Maps.dart';

class Group extends StatefulWidget{
  const Group({Key? key, required this.username, required this.uid}) : super(key: key);
  final String username;
  final String uid;

  @override
  _GroupState createState() => _GroupState();
}

class _GroupState extends State<Group>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final User? user;

  checkAuthentification() async {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed("start");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance!.addObserver(this);
    user = _auth.currentUser!;
  }

  navigateToSearch() async {
    try{
      // await Navigator.pushReplacementNamed(context, "Search");
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => Search(username: user!.displayName!)),
      );
    } catch(e){
      print(e.toString());
    }
  }

  goBackToProfile() async {
    try{
      await Navigator.pushReplacementNamed(context, "HomePage");
    } catch(e){
      print(e.toString());
    }
  }

  getUser() async {
    User? firebaseUser = _auth.currentUser;
    await firebaseUser!.reload();
    firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      setState(() {
        user = firebaseUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("${widget.username} received");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .where('users', arrayContains: widget.username)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(!snapshot.hasData){
            return Center(
              child: Text("Look Around! You're all alone."),
            );
          }
          return ListView.builder(
            scrollDirection: Axis.vertical,
            physics: ScrollPhysics(),
            padding: EdgeInsets.only(top: 24),
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var temp = snapshot.data!.docs[index];
              return Center(
                  child: Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        height: MediaQuery.of(context).size.height / 6,
                        // child: Text(temp['groupname']),
                        child: OutlinedButton.icon(
                          style: TextButton.styleFrom(
                            // padding: const EdgeInsets.all(16.0),
                            primary: Colors.black,
                            textStyle: const TextStyle(fontSize: 20),
                            backgroundColor: Colors.red[200],
                          ),
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Maps(id: temp.id, name: widget.username, uid: widget.uid)));
                          },
                          label: Text(temp['groupname']),
                          icon: Icon(Icons.group),
                        ),
                  ),
              );
            },
          );
        }
      ),
      floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: navigateToSearch,
              child: const Icon(Icons.add),
              backgroundColor: Colors.red[700],
            ),
          ]
      ),
    );
  }

}
