import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_admin/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class UpdateBannerScreen extends StatefulWidget {
  final String id;
  UpdateBannerScreen({Key? key, required this.id}) : super(key: key);

  @override
  _UpdateBannerScreenState createState() => _UpdateBannerScreenState();
}

class _UpdateBannerScreenState extends State<UpdateBannerScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  String imageUrl = '';
  String BannerImage = '';

  // Updaing Food Items
  CollectionReference Rooms = FirebaseFirestore.instance.collection('Banners');

  Future<void> updateBanner(id, BannerName, BannerImage) {
    if (_imageFile != null) {
      BannerImage = imageUrl;
    }
    return Rooms.doc(id)
        .update({
          'BannerName': BannerName,
          'BannerImage': BannerImage,
        })
        .then((value) => print("Banner Updated"))
        .catchError((error) => print("Failed to update Banner: $error"));
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
                      title: new Text('Photo Library'),
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
      storage.refFromURL(BannerImage).delete();
      _upload();
    });
  }

  _imgFromGallery() async {
    var image = await ImagePicker.platform
        .pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _imageFile = File(image!.path);
      fileName = path.basename(image.path);
      storage.refFromURL(BannerImage).delete();
      _upload();
    });
  }

  // Upload image
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> _upload() async {
    try {
      // Uploading the selected image with some custom meta data
      Reference ref = storage.ref('BannerImages/$fileName');
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
        title: Text("Update Rooms "),
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
                  }),
        ],
        backgroundColor: Colors.blueGrey,
      ),
      body: Form(
          key: _formKey,
          // Getting Specific Data by ID
          child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('Banners')
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
              var BannerName = data!['BannerName'];
              BannerImage = data['BannerImage'];

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
                            imageUrl: BannerImage,
                            placeholder: (context, url) =>
                                Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
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
                              initialValue: BannerName,
                              autofocus: false,
                              onChanged: (value) => BannerName = value,
                              decoration: InputDecoration(
                                labelText: 'Banner Name: ',
                                labelStyle: TextStyle(fontSize: 20.0),
                                border: OutlineInputBorder(),
                                errorStyle: TextStyle(
                                    color: Colors.redAccent, fontSize: 15),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Room Name';
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
                                      updateBanner(
                                          widget.id, BannerName, BannerImage);
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
