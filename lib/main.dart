import 'package:crypto_admin/ChatScreens/user_chat_list.dart';
import 'package:crypto_admin/Services/local_notification.dart';
import 'package:crypto_admin/firebase_options.dart';
import 'package:crypto_admin/screens/Banner/add_bannes_screen.dart';
import 'package:crypto_admin/screens/Banner/banner_list_screen.dart';
import 'package:crypto_admin/screens/Banner/admin_panel_screen.dart';
import 'package:crypto_admin/screens/CryptoScreens/add_crypto_screen.dart';
import 'package:crypto_admin/screens/CryptoScreens/crypto_list_screen.dart';
import 'package:crypto_admin/ChatScreens/type_chat_screen.dart';
import 'package:crypto_admin/screens/login_screen.dart';
import 'package:crypto_admin/screens/register_screen.dart';
import 'package:crypto_admin/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

Future<void> background(RemoteMessage remotevent) async {
  if (remotevent.notification != null) {
    devtools.log(
        'Notification body from outside of App: ${remotevent.notification!.body}');
    devtools.log(
        'Notification title from outside of App: ${remotevent.notification!.title}');
  }
}

void main() async {


  WidgetsFlutterBinding.ensureInitialized();
  LocalNotificationClass.initializeFun();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(background);
  runApp(CryptoAdminApp());
}

class CryptoAdminApp extends StatefulWidget {
  @override
  State<CryptoAdminApp> createState() => _CryptoAdminAppState();
}

class _CryptoAdminAppState extends State<CryptoAdminApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

// gives you the message on which user tap
// and it open app from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((event) {
      if (event != null) {
        final routefromNotification = event.data['route'];
        devtools.log(
            'Notification route data when app is Closed:  ${routefromNotification}');
      }
    });

// forground work
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        devtools.log(
            'Notification body from forbacground services of App: ${message.notification!.body}');
        devtools.log(
            'Notification title from forbacground servicesoutside of App: ${message.notification!.title}');
      } else {
        LocalNotificationClass.display(message);
      }
    });

    // when app is in bacground but not closed
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      final routefromNotification = event.data['route'];
      // Navigator.pushNamed(context, routefromNotification);

      devtools.log(
          'Notification route data when app is minimized:  ${routefromNotification}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        AdminPanelScreen.id: (context) => AdminPanelScreen(),
        UserChatListScreen.id : (context)=> UserChatListScreen(),
        BannerListScreen.id: (context) => BannerListScreen(),
        AddCryptoScreen.id: (context) => AddCryptoScreen(),
        AddBanners.id: (context) => AddBanners(),
        CryptoListScreen.id: (context) => CryptoListScreen(),
        TypeChatScreen.id: (context) => TypeChatScreen(),
      },
    );
  }
}
