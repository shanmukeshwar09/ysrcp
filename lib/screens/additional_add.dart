import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ysrcp/screens/full_screen.dart';
import 'package:ysrcp/screens/profile_screen.dart';
import 'package:ysrcp/service/notifications.dart';

class AdditionalAdd extends StatefulWidget {
  final DocumentSnapshot snap;

  const AdditionalAdd({Key key, this.snap}) : super(key: key);
  @override
  _AdditionalAddState createState() => _AdditionalAddState();
}

class _AdditionalAddState extends State<AdditionalAdd> {
  Firestore _firestore = Firestore.instance;
  Set selection = {};
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.deepOrange,
        appBar: selection.length > 0
            ? AppBar(
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      selection.clear();
                    });
                  },
                ),
                actions: <Widget>[
                    Center(
                      child: Text(
                        selection.length.toString(),
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 18),
                    Center(
                        child: FlatButton(
                            child: Text('Done',
                                style: TextStyle(
                                    fontSize: 21,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            onPressed: () => assignWork())),
                    SizedBox(width: 18),
                  ])
            : AppBar(
                title: Text('Members', style: TextStyle(fontSize: 25)),
                centerTitle: true,
                elevation: 0,
              ),
        body: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30), topLeft: Radius.circular(30)),
              color: Colors.white),
          child: loading
              ? Center(child: CircularProgressIndicator())
              : StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('Users').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.documents.length == 0) {
                        return Center(child: Text('No users Yet'));
                      } else {
                        return ListView.builder(
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (_, index) {
                              return Container(
                                margin: EdgeInsets.all(9),
                                padding: EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color: selection.contains(snapshot
                                            .data.documents[index].documentID)
                                        ? Colors.orange.withOpacity(0.3)
                                        : Colors.grey.shade100),
                                child: ListTile(
                                  onLongPress: () {
                                    setState(() {
                                      if (selection.contains(snapshot
                                          .data.documents[index].documentID)) {
                                        selection.remove(snapshot
                                            .data.documents[index].documentID);
                                      } else {
                                        selection.add(snapshot
                                            .data.documents[index].documentID);
                                      }
                                    });
                                  },
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ProfileScreen(
                                              snapshot: snapshot
                                                  .data.documents[index]))),
                                  leading: GestureDetector(
                                    onTap: () {
                                      if (snapshot.data.documents[index]
                                              ['imageUrl'] !=
                                          'null') {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    FullScreenImageView(
                                                        url: snapshot.data
                                                                .documents[index]
                                                            ['imageUrl'])));
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: 'No profile picture');
                                      }
                                    },
                                    child: CircleAvatar(
                                      maxRadius: 27,
                                      minRadius: 27,
                                      backgroundColor: Colors.white,
                                      backgroundImage:
                                          snapshot.data.documents[index]
                                                      ['imageUrl'] ==
                                                  'null'
                                              ? AssetImage(
                                                  'assets/circular_avatar.png')
                                              : CachedNetworkImageProvider(
                                                  snapshot.data.documents[index]
                                                      ['imageUrl'],
                                                ),
                                    ),
                                  ),
                                  title: Text(
                                      '${snapshot.data.documents[index]['first_name']} ${snapshot.data.documents[index]['last_name']}'),
                                  subtitle: Text(
                                      '${snapshot.data.documents[index]['area']}'),
                                ),
                              );
                            });
                      }
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
        ));
  }

  assignWork() {
    setState(() {
      loading = true;
    });
    selection.forEach((element) async {
      final docId = DateTime.now().millisecondsSinceEpoch.toString();
      await _firestore.collection('pending').document(docId).setData({
        'channel_name': widget.snap.data['channel_name'],
        'date': widget.snap.data['date'],
        'agenda': widget.snap.data['agenda'],
        'uid': element,
        'status': 'pending'
      }).whenComplete(() {
        _firestore
            .collection('Users')
            .document(element)
            .collection('pending')
            .document(docId)
            .setData({
          'status': 'pending',
          'channel_name': widget.snap.data['channel_name'],
          'date': widget.snap.data['date'],
          'agenda': widget.snap.data['agenda'],
        });
      }).whenComplete(() {
        Notifications().pushNotification(
            'new meeting', widget.snap.data['agenda'], element);
      });
      Fluttertoast.showToast(msg: 'Done !');
      Navigator.pop(context);
    });
  }
}
