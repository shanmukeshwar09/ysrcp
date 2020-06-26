import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ysrcp/screens/full_screen.dart';
import 'package:ysrcp/screens/profile_screen.dart';

class SuperUserRequests extends StatefulWidget {
  @override
  _SuperUserRequestsState createState() => _SuperUserRequestsState();
}

class _SuperUserRequestsState extends State<SuperUserRequests> {
  Firestore _firestore = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.deepOrange,
        appBar: AppBar(
          title: Text('Requests', style: TextStyle(fontSize: 23)),
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30)),
                color: Colors.white),
            child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('requests').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.data.documents.length == 0) {
                      return Center(
                          child: Text(
                        'No Requests !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey.shade900, fontSize: 21),
                      ));
                    } else {
                      return Container(
                          child: ListView.builder(
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
                                            .document(snapshot
                                                .data.documents[index]['uid'])
                                            .snapshots(),
                                        builder: (context, userSnap) {
                                          if (!userSnap.hasData) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          } else {
                                            return Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.all(9),
                                              child: ListTile(
                                                title: Center(
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
                                                          snapshot:
                                                              userSnap.data);
                                                    }));
                                                  },
                                                  onTap: () {
                                                    if (userSnap.data
                                                            .data['imageUrl'] !=
                                                        'null') {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (_) => FullScreenImageView(
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
                                                    backgroundColor:
                                                        Colors.white,
                                                    backgroundImage: userSnap
                                                                    .data.data[
                                                                'imageUrl'] ==
                                                            'null'
                                                        ? AssetImage(
                                                            'assets/circular_avatar.png')
                                                        : CachedNetworkImageProvider(
                                                            userSnap.data.data[
                                                                'imageUrl'],
                                                          ),
                                                  ),
                                                ),
                                                subtitle: Column(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
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
                                                              top: 5),
                                                      child: Text(
                                                          'Agenda : ${snapshot.data.documents[index]['agenda']}'
                                                              .toString()),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5),
                                                      child: Text(
                                                          'Link : ${snapshot.data.documents[index]['link']}'
                                                              .toString()),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5),
                                                      child: Text(
                                                          'Description : ${snapshot.data.documents[index]['description']}'
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
                                                                        BorderRadius.circular(
                                                                            14)),
                                                                color: Colors
                                                                    .red
                                                                    .shade300,
                                                                child: Text(
                                                                  'Delete',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          15),
                                                                ),
                                                                onPressed: () {
                                                                  snapshot
                                                                      .data
                                                                      .documents[
                                                                          index]
                                                                      .reference
                                                                      .delete();
                                                                }),
                                                          ),
                                                          SizedBox(width: 9),
                                                          Expanded(
                                                            child: FlatButton(
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            14)),
                                                                color: Colors
                                                                    .green
                                                                    .shade300,
                                                                child: Text(
                                                                  'Approve',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          15),
                                                                ),
                                                                onPressed: () {
                                                                  _firestore
                                                                      .collection(
                                                                          'final')
                                                                      .document(snapshot
                                                                          .data
                                                                          .documents[
                                                                              index]
                                                                          .documentID)
                                                                      .setData({
                                                                    'Member': userSnap.data.data[
                                                                            'first_name'] +
                                                                        ' ' +
                                                                        userSnap
                                                                            .data
                                                                            .data['last_name'],
                                                                    'Channel': snapshot
                                                                        .data
                                                                        .documents[
                                                                            index]
                                                                        .data['channel_name'],
                                                                    'Agenda': snapshot
                                                                        .data
                                                                        .documents[
                                                                            index]
                                                                        .data['agenda'],
                                                                    'Date': snapshot
                                                                        .data
                                                                        .documents[
                                                                            index]
                                                                        .data['date'],
                                                                    'Description': snapshot
                                                                        .data
                                                                        .documents[
                                                                            index]
                                                                        .data['description'],
                                                                    'Link': snapshot
                                                                        .data
                                                                        .documents[
                                                                            index]
                                                                        .data['link']
                                                                  }).whenComplete(() => snapshot
                                                                          .data
                                                                          .documents[
                                                                              index]
                                                                          .reference
                                                                          .delete());
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
                              }));
                    }
                  }
                })));
  }
}
