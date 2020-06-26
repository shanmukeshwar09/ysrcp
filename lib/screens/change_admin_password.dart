import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';

class ChangeAdminPassword extends StatefulWidget {
  @override
  _ChangeAdminPasswordState createState() => _ChangeAdminPasswordState();
}

class _ChangeAdminPasswordState extends State<ChangeAdminPassword> {
  String pin = '';
  String error = '';
  String changeError = '';
  String pin1 = '';
  String pin2 = '';
  bool isChecking = false;
  bool isChanging = false;
  Firestore _firestore = Firestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.deepOrange,
        appBar: AppBar(
          title: Text(
            'Change Password',
            style: TextStyle(fontSize: 23),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30)),
                color: Colors.white),
            child: Column(children: <Widget>[
              SizedBox(height: 25),
              Text('Enter old PIN to continue',
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
                      setState(() {
                        isChecking = false;
                        error = 'Authentication Sucessfull';
                      });
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
                  : Text(error,
                      style: TextStyle(
                          color: error == 'Wrong Password'
                              ? Colors.red.shade300
                              : Colors.green.shade300)),
              SizedBox(height: 18),
              Container(
                  margin: EdgeInsets.all(9),
                  child: Text('Enter new PIN',
                      style: TextStyle(color: Colors.grey.shade700))),
              PinEntryTextField(
                isTextObscure: true,
                onSubmit: (value) {
                  pin1 = value;
                },
              ),
              SizedBox(height: 18),
              Container(
                  margin: EdgeInsets.all(9),
                  child: Text('Confirm PIN',
                      style: TextStyle(color: Colors.grey.shade700))),
              PinEntryTextField(
                isTextObscure: true,
                onSubmit: (value) {
                  pin2 = value;
                  if (pin1 == pin2) {
                    setState(() {
                      isChanging = true;
                    });
                    _firestore
                        .collection('admin')
                        .document('admin_doc')
                        .setData({
                      'password': pin1,
                    }).whenComplete(() {
                      Fluttertoast.showToast(msg: 'Password Changed');
                      Navigator.pop(context);
                    });
                  } else {
                    setState(() {
                      changeError = 'un-matched passwords';
                    });
                  }
                },
              ),
              SizedBox(height: 25),
              isChanging
                  ? Center(child: CircularProgressIndicator())
                  : Text(changeError,
                      style: TextStyle(color: Colors.red.shade300)),
            ])));
  }
}
