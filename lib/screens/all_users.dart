import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ysrcp/screens/assign_work.dart';

class AllUsers extends StatefulWidget {
  @override
  _AllUsersState createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  StreamController _controller = StreamController();
  Stream _stream;
  Set _membersSet = {};

  initStream() async {
    _controller.add('waiting');

    _controller
        .add(await Firestore.instance.collection('Users').getDocuments());
  }

  @override
  void initState() {
    _stream = _controller.stream;
    initStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.deepOrange,
        appBar: _membersSet.length > 0
            ? AppBar(
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _membersSet.clear();
                    });
                  },
                ),
                actions: <Widget>[
                  Container(
                    margin: EdgeInsets.all(9),
                    alignment: Alignment.center,
                    child: Text(
                      _membersSet.length.toString(),
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  FlatButton(
                    child: Text(
                      'Done',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      setState(() {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return AssignWork(
                            uids: _membersSet,
                          );
                        })).whenComplete(() {
                          setState(() {
                            _membersSet.clear();
                          });
                        });
                      });
                    },
                  ),
                ],
              )
            : AppBar(
                title: Text(
                  'All Members',
                  style: TextStyle(fontSize: 25),
                ),
                centerTitle: true,
                elevation: 0,
              ),
        body: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30), topLeft: Radius.circular(30)),
              color: Colors.white),
          child: StreamBuilder(
            stream: _stream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == 'waiting') {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.data == null) {
                return Center(
                  child: Text(
                    'No users !',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 21),
                  ),
                );
              } else {
                return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (_, index) {
                      return Container(
                        margin: EdgeInsets.all(9),
                        decoration: BoxDecoration(
                            color: _membersSet.contains(
                                    snapshot.data.documents[index].documentID)
                                ? Colors.red.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(18)),
                        child: ListTile(
                            onTap: () {
                              setState(() {
                                if (_membersSet.contains(snapshot
                                    .data.documents[index].documentID)) {
                                  _membersSet.remove(snapshot
                                      .data.documents[index].documentID);
                                } else {
                                  _membersSet.add(snapshot
                                      .data.documents[index].documentID);
                                }
                              });
                            },
                            title: Text(
                              '${snapshot.data.documents[index]['first_name']} ${snapshot.data.documents[index]['last_name']}',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey.shade700),
                            ),
                            subtitle: Container(
                              child: Text(
                                '${snapshot.data.documents[index]['area']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            )),
                      );
                    });
              }
            },
          ),
        ));
  }
}
