import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ysrcp/screens/full_screen.dart';

class ProfileScreen extends StatefulWidget {
  final uid;

  const ProfileScreen({Key key, this.uid}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  StreamController _settingsController = StreamController.broadcast();
  Firestore _firestore = Firestore.instance;
  Stream _settingsStream;

  initUserData() {
    _settingsController.add('waiting');

    _firestore.collection('Users').document(widget.uid).get().then((value) {
      _settingsController.add(value);
    });
  }

  @override
  void initState() {
    _settingsStream = _settingsController.stream;
    initUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: Text(
            'Profile Screen',
            style: TextStyle(fontSize: 25),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30))),
          child: StreamBuilder(
            stream: _settingsStream,
            builder: (context, snapshot) {
              if (snapshot.data == 'waiting' || snapshot.data == null) {
                return Center(child: CircularProgressIndicator());
              } else {
                return SingleChildScrollView(
                  child: Column(children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 18, left: 10),
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () async {
                              if (snapshot.data['imageUrl'] != 'null') {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (_) {
                                  return FullScreenImageView(
                                    url: snapshot.data['imageUrl'],
                                  );
                                }));
                              }
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  (snapshot.data['imageUrl'] == 'null')
                                      ? AssetImage('assets/circular_avatar.png')
                                      : CachedNetworkImageProvider(
                                          snapshot.data['imageUrl']),
                              minRadius: 50,
                              maxRadius: 50,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    getApproprateTile(snapshot.data.data['first_name']),
                    getApproprateTile(snapshot.data.data['last_name']),
                    getApproprateTile(snapshot.data.data['dob']),
                    getApproprateTile(snapshot.data.data['phone']),
                    getApproprateTile(snapshot.data.data['area']),
                    getApproprateTile(snapshot.data.data['email']),
                  ]),
                );
              }
            },
          ),
        ));
  }

  getApproprateTile(String title) {
    return Container(
        margin: EdgeInsets.all(9),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(30)),
        child: ListTile(
          title: Text(
            title,
          ),
        ));
  }
}
