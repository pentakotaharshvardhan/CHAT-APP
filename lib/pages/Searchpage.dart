import 'dart:convert';
import 'dart:developer';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/ChatRoomModel.dart';
import 'package:chat_app/models/UserModel.dart';
import 'package:chat_app/pages/ChatRoomPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:uuid/uuid.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  SearchPage({required this.userModel, required this.firebaseUser});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
      ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatroom;
    } else {
      // Create a new one
      var uuid = Uuid();
      ChatRoomModel newChatroom = ChatRoomModel(
        uuid.v1(),
        {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
        "",
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;

      log("New Chatroom Created!");
    }

    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "Search",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                  ),
                  onChanged: (value) {
                    setState(() {}); // Trigger a rebuild whenever the text changes
                  },
                ),
                SizedBox(height: 20),
                CupertinoButton(
                  onPressed: () {
                    setState(() {});
                  },
                  color: Colors.blue,
                  child: Text(
                    "Search",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("User")
                      .where("email", isEqualTo: searchController.text)
                      .where("email", isNotEqualTo: widget.userModel.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                        snapshot.data as QuerySnapshot;

                        if (dataSnapshot.docs.isNotEmpty) {
                          Map<String, dynamic> userMap =
                          dataSnapshot.docs[0].data()
                          as Map<String, dynamic>;

                          UserModel searchedUser = UserModel.fromMap(userMap);

                          return ListTile(
                            onTap: () async {
                              ChatRoomModel? chatroomModel =
                              await getChatroomModel(searchedUser);

                              if (chatroomModel != null) {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ChatRoomPage(
                                        targetUser: searchedUser,
                                        userModel: widget.userModel,
                                        firebaseUser: widget.firebaseUser,
                                        chatroom: chatroomModel,
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                            leading: CircleAvatar(
                              backgroundImage: MemoryImage(
                                base64Decode(searchedUser.profilepic!),
                              ),
                              backgroundColor: Colors.grey[500],
                            ),
                            title: Text(searchedUser.fullname!),
                            subtitle: Text(
                              searchedUser.email!,
                              style: TextStyle(color: Colors.blue),
                            ),
                            trailing: Icon(Icons.keyboard_arrow_right),
                          );
                        } else {
                          return SizedBox(
                            height: 200,
                            child: RiveAnimation.asset(
                              "assests/tomato_reading.riv",
                              stateMachines: [
                                "State Machine 1",
                                "State Machine 2"
                              ],
                              artboard: "Artboard",
                            ),
                          );
                        }
                      } else if (snapshot.hasError) {
                        return Text("An error occured!");
                      } else {
                        return Text("No results found!");
                      }
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
