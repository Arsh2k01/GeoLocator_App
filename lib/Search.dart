// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class Search extends StatefulWidget{
//   @override
//   _SearchState createState() => _SearchState();
// }
//
// class _SearchState extends State<Search> {
//   late String _username,_groupName;
//   List<String> _usernames = <String>[];
//   List<String> _selectedusernames = <String>[];
//   Map<String, bool> _selectedusernamesbool = <String, bool>{};
//
//   // checkAuthentification() async {
//   //   _auth.authStateChanges().listen((user) {
//   //     if (user == null) {
//   //       Navigator.of(context).pushReplacementNamed("start");
//   //     }
//   //   });
//   // }
//
//
//
//   Widget appBarTitle = new Text("AppBar Title");
//   Icon actionIcon = new Icon(Icons.search);
//
//   Future<void> createCollectionGroup() async{
//     _selectedusernames.insert(_selectedusernames.length, _username);
//     Map<String, dynamic> mapGroups = {
//       'groupName' : _groupName,
//       'users' : _selectedusernames
//     };
//     try{
//       await FirebaseFirestore.instance.collection('groups').add(mapGroups);
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Group Created')));
//       setState(() {
//         _selectedusernames.clear();
//         _selectedusernamesbool.clear();
//       });
//     }catch(e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Failed to create group ${e}')));
//     }
//   }
//
//   final scaffoldkey = new GlobalKey<ScaffoldState>();
//   TextEditingController _searchQuery = new TextEditingController();
//   bool _isSearching = false;
//   String searchQuery = "Search Query";
//   bool _isLoading = false;
//
//   @override
//   void initState(){
//     super.initState();
//     _searchQuery = new TextEditingController();
//     final FirebaseAuth _auth = FirebaseAuth.instance;
//     _username = _auth.currentUser!.displayName!;
//   }
//
//   void _startSearch() {
//     try{
//       print("open search box");
//       ModalRoute
//           .of(context)!
//           .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: _stopSearching));
//
//       setState(() {
//         _isSearching = true;
//       });
//     }catch(e){
//       print(e.toString());
//     }
//   }
//
//   void _stopSearching() {
//     _clearSearchQuery();
//
//     setState(() {
//       _isSearching = false;
//     });
//   }
//
//   void _clearSearchQuery() {
//     print("close search box");
//     setState(() {
//       _searchQuery.clear();
//       updateSearchQuery("Search query");
//     });
//   }
//
//   void updateSearchQuery(String newQuery) {
//
//     setState(() {
//       searchQuery = newQuery;
//     });
//     print("search query " + newQuery);
//
//   }
//
//   Widget _buildTitle(BuildContext context) {
//     var horizontalTitleAlignment = CrossAxisAlignment.start;
//     return new InkWell(
//       onTap: () => scaffoldkey.currentState!.openDrawer(),
//       child: new Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 12.0),
//         child: new Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: horizontalTitleAlignment,
//           children: <Widget>[
//             const Text('Search box'),
//           ],
//         ),
//       ),
//     );
//   }
//
//   List<Widget> _buildActions() {
//     if (_isSearching) {
//       return <Widget>[
//         new IconButton(
//           icon: const Icon(Icons.clear),
//           onPressed: () {
//             if (_searchQuery == null || _searchQuery.text.isEmpty) {
//               Navigator.pop(context);
//               return;
//             }
//             _clearSearchQuery();
//           },
//         ),
//       ];
//     }
//
//     return <Widget>[
//       new IconButton(
//         icon: const Icon(Icons.search),
//         onPressed: _startSearch,
//       ),
//     ];
//   }
//
//   Widget _buildSearchField() {
//     return new TextField(
//         controller: _searchQuery,
//         autofocus: true,
//         decoration: const InputDecoration(
//           hintText: 'Search by username',
//           border: InputBorder.none,
//           hintStyle: const TextStyle(color: Colors.white30),
//         ),
//         style: const TextStyle(color: Colors.white, fontSize: 16.0),
//         onChanged: (text){
//           int i=0;
//           _usernames.clear();
//           FirebaseFirestore.instance
//               .collection('data')
//               .where('displayName', isEqualTo: text)
//               .get()
//               .then((snapshot){
//                 setState(() {
//                   snapshot.docs.forEach((element) {
//                     if(element['displayName'] != _username){
//                       if(!_usernames.contains(element['displayName'])){
//                         _usernames.insert(i, element['displayName']);
//                         if(_selectedusernames.contains(element['displayName'])){
//                           _selectedusernamesbool.update(
//                               element['displayName'],(value) => true,
//                               ifAbsent: () => true);
//                         } else{
//                           _selectedusernamesbool.update(
//                               element['displayName'],(value) => false,
//                               ifAbsent: () => false);
//                         }
//                       }i++;
//                     }
//                   });
//                 });
//               });
//         },
//       );
//   }
//
//   Widget _buildChip(String label, Color color){
//     return Chip(
//       labelPadding: EdgeInsets.all(2.0),
//       avatar: CircleAvatar(
//         backgroundColor: Colors.black,
//         child: Text(label[0].toUpperCase()),
//       ),
//       label: Text(
//         label,
//         style: TextStyle(
//           color: Colors.white,
//         ),
//       ),
//       deleteIcon: Icon(
//         Icons.close,
//       ),
//       onDeleted: () {
//         setState(() {
//           _selectedusernames.remove(label);
//         });
//       },
//       backgroundColor: color,
//       elevation: 6.0,
//       shadowColor: Colors.grey[60],
//       padding: EdgeInsets.all(8.0),
//     );
//   }
//
//   goBack() async {
//     try{
//       await Navigator.pushReplacementNamed(context, "Groups");
//     } catch(e){
//       print(e.toString());
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: scaffoldkey,
//       appBar: AppBar(
//         leading: _isSearching ? const BackButton() : null,
//         title: _isSearching ? _buildSearchField() : _buildTitle(context),
//         actions: _buildActions(),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 1.0, horizontal: 4.0
//                   ),
//                   child: Align(
//                     alignment: Alignment.topLeft,
//                     child: Wrap(
//                       spacing: 6.0,
//                       runSpacing: 6.0,
//                       children: _selectedusernames
//                           .map((item) => _buildChip(item, Color(0xFFff6666)))
//                           .toList()
//                           .cast<Widget>(),
//                     ),
//                   )
//                 ),
//                 Divider(thickness: 1.0),
//                 ListView.builder(
//                     scrollDirection: Axis.vertical,
//                     shrinkWrap: true,
//                     physics: ScrollPhysics(),
//                     padding: EdgeInsets.only(top: 24),
//                     itemCount: 10,
//                     itemBuilder: (context, i){
//                         return _selectedusernamesbool[i] == true
//                             ? ListTile(
//                                 title: Text(_selectedusernames[i].toString()),
//                             )
//                             : Container(
//                               height: 0,
//                               width: 0,
//                         );
//                       }
//
//                   )
//
//               ]
//           ),
//           floatingActionButton: Column(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 FloatingActionButton(
//                   onPressed: goBack,
//                   child: const Icon(Icons.arrow_back),
//                   backgroundColor: Colors.grey[700],
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 FloatingActionButton(
//                   onPressed: createCollectionGroup,
//                   child: const Icon(Icons.done),
//                   backgroundColor: Colors.red[600],
//                 ),
//               ]
//           )
//       );
//   }
//
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class Search extends StatefulWidget {
  const Search({Key? key, required this.username}) : super(key: key);
  final String username;

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static final GlobalKey<ScaffoldState> scaffoldKey =
  new GlobalKey<ScaffoldState>();
  late final String uid;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late final User user;
  TextEditingController _searchQuery = new TextEditingController();
  TextEditingController _groupnamecontroller = new TextEditingController();
  bool _isSearching = false;
  bool _isLoading = false;
  List<String> _usernames = <String>[];
  List<String> _selectedusernames = <String>[];
  Map<String, bool> _selectedusernamesbool = <String, bool>{};
  RandomColor _randomColor = RandomColor();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    user = auth.currentUser!;
    uid = user.uid;
  }

  @override
  void _startSearch() {
    ModalRoute.of(context)!
        .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _usernames.clear();
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    print("close search box");
    setState(() {
      _searchQuery.clear();
    });
  }

  Widget _buildTitle(BuildContext context) {
    var horizontalTitleAlignment = CrossAxisAlignment.start;

    return new InkWell(
      onTap: () => scaffoldKey.currentState!.openDrawer(),
      child: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: horizontalTitleAlignment,
          children: <Widget>[
            const Text('Search username'),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return new TextField(
        controller: _searchQuery,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search by username',
          border: InputBorder.none,
          hintStyle: const TextStyle(color: Colors.white30),
        ),
        style: const TextStyle(color: Colors.white, fontSize: 16.0),
        onChanged: (text) {
          int i = 0;
          _usernames.clear();
          FirebaseFirestore.instance
              .collection('data')
              .where('displayName', isEqualTo: text)
              .get()
              .then((snapshot) {
            setState(() {
              snapshot.docs.forEach((element) {
                if (element['displayName'] != widget.username) {
                  if (!_usernames.contains(element['displayName'])) {
                    _usernames.insert(i, element['displayName']);
                    if (_selectedusernames.contains(element['displayName'])) {
                      _selectedusernamesbool.update(
                          element['displayName'], (value) => true,
                          ifAbsent: () => true);
                    } else {
                      _selectedusernamesbool.update(
                          element['displayName'], (value) => false,
                          ifAbsent: () => false);
                    }
                  }
                  i++;
                }
              });
            });
          });
        });
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        new IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQuery == null || _searchQuery.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }

    return <Widget>[
      new IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

  goBack() async {
    try{
      await Navigator.pushReplacementNamed(context, "Groups");
    } catch(e){
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: _isSearching ? const BackButton() : null,
        title: _isSearching ? _buildSearchField() : _buildTitle(context),
        actions: _buildActions(),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 1.0, horizontal: 4.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: _selectedusernames
                        .map(
                            (item) => _buildChip(item,_randomColor.randomColor(colorHue: ColorHue.blue)))
                        .toList()
                        .cast<Widget>()),
              ),
            ),
            Container(
                child: _selectedusernames.isEmpty
                    ? null
                    : Divider(thickness: 1.0)),
            ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: _usernames.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 1.0, horizontal: 4.0),
                    child: Card(
                        color: _selectedusernamesbool[_usernames[index]]!
                            ? Color(0xff9EA6BA).withOpacity(0.3)
                            : Colors.white,
                        child: ListTile(
                            onTap: () {
                              setState(() {
                                if (!_selectedusernamesbool[
                                _usernames[index]]!) {
                                  _selectedusernames.insert(
                                      _selectedusernames.length,
                                      _usernames[index]);
                                  _selectedusernamesbool.update(
                                      _usernames[index], (value) => true,
                                      ifAbsent: () => true);
                                } else {
                                  _deleteselected(_usernames[index]);
                                }
                              });
                            },
                            leading: CircleAvatar(
                              backgroundColor: Colors.black,
                              child: Text(
                                  _usernames[index][0].toUpperCase()),
                            ),
                            title: Text(_usernames[index]),
                            trailing:
                            _selectedusernamesbool[_usernames[index]]!
                                ? Icon(Icons.check)
                                : null)));
              },
            ),
          ],
        ),
      ),
        floatingActionButton: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      onPressed: creategroup,
                      child: const Icon(Icons.check),
                      backgroundColor: Colors.red[600],
                    ),
                  ]
              )
    //   floatingActionButton: FloatingActionButton(
    //     child: Icon(Icons.check),
    //     onPressed: creategroup,
    //   ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Chip(
      labelPadding: EdgeInsets.all(2.0),
      avatar: CircleAvatar(
        backgroundColor: Colors.black,
        child: Text(label[0].toUpperCase()),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      deleteIcon: Icon(
        Icons.close,
      ),
      onDeleted: () => _deleteselected(label),
      backgroundColor: color,
      elevation: 6.0,
      shadowColor: Colors.grey[60],
      padding: EdgeInsets.all(8.0),
    );
  }

  void _deleteselected(String label) {
    setState(
          () {
        _selectedusernamesbool.update(label, (value) => false,
            ifAbsent: () => false);
        _selectedusernames.removeAt(_selectedusernames.indexOf(label));
      },
    );
  }

  void creategroup() async {
    if (_selectedusernames.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No users selected')));
    } else {
      setState(() {
        _isLoading = true;
      });
      await GroupnameWidget(context);
      if (_groupnamecontroller.text.length != 0) {
        await createcollectiongroup();
      }
      setState(
            () {
          _isLoading = false;
        },
      );
    }
  }

  Future<void> createcollectiongroup() async {
    _selectedusernames.insert(_selectedusernames.length, widget.username);
    Map<String, dynamic> mapgroups = {
      'groupname': _groupnamecontroller.text,
      'owner': widget.username,
      'users': _selectedusernames
    };
    try {
      await FirebaseFirestore.instance.collection('groups').add(mapgroups);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Group created')));
      Navigator.of(context).pop();
      setState(() {
        _selectedusernames.clear();
        _selectedusernamesbool.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to create group ${e}')));
    }
  }

  Future<dynamic> GroupnameWidget(BuildContext context) async {
    // alter the app state to show a dialog
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter group name'),
          content: TextField(
            controller: _groupnamecontroller,
            decoration: InputDecoration(
              hintText: 'Group name',
            ),),
          actions: <Widget>[
            // add button
            ElevatedButton(
              child: Text('CREATE'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // Cancel button
            ElevatedButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
                _groupnamecontroller.clear();
              },
            ),
          ],
        );
      },
    );
  }
}