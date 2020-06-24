import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ysrcp/screens/signin.dart';
import 'package:ysrcp/screens/super_user.dart';
import 'package:ysrcp/screens/user_request.dart';

class MainPage extends StatefulWidget {
  final uid;

  const MainPage({Key key, this.uid}) : super(key: key);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  StreamController _pendingController = StreamController.broadcast();
  Stream _pendingStream;
  StreamController _onGoingController = StreamController.broadcast();
  Stream _onGoingStream;
  Firestore _firestore = Firestore.instance;

  TabController _tabController;

  initOnGoing() async {
    _onGoingController.add('waiting');
    await _firestore
        .collection('Users')
        .document(widget.uid)
        .collection('onGoing')
        .getDocuments()
        .then((value) {
      if (value.documents.length > 0) {
        _onGoingController.add(value.documents);
      } else {
        _onGoingController.add('data_null');
      }
    });
  }

  initPending() async {
    _pendingController.add('waiting');
    await _firestore
        .collection('Users')
        .document(widget.uid)
        .collection('pending')
        .getDocuments()
        .then((value) {
      if (value.documents.length > 0) {
        _pendingController.add(value.documents);
      } else {
        _pendingController.add('data_null');
      }
    });
  }

  @override
  void initState() {
    _tabController = new TabController(length: 2, vsync: this);
    _pendingStream = _pendingController.stream;
    _onGoingStream = _onGoingController.stream;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      appBar: AppBar(
        title: Text(
          'YSRCP',
          style: TextStyle(fontSize: 25),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          indicatorColor: Colors.transparent,
          labelColor: Colors.grey,
          unselectedLabelColor: Colors.white,
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'OnGoing'),
          ],
          controller: _tabController,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return UserRequest(
              uid: widget.uid,
            );
          }));
        },
      ),
      drawer: Drawer(
        elevation: 50,
        child: Column(
          children: <Widget>[
            DrawerHeader(child: Text('//TODO YSRCP LOGO')),
            ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return Superuser();
                }));
              },
              title: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 9),
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30)),
                  child: Text(
                    'Super User',
                    style: TextStyle(color: Colors.red.shade500),
                  )),
            ),
            ListTile(
              onTap: () async {
                final SharedPreferences _pref =
                    await SharedPreferences.getInstance();
                await _pref.clear();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) {
                  return SignIn();
                }));
              },
              title: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 9),
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30)),
                  child: Text(
                    'Logout',
                    style: TextStyle(color: Colors.red.shade500),
                  )),
            )
          ],
        ),
      ),
      body: TabBarView(
        children: [
          getPending(),
          getOnGoing(),
        ],
        controller: _tabController,
      ),
    );
  }

  getPending() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          color: Colors.white),
      child: StreamBuilder(
        stream: _pendingStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == 'waiting') {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data == 'data_null') {
            return Center(
              child: Text(
                'No meetings Assaigned !',
                style: TextStyle(color: Colors.grey.shade900, fontSize: 21),
              ),
            );
          } else if (snapshot.data == null) {
            initPending();
            return Center(child: CircularProgressIndicator());
          } else {
            return Container(
              child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, index) {
                    return Container(
                      margin: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(18)),
                      child: ListTile(
                        title: Text(
                            'Channel Name : ${snapshot.data[index]['channel_name']}'),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  'Date : ${snapshot.data[index]['date']}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  'Description : ${snapshot.data[index]['description']}'),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                FlatButton(
                                  color: Colors.green.shade500,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9)),
                                  onPressed: () async {
                                    var docId = _firestore
                                        .collection('onGoing')
                                        .document()
                                        .documentID;

                                    await _firestore
                                        .collection('Users')
                                        .document(widget.uid)
                                        .get()
                                        .then((value) async {
                                      await value.reference
                                          .collection('onGoing')
                                          .document(docId)
                                          .setData({
                                        'channel_name': snapshot.data[index]
                                            ['channel_name'],
                                        'date': snapshot.data[index]['date'],
                                        'link': snapshot.data[index]['link'],
                                        'description': snapshot.data[index]
                                            ['description'],
                                        'docId': docId
                                      });

                                      await _firestore
                                          .collection('onGoing')
                                          .document(docId)
                                          .setData({
                                        'name': value.data['first_name'] +
                                            ' ' +
                                            value.data['last_name'],
                                        'channel_name': snapshot.data[index]
                                            ['channel_name'],
                                        'date': snapshot.data[index]['date'],
                                        'link': snapshot.data[index]['link'],
                                        'description': snapshot.data[index]
                                            ['description'],
                                        'uid': snapshot.data[index].documentID,
                                      });
                                      await _firestore
                                          .collection('pending')
                                          .document(
                                              snapshot.data[index].documentID)
                                          .delete();
                                      await _firestore
                                          .collection('Users')
                                          .document(widget.uid)
                                          .collection('pending')
                                          .document(
                                              snapshot.data[index].documentID)
                                          .delete();

                                      initPending();
                                    });
                                  },
                                  child: Text(
                                    'Accept',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                FlatButton(
                                  color: Colors.red,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9)),
                                  onPressed: () async {
                                    await _firestore
                                        .collection('Users')
                                        .document(widget.uid)
                                        .collection('pending')
                                        .document(
                                            snapshot.data[index].documentID)
                                        .delete();

                                    _firestore
                                        .collection('pending')
                                        .document(
                                            snapshot.data[index].documentID)
                                        .setData({'status': 'rejected'},
                                            merge: true);

                                    initPending();
                                  },
                                  child: Text(
                                    'Decline',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            );
          }
        },
      ),
    );
  }

  getOnGoing() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          color: Colors.white),
      child: StreamBuilder(
        stream: _onGoingStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == 'waiting') {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data == 'data_null') {
            return Center(
              child: Text(
                'No OnGoing Meetings !',
                style: TextStyle(color: Colors.grey.shade900, fontSize: 21),
              ),
            );
          } else if (snapshot.data == null) {
            initOnGoing();
            return Center(child: CircularProgressIndicator());
          } else {
            return Container(
              child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, index) {
                    return Container(
                      margin: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(18)),
                      child: ListTile(
                        title: Text(
                            'Channel Name : ${snapshot.data[index]['channel_name']}'),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  'Date : ${snapshot.data[index]['date']}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  'Description : ${snapshot.data[index]['description']}'),
                            ),
                            Center(
                              child: FlatButton(
                                padding: EdgeInsets.all(9),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                                color: Colors.green.shade500,
                                onPressed: () async {
                                  await _firestore
                                      .collection('Users')
                                      .document(widget.uid)
                                      .collection('onGoing')
                                      .document(snapshot.data[index].documentID)
                                      .delete();

                                  await _firestore
                                      .collection('onGoing')
                                      .document(snapshot.data[index].documentID)
                                      .delete();

                                  await _firestore
                                      .collection('Users')
                                      .document(widget.uid)
                                      .get()
                                      .then((value) {
                                    _firestore
                                        .collection('final')
                                        .document(
                                            snapshot.data[index].documentID)
                                        .setData({
                                      'Channel Name': snapshot.data[index]
                                          ['channel_name'],
                                      'Links': snapshot.data[index]['link'],
                                      'Channel Description':
                                          snapshot.data[index]['description'],
                                      'Date': snapshot.data[index]['date'],
                                      'User Name': value.data['first_name'] +
                                          ' ' +
                                          value.data['last_name'],
                                    });
                                  });

                                  initOnGoing();
                                },
                                child: Text(
                                  'Submit',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            );
          }
        },
      ),
    );
  }
}