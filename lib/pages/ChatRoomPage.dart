import 'dart:convert';
import 'dart:developer';
import 'package:rive/rive.dart';
import 'package:uuid/uuid.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/ChatRoomModel.dart';
import 'package:chat_app/models/MessageModel.dart';
import 'package:chat_app/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage({Key? key, required this.targetUser, required this.chatroom, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  StateMachineController? controller;
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if(msg != "") {
      // Send Message
      var uuid = Uuid();
      MessangeModel newMessage = MessangeModel(
          messageid: uuid.v1(),
          sender: widget.userModel.uid,
          text: msg,
          seen: false,
          createdon: DateTime.now(),
      );
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid).collection("messages").doc(newMessage.messageid).set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid).set(widget.chatroom.toMap());

      log("Message Sent!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: MemoryImage(base64Decode(widget.targetUser.profilepic.toString())),
            ),
            SizedBox(width: 10,),
            Flexible(child: Text(widget.targetUser.fullname.toString(),style: TextStyle(color: Colors.white),)),

          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: RiveAnimation.asset(
              'assests/lion_.riv', // Your Rive animation file
              stateMachines: const ["State Machine 1"],
              onInit: (artboard) {
                controller = StateMachineController.fromArtboard(
                  artboard,
                  /// from rive, you can see it in rive editor
                  "State Machine 1",
                );
                if (controller == null) return;

                artboard.addController(controller!);
              },
              fit: BoxFit.cover,  // Make the animation cover the screen
            ),
          ),
         SafeArea(
          child: Container(
            child: Column(
              children: [

                // This is where the chats will go
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10
                    ),
                    //child: Text("heloo"),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid).collection("messages").orderBy("createdon", descending: true).snapshots(),
                      builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.active) {
                          if(snapshot.hasData) {
                            QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                            return ListView.builder(
                              reverse: true,
                              itemCount: dataSnapshot.docs.length,
                              itemBuilder: (context, index) {
                                MessangeModel currentMessage = MessangeModel.fromMap(dataSnapshot.docs[index].data() as Map<String, dynamic>);
                                return Row(
                                  mainAxisAlignment: (currentMessage.sender == widget.userModel.uid) ? MainAxisAlignment.end : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (currentMessage.sender == widget.userModel.uid) ? Colors.white : Colors.greenAccent,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                          child: Text(
                                            currentMessage.text.toString(),
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                            ),
                                          ),
                                        )
                                  ],
                                );
                              },
                            );
                          }
                          else if(snapshot.hasError) {
                            return Center(
                              child: Text("An error occured! Please check your internet connection."),
                            );
                          }
                          else {
                            return Center(
                              child: Text("Say hi to your new friend"),
                            );
                          }
                        }
                        else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                ),

                Container(
                  color: Colors.grey[200],
                  padding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5
                  ),
                  child: Row(
                    children: [

                      Flexible(
                        child: TextField(
                          controller: messageController,
                          maxLines: null,
                          decoration: InputDecoration(
                              hintText: "Enter message",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          sendMessage();
                        },
                        icon: Icon(Icons.send, color: Colors.green,),
                      ),

                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
    ],
      ),
    );
  }
}