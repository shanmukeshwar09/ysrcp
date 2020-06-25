import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ysrcp/screens/full_screen.dart';

class Settings extends StatefulWidget {
  final String uid;

  const Settings({Key key, this.uid}) : super(key: key);
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  File _file;
  StorageReference _storage =
      FirebaseStorage.instance.ref().child('profile_pictures');
  FirebaseUser _firebaseUser;
  FirebaseAuth _auth = FirebaseAuth.instance;
  StreamController _settingsController = StreamController.broadcast();
  Firestore _firestore = Firestore.instance;
  Stream _settingsStream;

  initUserData() {
    _settingsController.add('waiting');

    _firestore.collection('Users').document(widget.uid).get().then((value) {
      _settingsController.add(value);
    });
    _auth.currentUser().then((value) => _firebaseUser = value);
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
            'Settings',
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
                        Stack(
                          overflow: Overflow.visible,
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
                                  backgroundImage: (snapshot.data['imageUrl'] ==
                                          'null')
                                      ? AssetImage('assets/circular_avatar.png')
                                      : CachedNetworkImageProvider(
                                          snapshot.data['imageUrl']),
                                  minRadius: 50,
                                  maxRadius: 50,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -10,
                              left: 70,
                              child: IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Colors.blueGrey,
                                  size: 36,
                                ),
                                onPressed: () {
                                  changeProfilePicture();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    GestureDetector(
                        onTap: () {},
                        child: getApproprateTile(
                            snapshot.data.data['first_name'])),
                    GestureDetector(
                        onTap: () {},
                        child:
                            getApproprateTile(snapshot.data.data['last_name'])),
                    GestureDetector(
                        onTap: () {},
                        child: getApproprateTile(snapshot.data.data['dob'])),
                    GestureDetector(
                        onTap: () {},
                        child: getApproprateTile(snapshot.data.data['phone'])),
                    GestureDetector(
                        onTap: () {},
                        child: getApproprateTile(snapshot.data.data['area'])),
                    GestureDetector(
                        onTap: () {},
                        child: getApproprateTile(_firebaseUser.email)),
                    GestureDetector(
                        onTap: () async {
                          await _auth.sendPasswordResetEmail(
                              email: _firebaseUser.email);

                          Scaffold.of(context).showSnackBar(SnackBar(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18),
                            )),
                            backgroundColor: Colors.deepOrangeAccent,
                            content: Text(
                              'A reset link has sent to your email',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ));
                        },
                        child: getApproprateTile('Change Password')),
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
          color: Colors.grey.shade200, borderRadius: BorderRadius.circular(30)),
      child: ListTile(
          title: Text(
            title,
          ),
          trailing: Icon(
            Icons.edit,
            color: Colors.deepOrange,
            size: 18,
          )),
    );
  }

  changeProfilePicture() async {
    _file = await FilePicker.getFile(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );
    if (_file != null) {
      try {
        _storage.child(widget.uid).putFile(_file).onComplete.then((value) {
          value.ref.getDownloadURL().then((value) async {
            await _firestore
                .collection('Users')
                .document(widget.uid)
                .setData({'imageUrl': value}, merge: true);
          });
        });
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }
}
