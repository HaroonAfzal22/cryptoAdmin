import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_admin/screens/CryptoScreens/add_crypto_screen.dart';
import 'package:crypto_admin/screens/CryptoScreens/crypto_update_screen.dart';
import 'package:crypto_admin/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

class CryptoListScreen extends StatefulWidget {
  static String id = 'Crypto_list_Screen';
  CryptoListScreen({
    Key? key,
  }) : super(key: key);

  @override
  _CryptoListScreenState createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Stream<QuerySnapshot> cryptoStream =
      FirebaseFirestore.instance.collection('Crypto').snapshots();
  FirebaseStorage storage = FirebaseStorage.instance;

  // For Deleting User
  CollectionReference crypto = FirebaseFirestore.instance.collection('Crypto');

  Future<void> deleteCrypto(id, cryptoImage) {
    print("Crypto Deleted $id");
    print(cryptoImage);
    return crypto
        .doc(id)
        .delete()
        .then(
          (value) => {
            print('Crypto Deleted'),
            storage.refFromURL(cryptoImage).delete(),
          },
        )
        .catchError((error) => print('Failed to Delete Crypto: $error'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Center(child: Text(' Crypto List')),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'LogOut',
            onPressed: () => {
              _auth.signOut(),
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false),
            },
          ),
        ],
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: cryptoStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final List storedocs = [];
            snapshot.data!.docs.map((DocumentSnapshot document) {
              Map a = document.data() as Map<String, dynamic>;
              storedocs.add(a);
              a['id'] = document.id;
              a['cryptoImage'] = document['cryptoImage'];
            }).toList();

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: const <int, TableColumnWidth>{
                    1: FixedColumnWidth(50),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            color: Colors.greenAccent,
                            child: const Center(
                              child: Text(
                                'Name',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            color: Colors.greenAccent,
                            child: const Center(
                              child: Text(
                                'price',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            color: Colors.greenAccent,
                            child: const Center(
                              child: Text(
                                'Image',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            color: Colors.greenAccent,
                            child: const Center(
                              child: Text(
                                'Action',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    for (var i = 0; i < storedocs.length; i++) ...[
                      TableRow(
                        children: [
                          TableCell(
                            child: Center(
                                child: Text(storedocs[i]['cryptoName'],
                                    style: TextStyle(fontSize: 18.0))),
                          ),
                          TableCell(
                            child: Center(
                                child: Text(storedocs[i]['cryptoPrice'],
                                    style: TextStyle(fontSize: 18.0))),
                          ),
                          TableCell(
                            child: SizedBox(
                              height: 100,
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: storedocs[i]['cryptoImage'],
                                placeholder: (context, url) =>
                                    Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                              // Image.network(
                              //   storedocs[i]['roomImage'],
                              //   fit: BoxFit.cover,
                              // ),
                            ),
                          ),
                          TableCell(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UpdateCryptoScreen(
                                                id: storedocs[i]['id']),
                                      ),
                                    )
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    // Validate returns true if the form is valid, otherwise false.

                                    setState(() {
                                      deleteCrypto(storedocs[i]['id'],
                                          storedocs[i]['cryptoImage']);
                                    });
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddCryptoScreen.id);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
