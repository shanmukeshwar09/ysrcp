import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssignWork extends StatefulWidget {
  final Set uids;

  const AssignWork({Key key, this.uids}) : super(key: key);
  @override
  _AssignWorkState createState() => _AssignWorkState();
}

class _AssignWorkState extends State<AssignWork> {
  Firestore _firestore = Firestore.instance;
  String _dateTime = DateTime.now().toString().split(' ')[0];
  String channelName = '';
  String link = '';
  String des = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.deepOrange,
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
                  topRight: Radius.circular(30), topLeft: Radius.circular(30)),
              color: Colors.white),
          child: loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        onChanged: (value) {
                          channelName = value;
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
                          hintText: "Channel name",
                          hintStyle:
                              TextStyle(color: Colors.grey, letterSpacing: 1.0),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
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
                          hintStyle:
                              TextStyle(color: Colors.grey, letterSpacing: 1.0),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        onChanged: (value) {
                          link = value;
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
                          hintText: "Youtube Link",
                          hintStyle:
                              TextStyle(color: Colors.grey, letterSpacing: 1.0),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      height: 300,
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
                          hintText: "Description",
                          hintStyle:
                              TextStyle(color: Colors.grey, letterSpacing: 1.0),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        margin: EdgeInsets.all(18),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.deepOrange),
                        child: FlatButton(
                          child: Text(
                            'Assign',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          onPressed: () {
                            if (des.length > 0 &&
                                link.length > 0 &&
                                channelName.length > 0) {
                              assignWork();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
        ));
  }

  assignWork() async {
    setState(() {
      loading = true;
    });

    var pushid = _firestore.collection('pending').document().documentID;

    widget.uids.forEach((element) async {
      await _firestore
          .collection('Users')
          .document(element)
          .get()
          .then((value) async {
        await value.reference.collection('pending').document(pushid).setData({
          'channel_name': channelName,
          'date': _dateTime,
          'link': link,
          'description': des,
          'docId' : pushid,
        });
        await _firestore.collection('pending').document(pushid).setData({
          'status': 'pending',
          'channel_name': channelName,
          'date': _dateTime,
          'name': value.data['first_name'] + ' ' + value.data['last_name']
        });
      });
    });
    Navigator.pop(context);
  }
}
