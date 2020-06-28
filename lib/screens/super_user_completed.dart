import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ysrcp/service/colors.dart';

class SuperUserCompleted extends StatefulWidget {
  @override
  _SuperUserCompletedState createState() => _SuperUserCompletedState();
}

class _SuperUserCompletedState extends State<SuperUserCompleted> {
  String fileName = '';
  Firestore _firestore = Firestore.instance;
  ColorsMap _colorsMap = ColorsMap();

  Future downloadData() async {
    await Permission.storage.request().then((value) {
      if (value.isGranted) {
        File f = new File("/sdcard/download/ysrcp-" +
            "${DateTime.now().toString().split(' ')[0]}.csv");
        List<List<dynamic>> rows = List<List<dynamic>>();
        List<dynamic> row = List();
        row.add('Date');
        row.add('Channel');
        row.add('Member');
        row.add('Agenda');
        row.add('Time');
        row.add('Link');
        rows.add(row);

        _firestore
            .collection('final')
            .orderBy('Date', descending: true)
            .getDocuments()
            .then((value) {
          for (int i = 0; i < value.documents.length; i++) {
            List<dynamic> row = List();
            row.add(value.documents[i]['Date']);
            row.add(value.documents[i]['Channel']);
            row.add(value.documents[i]['Member']);
            row.add(value.documents[i]['Agenda']);
            row.add(value.documents[i]['Time']);
            row.add(value.documents[i]['Link']);

            rows.add(row);
          }
          String csv = const ListToCsvConverter().convert(rows);
          f.writeAsString(csv).whenComplete(
              () => Fluttertoast.showToast(msg: 'Download Done!'));
        });
      } else {
        Fluttertoast.showToast(msg: 'Permission Denied');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          downloadData();
        },
        child: Icon(Icons.print),
      ),
      backgroundColor: _colorsMap.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: _colorsMap.getAppbarColor(),
        title: Text('Completed', style: TextStyle(fontSize: 23)),
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          Center(
            child: FlatButton(
              child: Text(
                'Clear',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                await Permission.storage.request().then((value) {
                  if (value.isGranted) {
                    File f = new File("/sdcard/ysrcp/" +
                        "${DateTime.now().toString().split(' ')[0]}.csv");
                    List<List<dynamic>> rows = List<List<dynamic>>();
                    List<dynamic> row = List();
                    row.add('Date');
                    row.add('Channel');
                    row.add('Member');
                    row.add('Agenda');
                    row.add('Time');
                    row.add('Link');
                    rows.add(row);

                    _firestore
                        .collection('final')
                        .orderBy('Date', descending: true)
                        .getDocuments()
                        .then((value) {
                      for (int i = 0; i < value.documents.length; i++) {
                        List<dynamic> row = List();
                        row.add(value.documents[i]['Date']);
                        row.add(value.documents[i]['Channel']);
                        row.add(value.documents[i]['Member']);
                        row.add(value.documents[i]['Agenda']);
                        row.add(value.documents[i]['Time']);
                        row.add(value.documents[i]['Link']);

                        rows.add(row);
                      }
                      String csv = const ListToCsvConverter().convert(rows);
                      f.writeAsString(csv).whenComplete(
                          () => Fluttertoast.showToast(msg: 'Download Done!'));
                      _firestore
                          .collection('final')
                          .getDocuments()
                          .then((value) {
                        value.documents.forEach((element) {
                          element.reference.delete();
                        });
                      });
                    });
                  } else {
                    Fluttertoast.showToast(msg: 'Permission Denied');
                  }
                });
              },
            ),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30)),
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
                                        'Time : ${snapshot.data.documents[index]['Time']}'),
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
                    },
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
