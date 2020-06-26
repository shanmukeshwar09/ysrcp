import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ysrcp/screens/additional_add.dart';
import 'package:ysrcp/screens/full_screen.dart';
import 'package:ysrcp/screens/profile_screen.dart';

class SuperUserPending extends StatefulWidget {
  @override
  _SuperUserPendingState createState() => _SuperUserPendingState();
}

class _SuperUserPendingState extends State<SuperUserPending> {
  Firestore _firestore = Firestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.deepOrange,
        appBar: AppBar(
          title: Text('Pending', style: TextStyle(fontSize: 23)),
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30)),
                color: Colors.white),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30), topLeft: Radius.circular(30)),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('pending').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.data.documents.length == 0) {
                      return Center(
                          child: Text('No pending meetings !',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey.shade900, fontSize: 21)));
                    } else {
                      return ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (_, index) {
                            return Container(
                              margin: EdgeInsets.all(9),
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(18)),
                              child: ListTile(
                                title: StreamBuilder<DocumentSnapshot>(
                                    stream: _firestore
                                        .collection('Users')
                                        .document(snapshot.data.documents[index]
                                            ['uid'])
                                        .snapshots(),
                                    builder: (context, userSnap) {
                                      if (!userSnap.hasData) {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      } else {
                                        return Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(9),
                                          child: ListTile(
                                            title: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 9),
                                              child: Text(
                                                'Member : ${userSnap.data.data['first_name']}  ${userSnap.data.data['last_name']}',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            leading: GestureDetector(
                                              onLongPress: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (_) {
                                                  return ProfileScreen(
                                                      snapshot: userSnap.data);
                                                }));
                                              },
                                              onTap: () {
                                                if (userSnap.data
                                                        .data['imageUrl'] !=
                                                    'null') {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              FullScreenImageView(
                                                                  url: userSnap
                                                                          .data
                                                                          .data[
                                                                      'imageUrl'])));
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          'No profile picture');
                                                }
                                              },
                                              child: CircleAvatar(
                                                maxRadius: 27,
                                                minRadius: 27,
                                                backgroundColor: Colors.white,
                                                backgroundImage: userSnap.data
                                                            .data['imageUrl'] ==
                                                        'null'
                                                    ? AssetImage(
                                                        'assets/circular_avatar.png')
                                                    : CachedNetworkImageProvider(
                                                        userSnap.data
                                                            .data['imageUrl'],
                                                      ),
                                              ),
                                            ),
                                            subtitle: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  child: Text(
                                                      'Channel : ${snapshot.data.documents[index]['channel_name']}'),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
                                                  child: Text(
                                                      'Date : ${snapshot.data.documents[index]['date']}'),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 9),
                                                  child: Text(
                                                      'Agenda : ${snapshot.data.documents[index]['agenda']}'),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 9, bottom: 9),
                                                  child: Text(
                                                      'Status : ${snapshot.data.documents[index]['status']}'
                                                          .toString()),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: FlatButton(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            14)),
                                                            color: Colors
                                                                .red.shade300,
                                                            child: Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18),
                                                            ),
                                                            onPressed: () {
                                                              snapshot
                                                                  .data
                                                                  .documents[
                                                                      index]
                                                                  .reference
                                                                  .delete();
                                                              userSnap.data
                                                                  .reference
                                                                  .collection(
                                                                      'pending')
                                                                  .document(snapshot
                                                                      .data
                                                                      .documents[
                                                                          index]
                                                                      .documentID)
                                                                  .delete();
                                                            }),
                                                      ),
                                                      SizedBox(width: 5),
                                                      Expanded(
                                                        child: FlatButton(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            14)),
                                                            color: Colors
                                                                .green.shade300,
                                                            child: Text(
                                                              'Add',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (_) => AdditionalAdd(
                                                                          snap: snapshot
                                                                              .data
                                                                              .documents[index])));
                                                            }),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    }),
                              ),
                            );
                          });
                    }
                  }
                },
              ),
            )));
  }
}
