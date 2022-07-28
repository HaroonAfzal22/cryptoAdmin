import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_admin/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AddCryptoScreen extends StatefulWidget {
  static String id = 'Add_crypto_Screen';
  AddCryptoScreen({Key? key}) : super(key: key);

  @override
  _AddCryptoScreenState createState() => _AddCryptoScreenState();
}

class _AddCryptoScreenState extends State<AddCryptoScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  var isProcessing = false;
  var isPictureSelected = false;
  var cryptoName = "";
  var cryptoPrice = "";

  late File imageFile;
  String imageUrl = '';
  String fileName = '';
  PickedFile? pickedImage;
  // Create a text controller and use it to retrieve the current value
  // of the TextField.

  final cryptoNameController = TextEditingController();
  final cryptoPriceController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    cryptoNameController.dispose();
    cryptoPriceController.dispose();

    super.dispose();
  }

  clearText() {
    cryptoNameController.clear();
    cryptoPriceController.clear();
  }

  // Adding Student
  CollectionReference crypto = FirebaseFirestore.instance.collection('Crypto');

  Future<void> addCrypto() {
    return crypto
        .add(
          {
            'cryptoName': cryptoName,
            'cryptoPrice': cryptoPrice,
            'cryptoImage': imageUrl,
          },
        )
        .then((value) => {
              print('crypto Added'),
              setState(() {
                isPictureSelected = false;
                isProcessing = false;
                clearText();
                imageFile = File('');
                fileName = '';
                imageUrl = '';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Crypto  Added'),
                  ),
                );
              }),
            })
        .catchError((error) => print('Failed to Add Crypto: $error'));
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
      Reference ref = storage.ref('CryptoImages/$fileName');
      UploadTask uploadTask = ref.putFile(
          imageFile,
          SettableMetadata(customMetadata: {
            'uploaded_by': 'A bad guy',
            'description': 'Some description...'
          }));
      uploadTask.then((value) async {
        var url = await value.ref.getDownloadURL();
        imageUrl = url.toString();
        addCrypto();
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
        centerTitle: true,
        title: Text("Add Crypto"),
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
                    labelText: 'Crypto Name: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle:
                        TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  controller: cryptoNameController,
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
                  autofocus: false,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Crypto Price: ',
                    labelStyle: TextStyle(fontSize: 20.0),
                    border: OutlineInputBorder(),
                    errorStyle:
                        TextStyle(color: Colors.redAccent, fontSize: 15),
                  ),
                  controller: cryptoPriceController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Crypto Price';
                      // } else if (!value.contains('@')) {
                      //   return 'Please Enter Valid Email';
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
                        // Validate returns true if the form is valid, otherwise false.
                        if (_formKey.currentState!.validate()) {
                          if (fileName != '') {
                            setState(() {
                              isProcessing = true;
                              cryptoName = cryptoNameController.text;
                              cryptoPrice = cryptoPriceController.text;

                              uploadPicture();
                              Navigator.pop(context);
                              //clearText();
                              //_loadImages();
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
