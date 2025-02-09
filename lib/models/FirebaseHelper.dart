import 'package:chat_app/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
class FirebaseHelper{
  
  Future<UserModel?> getUserModelById(String uid) async{
    UserModel? usermodel;
    
    DocumentSnapshot docSnap= await FirebaseFirestore.instance.collection("User").doc(uid).get();
    if(docSnap.data()!=null){
      usermodel=UserModel.fromMap(docSnap.data() as Map<String,dynamic>);
    }
    return usermodel;
  }
}