import 'package:crypto_admin/ChatScreens/user_chat_list.dart';
import 'package:crypto_admin/screens/Banner/banner_list_screen.dart';
import 'package:crypto_admin/screens/CryptoScreens/crypto_list_screen.dart';
import 'package:crypto_admin/ChatScreens/type_chat_screen.dart';
import 'package:crypto_admin/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminPanelScreen extends StatefulWidget {
  static String id = 'Main_Screen';
  AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('Admin Panel'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                _auth.signOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false);
              }),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomCardWidget(
            cardIcon: Icons.branding_watermark_outlined,
            cardOnPressed: () {
              Navigator.pushNamed(context, BannerListScreen.id);
            },
            title: 'Banners Managemet',
          ),
          CustomCardWidget(
            cardIcon: Icons.currency_bitcoin_sharp,
            cardOnPressed: () {
              Navigator.pushNamed(context, CryptoListScreen.id);
            },
            title: 'Crypto Management',
          ),
          CustomCardWidget(
            cardIcon: Icons.chat,
            cardOnPressed: () {
              Navigator.pushNamed(context, UserChatListScreen.id);
            },
            title: 'Chat with user ',
          ),
        ],
      ),
    );
  }
}

class CustomCardWidget extends StatelessWidget {
  CustomCardWidget(
      {required this.cardOnPressed,
      required this.title,
      required this.cardIcon});
  String title;
  VoidCallback cardOnPressed;
  IconData cardIcon;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 20,
        color: Colors.grey[600],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          overlayColor: MaterialStateProperty.all(Colors.black38),
          onTap: cardOnPressed,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cardIcon, color: Colors.white),
                SizedBox(
                  width: 20,
                ),
                Text(title,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
