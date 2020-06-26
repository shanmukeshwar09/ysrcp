import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ysrcp/screens/main_page.dart';
import 'package:ysrcp/service/notifications.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String passwordClone = '';
  String phone = '';
  bool loading = false;
  String selectedArea = 'Hyderabad';
  FirebaseMessaging _messaging = FirebaseMessaging();

  String _dateTime;

  bool hidePassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _dateTime = DateTime(DateTime.now().year - 20).toString().split(' ')[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      appBar: AppBar(
        title: Text(
          'Register',
          style: TextStyle(
              letterSpacing: 1.0, fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            color: Colors.white),
        child: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 9, horizontal: 27),
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromRGBO(225, 95, 27, .3),
                              blurRadius: 20,
                              offset: Offset(0, 10))
                        ]),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[300]))),
                            child: TextFormField(
                              onChanged: (value) => firstName = value,
                              validator: (value) {
                                return value.length > 1 ? null : 'invalid name';
                              },
                              decoration: InputDecoration(
                                hintText: "First name",
                                hintStyle: TextStyle(
                                    color: Colors.grey, letterSpacing: 1.0),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[300]))),
                            child: TextFormField(
                              onChanged: (value) => lastName = value,
                              validator: (value) {
                                return value.length > 1 ? null : 'invalid name';
                              },
                              decoration: InputDecoration(
                                hintText: "Last name",
                                hintStyle: TextStyle(
                                    color: Colors.grey, letterSpacing: 1.0),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[300]))),
                            child: TextFormField(
                              readOnly: true,
                              enabled: true,
                              onTap: () async {
                                final result = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        DateTime(DateTime.now().year - 20),
                                    firstDate:
                                        DateTime(DateTime.now().year - 50),
                                    lastDate:
                                        DateTime(DateTime.now().year - 15));

                                if (result != null) {
                                  setState(() {
                                    _dateTime = result.toString().split(' ')[0];
                                    print(_dateTime);
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                suffix: Text('DateOfBirth'),
                                hintText: _dateTime,
                                hintStyle: TextStyle(
                                    color: Colors.grey, letterSpacing: 1.0),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[300]))),
                            child: TextFormField(
                              onChanged: (value) => phone = value,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                return (value.length != 10)
                                    ? 'Invalid Phone number'
                                    : null;
                              },
                              decoration: InputDecoration(
                                hintText: "Phone",
                                hintStyle: TextStyle(
                                    color: Colors.grey, letterSpacing: 1.0),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[300]))),
                            child: TextFormField(
                              onChanged: (value) => email = value,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                return (value.isEmpty ||
                                        !value.contains('@') ||
                                        !value.contains('.'))
                                    ? 'Invalid Email'
                                    : null;
                              },
                              decoration: InputDecoration(
                                hintText: "Email",
                                hintStyle: TextStyle(
                                    color: Colors.grey, letterSpacing: 1.0),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      top: 16, bottom: 16, left: 9)),
                              isExpanded: true,
                              iconEnabledColor: Colors.grey,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18),
                              iconSize: 30,
                              elevation: 9,
                              value: selectedArea,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedArea = newValue;
                                });
                              },
                              items: <String>['Hyderabad', 'Test', 'Test2']
                                  .map<DropdownMenuItem<String>>((e) {
                                return DropdownMenuItem<String>(
                                    value: e,
                                    child: Text(
                                      e.toString(),
                                    ));
                              }).toList()),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey[300]),
                                    top: BorderSide(color: Colors.grey[300]))),
                            child: TextFormField(
                              onChanged: (value) => password = value,
                              validator: (value) {
                                return (value.isEmpty || value.length < 6)
                                    ? 'Invalid Password'
                                    : null;
                              },
                              style: TextStyle(letterSpacing: 1.5),
                              obscureText: hidePassword,
                              decoration: InputDecoration(
                                  hintText: "Password",
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.remove_red_eye,
                                        color: Colors.deepOrangeAccent),
                                    onPressed: () {
                                      setState(() {
                                        hidePassword = !hidePassword;
                                      });
                                    },
                                  ),
                                  hintStyle: TextStyle(
                                      color: Colors.grey, letterSpacing: 1.0),
                                  border: InputBorder.none),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[200]))),
                            child: TextFormField(
                              onChanged: (value) => passwordClone = value,
                              validator: (value) {
                                return ((value.isEmpty ||
                                        value.length < 6 ||
                                        value != password))
                                    ? 'Invalid Password'
                                    : null;
                              },
                              style: TextStyle(letterSpacing: 1.5),
                              obscureText: hidePassword,
                              decoration: InputDecoration(
                                  hintText: "Re-Enter Password",
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.remove_red_eye,
                                        color: Colors.deepOrangeAccent),
                                    onPressed: () {
                                      setState(() {
                                        hidePassword = !hidePassword;
                                      });
                                    },
                                  ),
                                  hintStyle: TextStyle(
                                      color: Colors.grey, letterSpacing: 1.0),
                                  border: InputBorder.none),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                      onTap: () async {
                        if (_formKey.currentState.validate()) {
                          signUp();
                        }
                      },
                      title: Center(
                          child: Container(
                        padding: EdgeInsets.all(18),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(27),
                            color: Colors.deepOrange),
                        child: Text(
                          'Register',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ))),
                  ListTile(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      title: Center(
                        child: Text(
                          'Already have an Account ?',
                          style: TextStyle(color: Colors.grey.shade900),
                        ),
                      ))
                ],
              ),
      ),
    );
  }

  signUp() async {
    setState(() {
      loading = true;
    });
    FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      final usersRef =
          Firestore.instance.collection('Users').document(result.user.uid);
      await usersRef.setData({
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'area': selectedArea,
        'dob': _dateTime,
        'imageUrl': 'null'
      });
      SharedPreferences _pref = await SharedPreferences.getInstance();
      _pref.setString('UID', result.user.uid);
      _messaging.subscribeToTopic(result.user.uid);
      Notifications().pushNotification('New Member',
          '$firstName $lastName has joined the community', 'admin');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
        return MainPage(uid: result.user.uid);
      }));
    } catch (e) {
      setState(() {
        loading = false;
        Fluttertoast.showToast(msg: e.toString());
      });
    }
  }
}
