import 'package:restart_app/Login.dart';
import 'package:restart_app/SignUp.dart';
import 'package:restart_app/Start.dart';
import 'package:flutter/material.dart';
import 'package:restart_app/HomePage.dart';
import 'package:restart_app/Groups.dart';
import 'package:restart_app/Search.dart';
import 'HomePage.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      theme: new ThemeData(scaffoldBackgroundColor: Colors.blueGrey[800]),
      debugShowCheckedModeBanner: false,
      home:

      HomePage(),

      routes: <String,WidgetBuilder>{

        "Login" : (BuildContext context)=>Login(),
        "SignUp":(BuildContext context)=>SignUp(),
        "start":(BuildContext context)=>Start(),
        // "Groups":(BuildContext context)=>Group(),
        // "Search":(BuildContext context)=>Search(),
        // "HomePage":(BuildContext context)=>HomePage(),
      },

    );
  }

}