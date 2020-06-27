import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:ysrcp/screens/super_user.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  String pin = '';
  String error = '';
  bool isChecking = false;
  Firestore _firestore = Firestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.green,
        appBar: AppBar(
          title: Text(
            'Authenticate',
            style: TextStyle(fontSize: 23),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30)),
                color: Colors.white),
            child: Column(children: <Widget>[
              SizedBox(height: 25),
              Text('Enter PIN to continue',
                  style: TextStyle(color: Colors.grey.shade700)),
              SizedBox(height: 25),
              PinEntryTextField(
                isTextObscure: true,
                onSubmit: (value) {
                  setState(() {
                    isChecking = true;
                  });
                  _firestore
                      .collection('admin')
                      .document('admin_doc')
                      .get()
                      .then((snap) {
                    if (value == snap.data['password']) {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => Superuser()));
                    } else {
                      setState(() {
                        isChecking = false;
                        error = 'Wrong Password';
                      });
                    }
                  });
                },
              ),
              SizedBox(height: 25),
              isChecking
                  ? Center(child: CircularProgressIndicator())
                  : Text(error, style: TextStyle(color: Colors.red.shade300))
            ])));
  }
}
