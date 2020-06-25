import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ysrcp/screens/all_users.dart';

class Superuser extends StatefulWidget {
  @override
  _SuperuserState createState() => _SuperuserState();
}

class _SuperuserState extends State<Superuser>
    with SingleTickerProviderStateMixin {
  StreamController _pendingController = StreamController.broadcast();
  Stream _pendingStream;
  StreamController _onGoingController = StreamController.broadcast();
  Stream _onGoingStream;
  StreamController _finalConroller = StreamController.broadcast();
  Stream _finalStream;
  StreamController _requestsController = StreamController.broadcast();
  Stream _requestsStream;
  TabController _tabController;
  Firestore _firestore = Firestore.instance;

  initRequests() async {
    _requestsController.add('waiting');
    Firestore.instance.collection('requests').getDocuments().then((value) {
      if (value.documents.length > 0) {
        _requestsController.add(value.documents);
      } else {
        _requestsController.add('null_data');
      }
    });
  }

  initFinal() async {
    _pendingController.add('waiting');
    Firestore.instance.collection('final').getDocuments().then((value) {
      if (value.documents.length > 0) {
        _finalConroller.add(value.documents);
      } else {
        _finalConroller.add('null_data');
      }
    });
  }

  initPending() async {
    _pendingController.add('waiting');
    Firestore.instance.collection('pending').getDocuments().then((value) {
      if (value.documents.length > 0) {
        _pendingController.add(value.documents);
      } else {
        _pendingController.add('null_data');
      }
    });
  }

  initOnGoingStream() {
    _onGoingController.add('waiting');
    Firestore.instance.collection('onGoing').getDocuments().then((value) {
      if (value.documents.length > 0) {
        _onGoingController.add(value.documents);
      } else {
        _onGoingController.add('null_data');
      }
    });
  }

  @override
  void initState() {
    _tabController = new TabController(length: 4, vsync: this);
    _pendingStream = _pendingController.stream;
    _onGoingStream = _onGoingController.stream;
    _finalStream = _finalConroller.stream;
    _requestsStream = _requestsController.stream;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      appBar: AppBar(
        title: Text(
          'SuperUser',
          style: TextStyle(fontSize: 25),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          indicatorColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'OnGoing'),
            Tab(text: 'Requests'),
            Tab(text: 'Completed'),
          ],
          controller: _tabController,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return AllUsers();
          })).whenComplete(() {
            initPending();
            initRequests();
            initOnGoingStream();
            initFinal();
          });
        },
      ),
      body: TabBarView(
        children: [
          getPending(),
          getOnGoing(),
          getRequests(),
          getCompleted(),
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
          } else if (snapshot.data == 'null_data') {
            return Center(
              child: Text(
                'No meetings!\n\nAdd using floating button',
                textAlign: TextAlign.center,
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
                      padding: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(18)),
                      child: ListTile(
                        title: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(9),
                            child: Text(snapshot.data[index]['name'])),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  'Channel Name : ${snapshot.data[index]['channel_name']}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  'Date : ${snapshot.data[index]['date']}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  'Status : ${snapshot.data[index]['status']}'),
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: FlatButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18)),
                                      color: Colors.red.shade300,
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                      onPressed: () {
                                        // _firestore.collection(path)
                                      }),
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
          } else if (snapshot.data == 'null_data') {
            return Center(
              child: Text(
                'No meetings!\n\nAdd using floating button',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade900, fontSize: 21),
              ),
            );
          } else if (snapshot.data == null) {
            initOnGoingStream();
            return Center(child: CircularProgressIndicator());
          } else {
            return Container(
              child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, index) {
                    return Container(
                      margin: EdgeInsets.all(9),
                      padding: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(18)),
                      child: ListTile(
                        title: Text(snapshot.data[index]['name']),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(snapshot.data[index]['channel_name']
                                    .toString()),
                                Text(
                                  snapshot.data[index]['date'],
                                ),
                              ],
                            ),
                            FlatButton(
                              padding: EdgeInsets.all(9),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              color: Colors.green.shade500,
                              onPressed: () async {
                                await _firestore
                                    .collection('Users')
                                    .document(snapshot.data[index]['uid'])
                                    .collection('onGoing')
                                    .document(snapshot.data[index].documentID)
                                    .delete();

                                await _firestore
                                    .collection('onGoing')
                                    .document(snapshot.data[index].documentID)
                                    .delete();

                                await _firestore
                                    .collection('final')
                                    .document(snapshot.data[index].documentID)
                                    .setData({
                                  'Channel Name': snapshot.data[index]
                                      ['channel_name'],
                                  'Links': snapshot.data[index]['link'],
                                  'Channel Description': snapshot.data[index]
                                      ['description'],
                                  'Date': snapshot.data[index]['date'],
                                  'User Name': snapshot.data[index]['name'],
                                });

                                initOnGoingStream();
                              },
                              child: Text('Submit'),
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

  getRequests() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          color: Colors.white),
      child: StreamBuilder(
        stream: _requestsStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == 'waiting') {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data == 'null_data') {
            return Center(
              child: Text(
                'No meetings!\n\nAdd using floating button',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade900, fontSize: 21),
              ),
            );
          } else if (snapshot.data == null) {
            initRequests();
            return Center(child: CircularProgressIndicator());
          } else {
            return Container(
              child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, index) {
                    return Container(
                      margin: EdgeInsets.all(9),
                      padding: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(18)),
                      child: ListTile(
                        title: Text(snapshot.data[index]['name']),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(snapshot.data[index]['channel_name']
                                    .toString()),
                                Text(
                                  snapshot.data[index]['date'],
                                ),
                              ],
                            ),
                            FlatButton(
                              padding: EdgeInsets.all(9),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              color: Colors.green.shade500,
                              onPressed: () async {
                                await _firestore
                                    .collection('requests')
                                    .document(snapshot.data[index].documentID)
                                    .delete();

                                await _firestore
                                    .collection('final')
                                    .document(snapshot.data[index].documentID)
                                    .setData({
                                  'Channel Name': snapshot.data[index]
                                      ['channel_name'],
                                  'Links': snapshot.data[index]['link'],
                                  'Channel Description': snapshot.data[index]
                                      ['description'],
                                  'Date': snapshot.data[index]['date'],
                                  'User Name': snapshot.data[index]['name'],
                                });

                                initRequests();
                              },
                              child: Text('Submit'),
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

  getCompleted() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          color: Colors.white),
      child: StreamBuilder(
        stream: _finalStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == 'waiting') {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data == 'null_data') {
            return Center(
              child: Text(
                'No meetings!\n\nAdd using floating button',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade900, fontSize: 21),
              ),
            );
          } else if (snapshot.data == null) {
            initFinal();
            return Center(child: CircularProgressIndicator());
          } else {
            return Container(
              child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, index) {
                    return Container(
                      margin: EdgeInsets.all(9),
                      padding: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(18)),
                      child: ListTile(
                        title: Text(snapshot.data[index]['User Name']),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(snapshot.data[index]['Channel Name']
                                    .toString()),
                                Text(
                                  snapshot.data[index]['Date'],
                                ),
                              ],
                            ),
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
