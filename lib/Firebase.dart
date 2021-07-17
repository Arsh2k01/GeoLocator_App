import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

Future<void> userSetup(String? displayName) async {
  // Map<String, dynamic> demo = {"name": "Arsh", "motto" : "Work"};

  CollectionReference data = FirebaseFirestore.instance.collection('data');
  // data.add(demo);
  FirebaseAuth auth = FirebaseAuth.instance;
  String uid = auth.currentUser!.uid.toString();
  data.add({'displayName': displayName, 'uid': uid});
  return;
}

Future<void> addLocation(GeoFirePoint myLocation, String name, String uid) async {
  try{
    CollectionReference loc = FirebaseFirestore.instance.collection('location');
    loc.doc(uid).set({'name': name, 'position': myLocation.data});
    return;
  }catch(e){
    print(e.toString());
  }
}