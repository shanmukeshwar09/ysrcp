import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ysrcp/screens/main_page.dart';
import 'package:ysrcp/screens/signin.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pref = await SharedPreferences.getInstance();

  runApp(MyApp(
    uid: pref.getString('UID'),
  ));
}

class MyApp extends StatelessWidget {
  final uid;

  const MyApp({Key key, this.uid}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return MaterialApp(
      home: uid == null ? SignIn() : MainPage(uid: uid),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
