import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ysrcp/service/notifications.dart';

class AssignWork extends StatefulWidget {
  final Set uids;

  const AssignWork({Key key, this.uids}) : super(key: key);
  @override
  _AssignWorkState createState() => _AssignWorkState();
}

class _AssignWorkState extends State<AssignWork> {
  Firestore _firestore = Firestore.instance;
  String _dateTime = DateTime.now().toString().split(' ')[0];
  String link = '';
  String des = '';
  bool loading = false;
  String selectedChannel = 'NTV';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.green,
        appBar: AppBar(
          title: Text(
            'Assign Meeting',
            style: TextStyle(fontSize: 25),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30)),
                color: Colors.white),
            child: loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView(children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.all(10),
                        child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(9),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200)),
                              disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200)),
                              hintText: _dateTime,
                              hintStyle: TextStyle(
                                  color: Colors.grey, letterSpacing: 1.0),
                              border: InputBorder.none,
                            ),
                            isExpanded: true,
                            iconEnabledColor: Colors.grey,
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                            iconSize: 30,
                            elevation: 9,
                            value: selectedChannel,
                            onChanged: (newValue) {
                              setState(() {
                                selectedChannel = newValue;
                              });
                            },
                            items: <String>[
                              'NTV',
                              'SAKSHI',
                              'TV19',
                              'AP27/7',
                              'I\'NEWS',
                              '10TV',
                              'TV99',
                              'HMTV',
                              'PRIME99',
                              '6TV',
                              'ABN',
                              'BHARAT TODAY',
                              'MOJOTV',
                              'TV5',
                              'STUDIO N',
                              '10 TV',
                              'MAHA NEWS'
                            ].map<DropdownMenuItem<String>>((e) {
                              return DropdownMenuItem<String>(
                                  value: e, child: Text(e.toString()));
                            }).toList())),
                    Container(
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                            readOnly: true,
                            enabled: true,
                            onTap: () async {
                              final result = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(DateTime.now().year + 3));

                              if (result != null) {
                                setState(() {
                                  _dateTime = result.toString().split(' ')[0];
                                });
                              }
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200)),
                              disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200)),
                              hintText: _dateTime,
                              hintStyle: TextStyle(
                                  color: Colors.grey, letterSpacing: 1.0),
                              border: InputBorder.none,
                            ))),
                    Container(
                      height: 180,
                      margin: EdgeInsets.only(top: 10),
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        onChanged: (value) {
                          des = value;
                        },
                        maxLines: 100,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200)),
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200)),
                          hintText: "Agenda",
                          hintStyle:
                              TextStyle(color: Colors.grey, letterSpacing: 1.0),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Center(
                        child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            color: Colors.deepOrange,
                            padding: EdgeInsets.all(9),
                            child: Text(
                              'Assign',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            onPressed: () {
                              if (des.length > 0) {
                                assignWork();
                              }
                            }))
                  ])));
  }

  assignWork() {
    setState(() {
      loading = true;
    });

    widget.uids.forEach((element) async {
      final docId = DateTime.now().millisecondsSinceEpoch.toString();
      print(docId);
      _firestore.collection('pending').document(docId).setData({
        'channel_name': selectedChannel,
        'date': _dateTime,
        'agenda': des,
        'uid': element,
        'status': 'pending'
      }).whenComplete(() {
        _firestore
            .collection('Users')
            .document(element)
            .collection('pending')
            .document(docId)
            .setData({
          'channel_name': selectedChannel,
          'date': _dateTime,
          'agenda': des,
        }).whenComplete(() {
          Notifications().pushNotification('New meeting', des, element);
        });
      });
      Fluttertoast.showToast(msg: 'Done !');
    });
    Navigator.pop(context);
  }
}
