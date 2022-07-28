import 'dart:core';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_admin/screens/Banner/add_bannes_screen.dart';
import 'package:crypto_admin/screens/Banner/updateBanner_screen.dart';
import 'package:crypto_admin/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class BannerListScreen extends StatefulWidget {
  static String id = 'BannerCrud_Screen';
  BannerListScreen({
    Key? key,
  }) : super(key: key);

  @override
  _BannerListScreenState createState() => _BannerListScreenState();
}

class _BannerListScreenState extends State<BannerListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Stream<QuerySnapshot> bannerStream =
      FirebaseFirestore.instance.collection('Banners').snapshots();
  FirebaseStorage storage = FirebaseStorage.instance;

  // For Deleting User
  CollectionReference banner = FirebaseFirestore.instance.collection('Banners');

  Future<void> deleteBanner(id, bannerImage) {
    print("Banner Deleted $id");
    print(bannerImage);
    return banner
        .doc(id)
        .delete()
        .then(
          (value) => {
            print('banner Deleted'),
            storage.refFromURL(bannerImage).delete(),
          },
        )
        .catchError((error) => print('Failed to Delete banner: $error'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Banner\'s List')),
        backgroundColor: Colors.blueGrey,
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
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: bannerStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final List storedocs = [];

            snapshot.data!.docs.map((DocumentSnapshot document) {
              Map a = document.data() as Map<String, dynamic>;

              storedocs.add(a);

              a['id'] = document.id;
              a['BannerImage'] = document['BannerImage'];
            }).toList();

            return Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
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
                                'Title',
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
                            child: SizedBox(
                              height: 60,
                              child: Center(
                                  child: Text(storedocs[i]['BannerName'] ?? '',
                                      style: const TextStyle(fontSize: 18.0))),
                            ),
                          ),
                          TableCell(
                            child: SizedBox(
                              height: 60,
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl:
                                    storedocs[i]['BannerImage'] ?? 'Image',
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
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
                                            UpdateBannerScreen(
                                                id: storedocs[i]['id']),
                                      ),
                                    )
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    // Validate returns true if the form is valid, otherwise false.

                                    setState(() {
                                      deleteBanner(storedocs[i]['id'],
                                          storedocs[i]['BannerImage']);
                                    });
                                  },
                                  icon: const Icon(
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
          Navigator.pushNamed(context, AddBanners.id);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
