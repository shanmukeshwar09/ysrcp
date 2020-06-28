import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ysrcp/screens/authenticate.dart';
import 'package:ysrcp/screens/settings.dart';
import 'package:ysrcp/screens/signin.dart';
import 'package:ysrcp/screens/submit_form.dart';
import 'package:ysrcp/screens/user_request.dart';
import 'package:ysrcp/service/colors.dart';
import 'package:ysrcp/service/notifications.dart';

import 'full_screen.dart';

class MainPage extends StatefulWidget {
  final uid;

  const MainPage({Key key, this.uid}) : super(key: key);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  Firestore _firestore = Firestore.instance;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  TabController _tabController;
  ColorsMap _colorsMap = ColorsMap();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;

  Future _showNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_ID',
      'channel name',
      'channel description',
      importance: Importance.Max,
      priority: Priority.High,
    );

    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  @override
  void initState() {
    _tabController = new TabController(length: 3, vsync: this);

    super.initState();

    initializationSettingsAndroid =
        new AndroidInitializationSettings('ic_launcher');
    initializationSettingsIOS = new IOSInitializationSettings();
    initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          _showNotification(message['data']['title'], message['data']['body']);
        },
        onLaunch: (Map<String, dynamic> message) async {},
        onResume: (Map<String, dynamic> message) async {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorsMap.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: _colorsMap.getAppbarColor(),
        title: Text(
          'YSRCP',
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
            Tab(text: 'Completed'),
          ],
          controller: _tabController,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _colorsMap.getAppbarColor(),
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return UserRequest(
              uid: widget.uid,
            );
          }));
        },
      ),
      drawer: Container(
        width: 250,
        child: Drawer(
          elevation: 30,
          child: StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance
                  .collection('Users')
                  .document(widget.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(9),
                        alignment: Alignment.topLeft,
                        child: Center(
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
                              backgroundImage:
                                  (snapshot.data['imageUrl'] == 'null')
                                      ? AssetImage('assets/circular_avatar.png')
                                      : CachedNetworkImageProvider(
                                          snapshot.data['imageUrl']),
                              maxRadius: 50,
                              minRadius: 50,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.all(5),
                        child: Text(
                          snapshot.data.data['first_name'] +
                              ' ' +
                              snapshot.data.data['last_name'],
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 18),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(9),
                        decoration: BoxDecoration(
                            color: _colorsMap.getDrawrTileColor(),
                            borderRadius: BorderRadius.circular(30)),
                        child: ListTile(
                          title: Text(
                            snapshot.data.data['bio'],
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          trailing: Text(
                            'bio',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(9),
                        decoration: BoxDecoration(
                            color: _colorsMap.getDrawrTileColor(),
                            borderRadius: BorderRadius.circular(30)),
                        child: ListTile(
                          title: Text(
                            snapshot.data.data['area'],
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          trailing: Text(
                            'Area',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => Authenticate()));
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
                              style: TextStyle(color: Colors.grey.shade500),
                            )),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return Settings(uid: widget.uid);
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
                              'Settings',
                              style: TextStyle(color: Colors.grey.shade500),
                            )),
                      ),
                      ListTile(
                        onTap: () async {
                          final SharedPreferences _pref =
                              await SharedPreferences.getInstance();
                          await _pref.clear();
                          _firebaseMessaging.unsubscribeFromTopic(widget.uid);
                          _firebaseMessaging.unsubscribeFromTopic('admin');
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
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
        ),
      ),
      body: TabBarView(
        children: [
          getPending(),
          getOnGoing(),
          getFinal(),
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
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Users')
            .document(widget.uid)
            .collection('pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.data.documents.length == 0) {
              return Center(
                  child: Text('No Pending Assaignments !',
                      style: TextStyle(
                          color: Colors.grey.shade700, fontSize: 21)));
            } else {
              return Container(
                  child: ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (_, index) {
                        return Container(
                          margin: EdgeInsets.all(9),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(18)),
                          child: ListTile(
                            title: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(9),
                                child: Text(
                                    'Channel : ${snapshot.data.documents[index]['channel_name']}',
                                    style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 19))),
                            subtitle: Column(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.only(top: 9),
                                  child: Text(
                                      'Date : ${snapshot.data.documents[index]['date']}',
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 14)),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.only(top: 9),
                                  child: Text(
                                      'Time : ${snapshot.data.documents[index]['time']}',
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 14)),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  padding:
                                      const EdgeInsets.only(top: 9, bottom: 9),
                                  child: Text(
                                      'Agenda : ${snapshot.data.documents[index]['agenda']}',
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 14)),
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: FlatButton(
                                        color: Colors.green.shade500,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        onPressed: () {
                                          var docId = DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString();

                                          _firestore
                                              .collection('Users')
                                              .document(widget.uid)
                                              .collection('onGoing')
                                              .document(docId)
                                              .setData(snapshot
                                                  .data.documents[index].data);

                                          _firestore
                                              .collection('onGoing')
                                              .document(docId)
                                              .setData({
                                            'channel_name': snapshot
                                                .data
                                                .documents[index]
                                                .data['channel_name'],
                                            'date': snapshot.data
                                                .documents[index].data['date'],
                                            'agenda': snapshot
                                                .data
                                                .documents[index]
                                                .data['agenda'],
                                            'time': snapshot.data
                                                .documents[index].data['time'],
                                            'uid': widget.uid
                                          });
                                          _firestore
                                              .collection('pending')
                                              .document(snapshot.data
                                                  .documents[index].documentID)
                                              .delete();

                                          snapshot
                                              .data.documents[index].reference
                                              .delete();

                                          Notifications().pushNotification(
                                              'Request Accepted',
                                              'Agenda : ${snapshot.data.documents[index]['agenda']}',
                                              'admin');
                                        },
                                        child: Text(
                                          'Accept',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 9),
                                    Expanded(
                                      flex: 1,
                                      child: FlatButton(
                                        color: Colors.red,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        onPressed: () {
                                          _firestore
                                              .collection('Users')
                                              .document(widget.uid)
                                              .collection('pending')
                                              .document(snapshot.data
                                                  .documents[index].documentID)
                                              .delete()
                                              .whenComplete(() {
                                            _firestore
                                                .collection('pending')
                                                .document(snapshot
                                                    .data
                                                    .documents[index]
                                                    .documentID)
                                                .setData({'status': 'rejected'},
                                                    merge: true);
                                            Notifications().pushNotification(
                                                'Request Declined',
                                                snapshot.data.documents[index]
                                                    ['agenda'],
                                                'admin');
                                          });
                                        },
                                        child: Text(
                                          'Decline',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }));
            }
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
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Users')
            .document(widget.uid)
            .collection('onGoing')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.data.documents.length == 0) {
              return Center(
                  child: Text('No OnGoing Assaignments !',
                      style: TextStyle(
                          color: Colors.grey.shade900, fontSize: 21)));
            } else {
              return Container(
                child: ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (_, index) {
                      return Container(
                        margin: EdgeInsets.all(9),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(18)),
                        child: ListTile(
                          title: Container(
                              padding: EdgeInsets.all(9),
                              alignment: Alignment.center,
                              child: Text(
                                  'Channel : ${snapshot.data.documents[index]['channel_name']}',
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 19))),
                          subtitle: Column(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(top: 9),
                                child: Text(
                                    'Date : ${snapshot.data.documents[index]['date']}',
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 14)),
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(top: 9),
                                child: Text(
                                    'Time : ${snapshot.data.documents[index]['time']}',
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 14)),
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.only(top: 9, bottom: 9),
                                child: Text(
                                    'Agenda : ${snapshot.data.documents[index]['agenda']}',
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 14)),
                              ),
                              Center(
                                child: FlatButton(
                                  padding: EdgeInsets.all(9),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18)),
                                  color: Colors.green.shade500,
                                  onPressed: () async {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (_) {
                                      return SubmitForm(
                                        uid: widget.uid,
                                        documentSnapshot:
                                            snapshot.data.documents[index],
                                      );
                                    }));
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            'Submit',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ],
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
          }
        },
      ),
    );
  }

  getFinal() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          color: Colors.white),
      child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('Users')
              .document(widget.uid)
              .collection('completed')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.data.documents.length == 0) {
                return Center(
                  child: Text(
                    'No meetings completed yet !',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 21),
                  ),
                );
              } else {
                return Container(
                  child: ListView.builder(
                      itemCount: snapshot.data.documents.length,
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
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                      'Member : ${snapshot.data.documents[index]['Member']}'),
                                ),
                                subtitle: Column(children: <Widget>[
                                  Column(children: <Widget>[
                                    Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                          'Channel : ${snapshot.data.documents[index]['Channel']}'),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(9),
                                      child: Text(
                                          'Date : ${snapshot.data.documents[index]['Date']}'),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(9),
                                      child: Text(
                                          'Agenda : ${snapshot.data.documents[index]['Agenda']}'),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(9),
                                      child: Text(
                                          'Description : ${snapshot.data.documents[index]['Description']}'),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(9),
                                      child: Text(
                                          'Link : ${snapshot.data.documents[index]['Link']}'),
                                    ),
                                  ])
                                ])));
                      }),
                );
              }
            }
          }),
    );
  }
}
