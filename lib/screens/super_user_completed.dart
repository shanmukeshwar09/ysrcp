import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SuperUserCompleted extends StatefulWidget {
  @override
  _SuperUserCompletedState createState() => _SuperUserCompletedState();
}

class _SuperUserCompletedState extends State<SuperUserCompleted> {
  Firestore _firestore = Firestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.green,
        appBar: AppBar(
          title: Text('Completed', style: TextStyle(fontSize: 23)),
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
                stream: _firestore.collection('final').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.data.documents.length == 0) {
                      return Center(
                        child: Text(
                          'No meetings completed yet !',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey.shade900, fontSize: 21),
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
                                        borderRadius:
                                            BorderRadius.circular(18)),
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
                              }));
                    }
                  }
                })));
  }
}
