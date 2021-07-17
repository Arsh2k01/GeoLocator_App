import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:restart_app/Groups.dart';
import 'package:rxdart/rxdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restart_app/Firebase.dart';


class Maps extends StatefulWidget {
  final String id;
  final String name;
  final String uid;
  const Maps({Key? key, required this.id, required this.name, required this.uid}) : super(key: key);


  @override
  _MapsState createState() => _MapsState();
}


class _MapsState extends State<Maps> {
  // late LocationData _currentPosition;
  // late String _address,_dateTime;
  late GoogleMapController _controller;
  late Marker marker;
  Location location = Location();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference groupReference =
  FirebaseFirestore.instance.collection('groups');


  BehaviorSubject<double> radius = BehaviorSubject();
  late Stream<List<DocumentSnapshot>> stream;
  double _value = 0.0;
  String _label = 'Adjust Radius';
  late Set<Marker> _markers = {};
  bool isLoading = true;

  late double _latitude;
  late double _longitude;
  bool done = false;
  late String _groupname;

  // onCreateMap(GoogleMapController mapController) {
  //   location.onLocationChanged.listen((LocationData currentLocation) async {
  //     double prevZoom = await mapController.getZoomLevel();
  //     mapController.animateCamera(
  //       CameraUpdate.newCameraPosition(CameraPosition(
  //         target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
  //         zoom: prevZoom,
  //       )),
  //     );
  //     GeoFirePoint myLocation = Geoflutterfire().point(
  //         latitude: currentLocation.latitude!,
  //         longitude: currentLocation.longitude!);
  //     addLocation(myLocation, widget.name, widget.uid);
  //   });
  //
  //   stream.listen((List<DocumentSnapshot> documentList) {
  //     updateMarkers(documentList);
  //   });
  // }

  double? lod;
  void _onMapCreated(GoogleMapController _ctrlr) {
    _controller = _ctrlr;


    location.onLocationChanged.listen((l) async {
      lod = l.latitude;
      GeoFirePoint myloc = Geoflutterfire()
          .point(latitude: l.latitude!, longitude: l.longitude!);
      addLocation(myloc, widget.name, widget.uid);
      // addIntoGroups(myloc, widget.name);
      print("$lod location check");
    });

    stream.listen((List<DocumentSnapshot> documentList) {
      updateMarkers(documentList);
    });
  }
  addIntoGroups(GeoFirePoint myloc, String name) {
    groupReference
        .doc(widget.id)
        .collection('locations')
        .doc(widget.uid)
        .set({'name': name, 'position': myloc.data});
  }


  // addLoc(myLocation) {
  //   // groupReference
  //   //     .doc(widget.id)
  //   //     .collection('location')
  //   //     .where('displayName', isEqualTo: widget.name);
  //
  //   // CollectionReference loc = FirebaseFirestore.instance.collection('location');
  //   // loc.add({'name': widget.name, 'position': myLocation.data});
  //   addLocation(myLocation, widget.name);
  // }

  changedRadius(value) {
    setState(() {
      _value = value;
      _label = '${_value.toInt().toString()} kms';
      _markers.clear();
    });
    radius.add(value);
  }

  updateMarkers(List<DocumentSnapshot> documentList) {
    setState(() {
      _markers.clear();
    });
    documentList.forEach((DocumentSnapshot document) {
      // final GeoFirePoint gp = document['position'];
      final GeoPoint point = document['position']['geopoint'];
      _addMarker(point.latitude, point.longitude, document['name']);
      // addIntoGroups(gp, document['name']);
    });
  }

  // addMarker(double latitude, double longitude, String name) {
  //   _markers.add(Marker(
  //     markerId: MarkerId(name),
  //     position: LatLng(latitude, longitude),
  //     draggable: false,
  //     infoWindow: InfoWindow(
  //       title: name,
  //     ),
  //   ));
  // }
  void _addMarker(double lat, double lng, String name) {
    var _marker = Marker(
        markerId: MarkerId(UniqueKey().toString()),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(title: name, snippet: '${lat},${lng}'));
    setState(() {
      _markers.add(_marker);
    });
  }

  initStream() {
    GeoFirePoint center =
    Geoflutterfire().point(latitude: _latitude, longitude: _longitude);
    stream = radius.switchMap((rad) {
      return Geoflutterfire()
          .collection(
          collectionRef:
          FirebaseFirestore.instance.collection('location'))
          .within(
        center: center,
        radius: rad,
        field: 'position',
        strictMode: true,
      );
    }
    );
  }

  getInfo() async {
    try{
      DocumentSnapshot ds = await groupReference.doc(widget.id).get();
      _groupname = ds['groupname'];

      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      LocationData _locationData;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      _locationData = await location.getLocation();
      setState(() {
        _latitude = _locationData.latitude!;
        _longitude = _locationData.longitude!;
      });

      try{
        location.enableBackgroundMode(enable: true);
      }catch(e){
        print(e.toString());
      }

      // 10000ms and 100m
      location.changeSettings(interval: 10000, distanceFilter: 100);

      initStream();
      setState(() {
        isLoading = false;
      });
    }catch(e){
      print(e.toString());
    }
  }

  navigatetoGroups() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Group(username: widget.name, uid: widget.uid)));
  }

  @override
  void initState() {
    super.initState();
    this.getInfo();
  }

  @override
  Widget build(BuildContext context) {
    print("$lod location check");
    return WillPopScope(
      onWillPop: () async {
        return navigatetoGroups();
      },
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : Scaffold(
          backgroundColor: Colors.blueGrey[200],
          appBar: AppBar(
            backgroundColor: Colors.red,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
              ),
              onPressed: navigatetoGroups,
            ),
            title: TextButton(
              onPressed: (){},
              child: Text(
                _groupname,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          body: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    )
                ),
                height: 550,
                width: double.infinity,
                child: GoogleMap(
                  onMapCreated: (_controller) {
                    // onCreateMap(controller);
                    _onMapCreated(_controller);
                  },
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_latitude, _longitude),
                    zoom: 12,
                  ),
                  markers: _markers,
                  // mapType: MapType.satellite,
                ),
              ),
              SizedBox(height:10),
              Container(
                width: 200,
                child: Slider(
                  min: 0,
                  max: 1000,
                  divisions: 200,
                  value: _value,
                  label: _label,
                  activeColor: Colors.red[400],
                  inactiveColor: Colors.black.withOpacity(0.2),
                  onChanged: (double value) {
                    changedRadius(value);
                  },
                ),
              ),
              Text('Radius',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              Text('$_value Kms',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          )
      ),
    );
  }



}