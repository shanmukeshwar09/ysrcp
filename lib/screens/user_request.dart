import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ysrcp/service/notifications.dart';

class UserRequest extends StatefulWidget {
  final uid;

  const UserRequest({Key key, this.uid}) : super(key: key);
  @override
  _UserRequestState createState() => _UserRequestState();
}

class _UserRequestState extends State<UserRequest> {
  Firestore _firestore = Firestore.instance;
  String _dateTime = DateTime.now().toString().split(' ')[0];
  String selectedChannel = 'NTV';
  String link = '';
  String des = '';
  bool loading = false;

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
                              'MAHA NEWS',
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
                      child: RaisedButton(
                        padding: EdgeInsets.all(12),
                        onPressed: () {
                          if (des.length > 0 && link.length > 0) {
                            request();
                          }
                        },
                        color: Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        child: Text(
                          'Request',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
        ));
  }

  request() async {
    if (des.length > 3 && link.length > 3) {
      setState(() {
        loading = true;
      });

      _firestore.collection('requests').document().setData({
        'channel_name': selectedChannel,
        'link': link,
        'description': des,
        'date': _dateTime,
        'uid': widget.uid,
        'agenda': 'null'
      }).whenComplete(() {
        Notifications().pushNotification('New Request', des, 'admin');
        Fluttertoast.showToast(msg: 'Done !');
        Navigator.pop(context);
      });
    } else {
      Fluttertoast.showToast(msg: 'Incomplete Fields');
    }
  }
}
