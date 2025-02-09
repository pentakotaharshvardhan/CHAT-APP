import 'dart:convert';

import 'package:chat_app/models/ChatRoomModel.dart';
import 'package:chat_app/models/FirebaseHelper.dart';
import 'package:chat_app/models/UIHelper.dart';
import 'package:chat_app/models/UserModel.dart';
import 'package:chat_app/pages/ChatRoomPage.dart';
import 'package:chat_app/pages/LoginPage.dart';
import 'package:chat_app/pages/SearchPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage(this.userModel, this.firebaseUser);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Chat App",style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            color: Colors.white,
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Loginpage();
                  },
                ),
              );
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .where("participants.${widget.userModel.uid}", isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;

                  return ListView.builder(
                    itemCount: chatRoomSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                          chatRoomSnapshot.docs[index].data() as Map<String, dynamic>);

                      Map<String, dynamic> participants = chatRoomModel.participants!;
                      List<String> participantKeys = participants.keys.toList();
                      participantKeys.remove(widget.userModel.uid);
                      FirebaseHelper fh = FirebaseHelper();

                      return FutureBuilder<UserModel?>(
                        future: fh.getUserModelById(participantKeys[0]),
                        builder: (context, userData) {
                          if (userData.connectionState == ConnectionState.done) {
                            if (userData.data != null) {
                              UserModel targetUser = userData.data!;

                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return ChatRoomPage(
                                        chatroom: chatRoomModel,
                                        firebaseUser: widget.firebaseUser,
                                        userModel: widget.userModel,
                                        targetUser: targetUser,
                                      );
                                    }),
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundImage: MemoryImage(
                                      base64Decode(targetUser.profilepic.toString())),
                                ),
                                title: Text(targetUser.fullname.toString()),
                                subtitle: (chatRoomModel.lastMessage != "")
                                    ? Text(chatRoomModel.lastMessage.toString(),style: TextStyle(color: Colors.blue),)
                                    : Text(
                                  "Say hi to your new friend!",
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          } else {
                            return Container();
                          }
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return Center(
                    child: Text("No Chats"),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return SearchPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
            }),
          );


        },
        child: Icon(Icons.search),
      ),
    );
  }
}

