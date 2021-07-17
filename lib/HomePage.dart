import 'package:geolocator/geolocator.dart';
import 'package:restart_app/Firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restart_app/Groups.dart';

class HomePage extends StatefulWidget {
  // const HomePage({Key? key, required this.username}) : super(key: key);
  // final String username;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final userCollection = FirebaseFirestore.instance.collection("data");
  String? name, email, uid;
  User? user;
  bool isloggedin = false;

  checkAuthentification() async {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed("start");
      }
    });
  }

  getUser() async {
    User? firebaseUser = _auth.currentUser;
    await firebaseUser!.reload();
    firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      setState(() {
        user = firebaseUser;
        // this.user = firebaseUser;
        this.isloggedin = true;
      });
    }
  }

  signOut() async {
    _auth.signOut();

    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

  navigateToGroups() async {
    try{
      // await Navigator.pushReplacementNamed(context, "Groups");
      // print("${widget.username} received");
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => Group(username: user!.displayName!, uid: user!.uid)),
      );
    } catch(e){
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentification();
    this.getUser();
    WidgetsBinding.instance!.addObserver(this);
    user = _auth.currentUser!;
  }

// Future<void> userdata() async{
//
//     try{
//       final disp = user!.uid;
//       DocumentSnapshot ds = await userCollection.doc(disp).get();
//       name = ds.get('displayName');
//       // email=ds.get("email");
//       name = username;
//       print("$name");
//
//       setState(() {
//         name=ds.get('displayName');
//         print("$name");
//       });
//     } catch(e){
//       print(e.toString());
//     }
// }
  var locationMessage = "";

  void getCurrentLocation() async {
    var position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    var lastPosition = await Geolocator().getLastKnownPosition();
    print(lastPosition);
    var lat = position.latitude;
    var long = position.longitude;
    print("$lat , $long");

    setState(() {
      locationMessage = "Latitude : $lat, Longitude : $long";
    });
    // addLocation(lat, long);
  }
  @override
  Widget build(BuildContext context) {
    // print("${user!.uid} gotcha");
    return Scaffold(
        body: Container(
          child: !isloggedin
              ? CircularProgressIndicator()
              : Column(
            children: <Widget>[
              SizedBox(height: 40.0),
              Container(
                height: 300,
                child: Image(
                  image: AssetImage("images/welcome.png"),
                  fit: BoxFit.contain,
                ),
              ),
              // FutureBuilder(
              //   future: userdata(),
              //   builder: (context, snapshot){
              //     if(snapshot.connectionState!=ConnectionState.done)
              //       return Text("Loading");
              //     return Text( "${user!.displayName}" ,
              //     style: TextStyle(
              //       color: Colors.black,
              //       fontSize: 21,
              //     ),);
              //   },
              // ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                child: Text(
                  "Hello ${user!.displayName} you are Logged in as ${user!.email}",
                  style:
                  TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height:15.0,
              ),
              Text("Position : $locationMessage"),
              FlatButton(
                  onPressed: () {
                    getCurrentLocation();
                  },
                  color: Colors.blue,
                  child: Text("Get Current Location",
                  style: TextStyle(
                    color: Colors.white,
                  )),
              ),
              SizedBox(
                height:15.0,
              ),
              FlatButton(
                onPressed: navigateToGroups,
                  child: Text(
                    'My Groups',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  color: Colors.red,
              ),
              SizedBox(
                height:150.0,
              ),
              RaisedButton(
                padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                onPressed: signOut,
                child: Text('Signout',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold)),
                color: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              )
            ],
          ),
        ));
  }
}