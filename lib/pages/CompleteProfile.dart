import 'dart:convert';
import 'dart:io';

import 'package:chat_app/models/UserModel.dart';
import 'package:chat_app/pages/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class Completeprofile extends StatefulWidget {
  UserModel? userModel;
  User? firebaseuser;

  Completeprofile(this.userModel,this.firebaseuser);


  @override
  State<Completeprofile> createState() => _CompleteprofileState();
}

class _CompleteprofileState extends State<Completeprofile> {
   File? imagefile;
  TextEditingController _namecontroller=TextEditingController();

  void selectImage(ImageSource source) async{
    XFile? pickedfile=await ImagePicker().pickImage(source: source);
    if(pickedfile!=null){
      cropImage(pickedfile);
    }
  }
  void cropImage(XFile file) async{
   CroppedFile? imageCropped= await ImageCropper().cropImage(
       sourcePath: file.path,
     aspectRatio: CropAspectRatio(ratioX: 3, ratioY: 3),
     compressQuality: 20
   );
   if(imageCropped!=null){
     setState(() {
       print(imageCropped);
       imagefile=File(imageCropped.path);
     });
   }
  }

  void showImage(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Upload the picture"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: (){
                Navigator.of(context).pop();
                selectImage(ImageSource.gallery);
              },
              leading: Icon(Icons.photo_album),
              title: Text("Select from Gallery"),
            ),
            ListTile(
              onTap: (){
                Navigator.of(context).pop();
                selectImage(ImageSource.camera);
              },
              leading: Icon(Icons.camera_alt),
              title: Text("Take a Image"),
            ),
          ],
        ),
      );
    });
  }

  void checkvalues(){
    String fullname=_namecontroller.text.trim();
    if(fullname=="" || imagefile==""){
      print("Enter the inputs properly");
    }
    else{
     uploaddata();
    }
  }

  void uploaddata() async{
    try {
      // Convert the image to a base64 string
      List<int> imageBytes = (await imagefile?.readAsBytes()) as List<int>;
      String base64String = base64Encode(imageBytes);
      String? fullname=_namecontroller.text.trim();
      widget.userModel?.fullname=fullname;
      widget.userModel?.profilepic=base64String;
      // Save the base64 string in Firestore

      await FirebaseFirestore.instance.collection("User").doc(widget.userModel!.uid).set(widget.userModel!.toMap()).then((value){
        print("Profile updated...");
        Navigator.of(context).popUntil((route)=>route.isFirst);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>
        HomePage(widget.userModel!,widget.firebaseuser! )));
      });

    } catch (e) {
      print("Error uploading file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading file: $e")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: Text("Complete Profile",style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView(
                children: [
                  SizedBox(height: 20,),
                  CupertinoButton(
                    onPressed: (){
                      showImage();
                    },
                    child: CircleAvatar(
                      radius: 60.0,
                      backgroundImage: imagefile != null ? FileImage(imagefile!) : null,
                      //backgroundColor: Colors.blue,
                      child:imagefile==null? Icon(Icons.person,color: Colors.black,size: 50,): null,
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    controller: _namecontroller,
                    decoration: InputDecoration(
                        labelText: "Full Name",
                        hintText: "Enter full Name"
                    ),
                  ),
                  SizedBox(height: 40,),
                  CupertinoButton(
                      color: Colors.blue,
                      disabledColor: Colors.indigoAccent,
                      child: Text("Save",style: TextStyle(color: Colors.white),), onPressed: (){
                        checkvalues();
                  }),
                ],
              ),
            ),
          )
      ),
    );
  }
}
