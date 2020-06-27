import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ysrcp/service/notifications.dart';

class SubmitForm extends StatefulWidget {
  final uid;
  final DocumentSnapshot documentSnapshot;

  const SubmitForm({Key key, this.uid, this.documentSnapshot})
      : super(key: key);

  @override
  _SubmitFormState createState() => _SubmitFormState();
}

class _SubmitFormState extends State<SubmitForm> {
  Firestore _firestore = Firestore.instance;
  final _controller = TextEditingController();
  final _linkController = TextEditingController();
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: Text(
          'Submit',
          style: TextStyle(fontSize: 25),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30)),
            color: Colors.white),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                      controller: _linkController,
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
                    height: 180,
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: _controller,
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
                        padding:
                            EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        color: Colors.deepOrange,
                        onPressed: () async {
                          if (_controller.text.length > 15) {
                            setState(() {
                              loading = true;
                            });
                            await _firestore
                                .collection('Users')
                                .document(widget.uid)
                                .get()
                                .then((value) {
                              _firestore
                                  .collection('requests')
                                  .document(widget.documentSnapshot.documentID)
                                  .setData({
                                'channel_name':
                                    widget.documentSnapshot['channel_name'],
                                'agenda': widget.documentSnapshot['agenda'],
                                'description': _controller.text,
                                'date': widget.documentSnapshot['date'],
                                'link': _linkController.text,
                                'uid': widget.uid
                              });
                            });

                            await widget.documentSnapshot.reference.delete();

                            await _firestore
                                .collection('onGoing')
                                .document(widget.documentSnapshot.documentID)
                                .delete();
                            Notifications().pushNotification(
                                'New Request',
                                widget.documentSnapshot.data['agenda'],
                                'admin');
                            Fluttertoast.showToast(msg: 'Done !');
                            Navigator.pop(context);
                          } else {
                            Fluttertoast.showToast(
                                msg: '15 Charecters Minimum');
                          }
                        },
                        child: Text('submit',
                            style: TextStyle(color: Colors.white))),
                  )
                ],
              ),
      ),
    );
  }
}
