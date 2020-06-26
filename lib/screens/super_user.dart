import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ysrcp/screens/change_admin_password.dart';
import 'package:ysrcp/screens/members.dart';
import 'package:ysrcp/screens/super_user_completed.dart';
import 'package:ysrcp/screens/super_user_ongoing.dart';
import 'package:ysrcp/screens/super_user_pending.dart';
import 'package:ysrcp/screens/super_user_requests.dart';

class Superuser extends StatefulWidget {
  @override
  _SuperuserState createState() => _SuperuserState();
}

class _SuperuserState extends State<Superuser> {
  Firestore _firestore = Firestore.instance;
  var pendingCount = 0;
  var onGoingCount = 0;
  var requestsCount = 0;
  subscribeToTopic() {
    FirebaseMessaging _msg = FirebaseMessaging();
    _msg.subscribeToTopic('admin');
  }

  initCount() async {
    _firestore.collection('pending').getDocuments().then((value) {
      setState(() {
        pendingCount = value.documents.length;
      });
    });

    _firestore.collection('onGoing').getDocuments().then((value) {
      setState(() {
        onGoingCount = value.documents.length;
      });
    });
    _firestore.collection('requests').getDocuments().then((value) {
      setState(() {
        requestsCount = value.documents.length;
      });
    });
  }

  @override
  void initState() {
    initCount();
    subscribeToTopic();
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
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return Members();
            })).whenComplete(() => initCount());
          },
        ),
        body: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30)),
                color: Colors.white),
            child: StreamBuilder<QuerySnapshot>(
                stream: null,
                builder: (context, snapshot) {
                  return ListView(children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.grey.shade100),
                      child: ListTile(
                          onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => SuperUserPending()))
                              .whenComplete(() => initCount()),
                          title: Center(
                              child: Text('Pending ($pendingCount)',
                                  style:
                                      TextStyle(color: Colors.grey.shade700)))),
                    ),
                    Container(
                      margin: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.grey.shade100),
                      child: ListTile(
                          onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => SuperUserOnGoing()))
                              .whenComplete(() => initCount()),
                          title: Center(
                              child: Text('OnGoing ($onGoingCount)',
                                  style:
                                      TextStyle(color: Colors.grey.shade700)))),
                    ),
                    Container(
                      margin: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.grey.shade100),
                      child: ListTile(
                          onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => SuperUserRequests()))
                              .whenComplete(() => initCount()),
                          title: Center(
                              child: Text('Requests ($requestsCount)',
                                  style:
                                      TextStyle(color: Colors.grey.shade700)))),
                    ),
                    Container(
                      margin: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.grey.shade100),
                      child: ListTile(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => SuperUserCompleted())),
                          title: Center(
                              child: Text('Completed',
                                  style:
                                      TextStyle(color: Colors.grey.shade700)))),
                    ),
                    Container(
                        margin: EdgeInsets.all(9),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.grey.shade100),
                        child: ListTile(
                            onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => Members()))
                                .whenComplete(() => initCount()),
                            title: Center(
                                child: Text('Members',
                                    style: TextStyle(
                                        color: Colors.grey.shade700))))),
                    Container(
                        margin: EdgeInsets.all(9),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.grey.shade100),
                        child: ListTile(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ChangeAdminPassword())),
                          title: Center(
                            child: Text('Change Admin Password',
                                style: TextStyle(color: Colors.grey.shade700)),
                          ),
                        ))
                  ]);
                })));
  }
}
