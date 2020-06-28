import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ysrcp/screens/full_screen.dart';
import 'package:ysrcp/service/colors.dart';

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
  Firestore _firestore = Firestore.instance;
  ColorsMap _colorsMap = ColorsMap();

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((value) {
      _firebaseUser = value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: _colorsMap.getBackgroundColor(),
        appBar: AppBar(
          backgroundColor: _colorsMap.getAppbarColor(),
          title: Text(
            'Settings',
            style: TextStyle(
              fontSize: 23,
            ),
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
          child: StreamBuilder<DocumentSnapshot>(
            stream:
                _firestore.collection('Users').document(widget.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
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
                                  MdiIcons.cameraOutline,
                                  color: Colors.deepOrangeAccent,
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
                        onTap: () {
                          showTile(
                              'Change first name', 'first_name', snapshot.data);
                        },
                        child: getApproprateTile(
                            snapshot.data.data['first_name'], 'First name')),
                    GestureDetector(
                        onTap: () {
                          showTile(
                              'Change last name', 'last_name', snapshot.data);
                        },
                        child: getApproprateTile(
                            snapshot.data.data['last_name'], 'Last name')),
                    GestureDetector(
                        onTap: () {
                          showTile('Change Bio', 'bio', snapshot.data);
                        },
                        child: getApproprateTile(
                            snapshot.data.data['bio'], 'Bio')),
                    GestureDetector(
                        onTap: () {},
                        child: getApproprateTile(
                            snapshot.data.data['dob'], 'Date of birth')),
                    GestureDetector(
                        onTap: () {},
                        child: getApproprateTile(
                            snapshot.data.data['phone'], 'Phone')),
                    GestureDetector(
                        onTap: () {},
                        child: getApproprateTile(
                            snapshot.data.data['area'], 'Area')),
                    GestureDetector(
                        onTap: () {},
                        child: getApproprateTile(
                            snapshot.data.data['email'], 'Email')),
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
                            backgroundColor: Colors.orange.shade300,
                            content: Text(
                              'A reset link has sent to your email',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ));
                        },
                        child: getApproprateTile('Change Password', '')),
                  ]),
                );
              }
            },
          ),
        ));
  }

  showTile(String agenda, String deployType, DocumentSnapshot snap) {
    String text = '';
    showDialog(
        context: context,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: CupertinoAlertDialog(
            title: Text(
              '$agenda',
              style: TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            content: Container(
              decoration: BoxDecoration(),
              child: TextFormField(
                onChanged: (value) => text = value,
                decoration: InputDecoration(
                  hintText: "First name",
                  hintStyle: TextStyle(color: Colors.grey, letterSpacing: 1.0),
                  border: InputBorder.none,
                ),
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  if (text.length < 3) {
                    Fluttertoast.showToast(msg: 'Invalid Content');
                  } else {
                    snap.reference.setData({deployType: text}, merge: true);
                    Navigator.pop(context);
                    Fluttertoast.showToast(msg: 'Preferences Updated');
                  }
                },
                child: Text(
                  'Change',
                  style: TextStyle(
                      color: Colors.green.shade500,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              )
            ],
          ),
        ));
  }

  getApproprateTile(String title, String trailing) {
    return Container(
        margin: EdgeInsets.all(9),
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(25)),
        child: ListTile(
            title: Text(title, style: TextStyle(color: Colors.grey.shade700)),
            trailing:
                Text(trailing, style: TextStyle(color: Colors.grey.shade500))));
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
