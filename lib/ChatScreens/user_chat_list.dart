import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_admin/ChatScreens/type_chat_screen.dart';
import 'package:crypto_admin/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:rxdart/rxdart.dart';

class UserChatListScreen extends StatefulWidget {
  static String id = 'UserChat_Screen';
  const UserChatListScreen({Key? key}) : super(key: key);

  @override
  State<UserChatListScreen> createState() => _UserChatListScreenState();
}

class _UserChatListScreenState extends State<UserChatListScreen> {
  String? userDocName;
  String? userDocPhone;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;

  // final mergedStream = MergeStream([
  //   FirebaseFirestore.instance.collection('UserInfo').snapshots(),
  //   FirebaseFirestore.instance.collection('UsersMessage').snapshots()
  // ]);

  var loggedinUser;
  var collectionStrem;
  //

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

  /////
  Future UserInfoData() async {
    await for (collectionStrem
        in _fireStore.collection('UserInfo').snapshots()) {
      devtools.log('All document  ${collectionStrem.docs}');

      for (var docsStream in collectionStrem.docs) {
        if (docsStream.data().containsValue(loggedinUser!.email.toString())) {
          userDocName = docsStream.data()['Name'];
          userDocPhone = docsStream.data()['Phone'];
          // devtools.log('User info data : ${docsStream.data()['Name']}');
          // devtools.log('User info data : ${docsStream.data()['Phone']}');
          return;
        } else {
          devtools.log('No Match');
        }
      }
    }
    return;
  }

  ///-------////
  @override
  void initState() {
    getCurrentUser();
    // UserInfoData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User\'s Chat',
        ),
        centerTitle: true,
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
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          StreamBuilder(
            stream: _fireStore.collection('user').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    // reverse: true,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String Useremail;
                      // userInfoMap!.forEach(
                      //   (key, value) {
                      //     print('{ key: $key, value: $value }');
                      //   },
                      // );

                      return GestureDetector(
                        onTap: () {
                          devtools.log('Documents id printing ${document.id}');

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TypeChatScreen(
                                      userId: data['uid'],
                                      userEmail: data['email'],
                                      userName: data['firstName'],
                                      // userPhone: data['UserPhone'] ?? '0300',
                                    )),
                          );
                        },
                        child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            decoration: containerDecoration,
                            child: Row(
                              children: [
                                Text(
                                  data['firstName'] ?? 'data not found',
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text(data['email']),
                              ],
                            )),
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
        ],
      ),
    );
  }
}

final containerDecoration = BoxDecoration(
    color: Color.fromARGB(255, 168, 209, 229),
    borderRadius: BorderRadius.circular(10));
