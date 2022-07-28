import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_admin/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:crypto_admin/constants.dart';
import 'dart:developer' as devtools show log;

class TypeChatScreen extends StatefulWidget {
  static String id = 'Chat_Screen';
  String? userId;
  String? userName;
  String? userPhone;
  String? userEmail;
  TypeChatScreen({this.userId, this.userEmail, this.userName, this.userPhone});
  @override
  _TypeChatScreenState createState() => _TypeChatScreenState();
}

class _TypeChatScreenState extends State<TypeChatScreen> {
  final messageController = TextEditingController();
  List? messageWidgetList;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  var loggedinUser;
  var messageText;

  getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedinUser = user;
        devtools.log(loggedinUser!.email);
      }
    } on Exception catch (e) {
      devtools.log('Error comming from getuserfunction chat screen $e');
      // TODO
    }
  }

  // get streaam data from firstore
  void chatMessages() async {
    await for (var collectionStrem in _fireStore
        .collection('user')
        .doc(widget.userId)
        .collection('UsersChat')
        .get()
        .asStream()) {
      devtools.log('First loop ${collectionStrem.docs}');
      for (var docsStream in collectionStrem.docs) {
        // messageWidgetList!.add(docsStream.data());
        devtools.log('Second Loop dos $docsStream');
      }
    }
  }

  @override
  void initState() {
    getCurrentUser();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                //Implement logout functionality

                _auth.signOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false);
              }),
        ],
        title: Center(
          child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("User Information"),
                    content: Container(
                      height: 100,
                      child: Column(
                        children: [
                          CustomDialogWidget(
                            widget: widget,
                            nameKey: 'Name',
                            nameValue: '${widget.userName}',
                          ),
                          CustomDialogWidget(
                            widget: widget,
                            nameKey: 'Phone',
                            nameValue: '${widget.userPhone}',
                          ),
                          CustomDialogWidget(
                            widget: widget,
                            nameKey: 'Email',
                            nameValue: '${widget.userEmail}',
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: const Text("Close"),
                      ),
                    ],
                  ),
                );
              },
              child: Text(widget.userName ?? '⚡️Chat')),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder(
              stream: _fireStore
                  .collection('user')
                  .doc(widget.userId)
                  .collection('UsersChat')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: ListView(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      reverse: true,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: snapshot.data!.docs.reversed
                          .map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;

                        return MessageBubble(
                          isME: loggedinUser.email == data['sender'],
                          userEmail: data['sender'],
                          userText: data['text'],
                        );
                      }).toList(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                return Text("Loading");
              },
            ),
            Container(
              decoration: kMessagertContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration.copyWith(
                          hintText: 'Type you\'r message here...'),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      try {
                        messageController.clear();
                        devtools.log(
                            'message: $messageText user:${loggedinUser.email}');
                        stream:
                        _fireStore
                            .collection('user')
                            .doc(widget.userId)
                            .collection('UsersChat')
                            .add({
                          'sender': loggedinUser.email,
                          'text': messageText,
                        });
                      } on Exception catch (e) {
                        devtools.log('Exception from fireStore $e');
                        // TODO
                      }
                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDialogWidget extends StatelessWidget {
  CustomDialogWidget(
      {required this.widget, required this.nameKey, required this.nameValue});
  String nameKey;
  String nameValue;
  final TypeChatScreen widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text('$nameKey:'),
        SizedBox(
          width: 20,
        ),
        Text(nameValue)
      ],
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {required this.userEmail, required this.userText, required this.isME});
  String userText;
  String userEmail;
  bool isME;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isME ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(userEmail,
              style: TextStyle(color: Colors.black54, fontSize: 12)),
          Material(
            borderRadius: isME
                ? BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  )
                : BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
            elevation: 5,
            color: isME ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                userText,
                style: TextStyle(
                    color: isME ? Colors.white : Colors.black54, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
