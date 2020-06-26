import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ysrcp/screens/full_screen.dart';

class ProfileScreen extends StatefulWidget {
  final DocumentSnapshot snapshot;

  const ProfileScreen({Key key, this.snapshot}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: Text(
            'Profile Screen',
            style: TextStyle(fontSize: 25),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 18, left: 10),
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () async {
                        if (widget.snapshot.data['imageUrl'] != 'null') {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return FullScreenImageView(
                              url: widget.snapshot.data['imageUrl'],
                            );
                          }));
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage:
                            (widget.snapshot.data['imageUrl'] == 'null')
                                ? AssetImage('assets/circular_avatar.png')
                                : CachedNetworkImageProvider(
                                    widget.snapshot.data['imageUrl']),
                        minRadius: 50,
                        maxRadius: 50,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 18,
              ),
              getApproprateTile(
                  widget.snapshot.data['first_name'], 'First Name'),
              getApproprateTile(widget.snapshot.data['last_name'], 'Last Name'),
              getApproprateTile(widget.snapshot.data['dob'], 'Date Of Birth'),
              getApproprateTile(widget.snapshot.data['phone'], 'Phone'),
              getApproprateTile(widget.snapshot.data['area'], 'Area'),
              getApproprateTile(widget.snapshot.data['email'], 'Email'),
            ]))));
  }

  getApproprateTile(String title, String trailing) {
    return Container(
        margin: EdgeInsets.all(9),
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(25)),
        child: ListTile(
          title: Text(title, style: TextStyle(color: Colors.grey.shade700)),
          trailing: Text(trailing , style: TextStyle(color: Colors.grey.shade500))
        ));
  }
}
