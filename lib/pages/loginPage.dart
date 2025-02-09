import 'package:chat_app/models/UserModel.dart';
import 'package:chat_app/pages/HomePage.dart';
import 'package:chat_app/pages/SingupPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  TextEditingController _emailcontroller=TextEditingController();
  FocusNode passwordFocusNode = FocusNode();
  TextEditingController _passwordcontroller=TextEditingController();

  /// rive controller and input
  StateMachineController? controller;
  SMIInput<bool>? isHandsUp;

  @override
  void initState() {
    passwordFocusNode.addListener(passwordFocus);
    // TODO: implement initState
    super.initState();
  }

  void passwordFocus() {
    isHandsUp?.change(passwordFocusNode.hasFocus);
  }
  void checkValues(){
    String email=_emailcontroller.text.trim();
    String password=_passwordcontroller.text.trim();
    if(email=="" || password==""){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Inputs are empty...")),
      );
    }
    else{
      Login(email,password);
    }
  }
  void Login(String email,String password) async{
    UserCredential? credential;
    try{
      credential=await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password);
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
    if(credential!=null){
      String uid=credential.user!.uid;
      DocumentSnapshot userData=await FirebaseFirestore.instance.collection("User").doc(uid).get();
      UserModel usermodel=UserModel.fromMap(userData.data() as Map<String,dynamic>);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Successful...")),
      );
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (value)=> HomePage(usermodel,credential!.user! )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFD6E2EA),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 1000,
                    child: Column(
                      children: [
                        SizedBox(height: 25,),
                        Text("Chat App",style: TextStyle(fontSize: 36,color: Colors.blue,fontWeight: FontWeight.bold),),
                        SizedBox(height: 20.0,),
                        SizedBox(
                          height: 250,
                          width: 250,
                          child: RiveAnimation.asset(
                            "assests/login_screen_character.riv",
                            fit: BoxFit.fitHeight,
                            stateMachines: const ["State Machine 1"],
                            onInit: (artboard) {
                              controller = StateMachineController.fromArtboard(
                                artboard,
                                /// from rive, you can see it in rive editor
                                "State Machine 1",
                              );
                              if (controller == null) return;
        
                              artboard.addController(controller!);
                              isHandsUp = controller?.findInput("hands_up");
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0,),
                  TextField(
                    controller: _emailcontroller,
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Enter the email"
                    ),
                  ),
                  SizedBox(height: 10.0,),
                    TextField(
                      focusNode: passwordFocusNode,
                      controller: _passwordcontroller,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "Enter the password"
                      ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CupertinoButton(
                    color: Colors.blue,
                      disabledColor: Colors.indigoAccent,
                      child: Text("Sign IN",style: TextStyle(color: Colors.white),), onPressed: (){
                    passwordFocusNode.unfocus();
                      checkValues();
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Color(0xFFD6E2EA),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have any Account ?"),
            CupertinoButton(child: Text("Sign Up",style: TextStyle(color: Colors.blue),), onPressed: (){
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>SignUpPage()));
            }),
          ],
        ),
      )
    );
  }
}
