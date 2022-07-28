import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_admin/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AddBanners extends StatefulWidget {
  static String id = 'AddBanner_Screen';
  AddBanners({Key? key}) : super(key: key);

  @override
  _AddBannersState createState() => _AddBannersState();
}

class _AddBannersState extends State<AddBanners> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  var isProcessing = false;
  var isPictureSelected = false;
  var bannerName = "";
  late File imageFile;
  String imageUrl = '';
  String fileName = '';
  PickedFile? pickedImage;
  // Create a text controller and use it to retrieve the current value
  // of the TextField.

  final bannerNameController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    bannerNameController.dispose();
    super.dispose();
  }

  clearText() {
    bannerNameController.clear();
  }

  // Adding Banner
  CollectionReference banner = FirebaseFirestore.instance.collection('Banners');

  Future<void> addBanner() {
    return banner
        .add(
          {
            'BannerName': bannerName,
            'BannerImage': imageUrl,
          },
        )
        .then((value) => {
              print('Banner Added'),
              setState(() {
                isPictureSelected = false;
                isProcessing = false;
                clearText();
                imageFile = File('');
                fileName = '';
                imageUrl = '';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Banner added Successfuly'),
                  ),
                );
              }),
            })
        .catchError((error) => print('Failed to Add Banner: $error'));
  }

  // Upload image
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> _selectPicture(String inputSource) async {
    final picker = ImagePicker();

    pickedImage = await picker.getImage(
        source:
            inputSource == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1920);

    fileName = path.basename(pickedImage!.path);
    imageFile = File(pickedImage!.path);
    setState(() {
      isPictureSelected = true;
    });
  }

  void uploadPicture() {
    try {
      // Uploading the selected image with some custom meta data
      Reference ref = storage.ref('BannerImages/$fileName');
      UploadTask uploadTask = ref.putFile(
          imageFile,
          SettableMetadata(customMetadata: {
            'uploaded_by': 'A bad guy',
            'description': 'Some description...'
          }));
      uploadTask.then((value) async {
        var url = await value.ref.getDownloadURL();
        imageUrl = url.toString();
        addBanner();
      });

      // Refresh the UI
      setState(() {
        if (pickedImage != null) {
          imageFile = File(pickedImage!.path);
        } else {
          print('No image selected.');
        }
      });
    } on FirebaseException catch (error) {
      print(error);
    }
  }

  Future<List<Map<String, dynamic>>> _loadImages() async {
    List<Map<String, dynamic>> files = [];

    final ListResult result = await storage.ref().list();
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final String fileUrl = await file.getDownloadURL();
      final FullMetadata fileMeta = await file.getMetadata();
      files.add({
        "url": fileUrl,
        "path": file.fullPath,
        "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'Nobody',
        "description":
            fileMeta.customMetadata?['description'] ?? 'No description'
      });
    });

    return files;
  }

  //Delete Image

  Future<void> _delete(String ref) async {
    await storage.ref(ref).delete();
    // Rebuild the UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Banners"),
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
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: ListView(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: TextFormField(
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: 'Banner Name: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle:
                        TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  controller: bannerNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Banner Name';
                    }
                    return null;
                  },
                ),
              ),
              isPictureSelected
                  ? Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 100,
                        width: 100,
                        child: Image.file(imageFile),
                      ),
                    )
                  : SizedBox.shrink(),
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black38),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ElevatedButton.icon(
                    //     onPressed: () => _selectPicture('camera'),
                    //     icon: Icon(Icons.camera),
                    //     label: Text('camera')),
                    // SizedBox(
                    //   width: 20,
                    // ),
                    ElevatedButton.icon(
                        onPressed: () => _selectPicture('gallery'),
                        icon: Icon(Icons.library_add),
                        label: Text('Gallery')),
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (fileName != '') {
                            setState(() {
                              isProcessing = true;
                              bannerName = bannerNameController.text;

                              uploadPicture();
                              Navigator.pop(context);
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please add image'),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        'Add',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => {
                        clearText(),
                        setState(() {
                          isPictureSelected = false;
                          imageFile = File('');
                          fileName = '';
                          imageUrl = '';
                        }),
                      },
                      child: Text(
                        'Clear',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      style: ElevatedButton.styleFrom(primary: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              isProcessing
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
