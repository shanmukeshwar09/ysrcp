import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ysrcp/screens/main_page.dart';
import 'package:ysrcp/screens/signup.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String email = '';
  String password = '';
  bool hidePassword = true;
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      appBar: AppBar(
        title: Text(
          'Login',
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
                    margin: EdgeInsets.all(27),
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
                              onChanged: (value) {
                                email = value;
                              },
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
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: Colors.grey[200]))),
                            child: TextFormField(
                              onChanged: (value) {
                                password = value;
                              },
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
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        'Forgot Password',
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 18),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState.validate()) {
                            signIn();
                          }
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.deepOrange),
                          child: Text(
                            'Login',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return SignUp();
                        }));
                      },
                      title: Container(
                        margin: EdgeInsets.only(top: 30),
                        alignment: Alignment.center,
                        child: Text(
                          'Dont have an Account ?',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      )),
                  ListTile(
                      title: Center(
                    child: Text(
                      error,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  )),
                ],
              ),
      ),
    );
  }

  signIn() async {
    setState(() {
      loading = true;
    });
    FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      SharedPreferences _pref = await SharedPreferences.getInstance();
      _pref.setString('UID', result.user.uid);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
        return MainPage(uid: result.user.uid);
      }));
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }
}