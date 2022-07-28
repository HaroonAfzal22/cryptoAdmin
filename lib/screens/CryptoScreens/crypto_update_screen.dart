import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_admin/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class UpdateCryptoScreen extends StatefulWidget {
  final String id;
  UpdateCryptoScreen({Key? key, required this.id}) : super(key: key);

  @override
  _UpdateCryptoScreenState createState() => _UpdateCryptoScreenState();
}

class _UpdateCryptoScreenState extends State<UpdateCryptoScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  String imageUrl = '';
  String cryptoImage = '';

  // Updaing Food Items
  CollectionReference crypto = FirebaseFirestore.instance.collection('Crypto');

  Future<void> updateCrypto(id, cryptoName, cryptoPrice, cryptoImage) {
    if (_imageFile != null) {
      cryptoImage = imageUrl;
    }
    return crypto
        .doc(id)
        .update({
          'cryptoName': cryptoName,
          'cryptoPrice': cryptoPrice,
          'cryptoImage': cryptoImage,
        })
        .then((value) => print("Crypto Added Successfuly"))
        .catchError((error) => print("Failed to update Crypto: $error"));
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Upadte Crypto'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  String fileName = '';
  _imgFromCamera() async {
    var image = await ImagePicker.platform
        .pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _imageFile = File(image!.path);
      fileName = path.basename(image.path);
      storage.refFromURL(cryptoImage).delete();
      _upload();
    });
  }

  _imgFromGallery() async {
    var image = await ImagePicker.platform
        .pickImage(source: ImageSource.gallery, imageQuality: 50);
    // final ImagePicker _picker = ImagePicker();
    // final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(image!.path);
      fileName = path.basename(image.path);
      storage.refFromURL(cryptoImage).delete();
      _upload();
    });
  }

  // Upload image
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> _upload() async {
    try {
      // Uploading the selected image with some custom meta data
      Reference ref = storage.ref('CryptoImages/$fileName');
      UploadTask uploadTask = ref.putFile(
          _imageFile!,
          SettableMetadata(customMetadata: {
            'uploaded_by': 'A bad guy',
            'description': 'Some description...'
          }));
      uploadTask.then((value) async {
        var url = await value.ref.getDownloadURL();
        imageUrl = url.toString();
      });

      // Refresh the UI

    } on FirebaseException catch (error) {
      print(error);
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Crypto "),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'LogOut',
            onPressed: () => {
              _auth.signOut(),
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false)
            },
          ),
        ],
        backgroundColor: Colors.blueGrey,
      ),
      body: Form(
          key: _formKey,
          // Getting Specific Data by ID
          child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('Crypto')
                .doc(widget.id)
                .get(),
            builder: (_, snapshot) {
              if (snapshot.hasError) {
                print('Something Went Wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              var data = snapshot.data!.data();
              var cryptoName = data!['cryptoName'];
              var cryptoPrice = data['cryptoPrice'];

              cryptoImage = data['cryptoImage'];

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      child: GestureDetector(
                        onTap: () {
                          _showPicker(context);
                        },
                        child: ClipRRect(
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: cryptoImage,
                            placeholder: (context, url) =>
                                Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          // Image.network(
                          //   roomImage,
                          //   fit: BoxFit.cover,
                          // ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10.0),
                            child: TextFormField(
                              initialValue: cryptoName,
                              autofocus: false,
                              onChanged: (value) => cryptoName = value,
                              decoration: InputDecoration(
                                labelText: ' Name: ',
                                labelStyle: TextStyle(fontSize: 20.0),
                                border: OutlineInputBorder(),
                                errorStyle: TextStyle(
                                    color: Colors.redAccent, fontSize: 15),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Crypto Name';
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10.0),
                            child: TextFormField(
                              initialValue: cryptoPrice,
                              autofocus: false,
                              onChanged: (value) => cryptoPrice = value,
                              decoration: InputDecoration(
                                labelText: 'Crypto Price: ',
                                labelStyle: TextStyle(fontSize: 20.0),
                                border: OutlineInputBorder(),
                                errorStyle: TextStyle(
                                    color: Colors.redAccent, fontSize: 15),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Crypto Price';
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Validate returns true if the form is valid, otherwise false.
                                    if (_formKey.currentState!.validate()) {
                                      updateCrypto(widget.id, cryptoName,
                                          cryptoPrice, cryptoImage);
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text(
                                    'Update',
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => {},
                                  child: Text(
                                    'Reset',
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.blueGrey),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }, // snapshot
          )),
    );
  }
}
