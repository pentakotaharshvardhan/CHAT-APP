import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
 class MessangeModel{
   String? messageid;
   String? sender;
   String? text;
   bool? seen;
   DateTime? createdon;

   MessangeModel({this.messageid,this.sender,this.text,this.seen,this.createdon});

   MessangeModel.fromMap(Map<String,dynamic> map){
     messageid = map["messageid"];
     sender= map['sender'];
     text=map['text'];
     seen=map['seen'];
     createdon=(map['createdon']as Timestamp).toDate();
   }

   Map<String,dynamic> toMap(){
     return {
       "messageid": messageid,
       "sender" : sender,
       "text":text,
       "seen":seen,
       "createdon":createdon,
     };
   }
 }