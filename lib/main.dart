import 'package:chat_app/models/FirebaseHelper.dart';
import 'package:chat_app/pages/CompleteProfile.dart';
import 'package:chat_app/pages/HomePage.dart';
import 'package:chat_app/pages/SingupPage.dart';
import 'package:chat_app/pages/loginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'models/UserModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;
  UserModel? userModel = currentUser != null ? await FirebaseHelper().getUserModelById(currentUser.uid) : null;

  if (currentUser != null && userModel != null) {
    runApp(MyAppLogged(userModel, currentUser));
  } else {
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Loginpage(),
    );
  }
}

class MyAppLogged extends StatelessWidget {
  UserModel? userModel;
  User? firebaseUser;
  MyAppLogged(this.userModel, this.firebaseUser);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel!, firebaseUser!),
    );
  }
}
