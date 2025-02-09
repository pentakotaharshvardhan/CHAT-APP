
import 'package:chat_app/models/UserModel.dart';
import 'package:chat_app/pages/CompleteProfile.dart';
import 'package:chat_app/pages/loginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rive/rive.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _emailcontroller=TextEditingController();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode cpasswordFocusNode = FocusNode();
  TextEditingController _passwordcontroller=TextEditingController();
  TextEditingController _cpasswordcontroller=TextEditingController();


  StateMachineController? controller;
  SMIInput<bool>? isHandsUp;

  @override
  void initState() {
    cpasswordFocusNode.addListener(cpasswordFocus);
    passwordFocusNode.addListener(passwordFocus);
    // TODO: implement initState
    super.initState();
  }

  void passwordFocus() {
    isHandsUp?.change(passwordFocusNode.hasFocus);
  }
  void cpasswordFocus() {
    isHandsUp?.change(cpasswordFocusNode.hasFocus);
  }
  void checkValues(){
    String email=_emailcontroller.text.trim();
    String password=_passwordcontroller.text.trim();
    String cpassword=_cpasswordcontroller.text.trim();
    if(email=="" || password==""|| cpassword==""){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Inputs are empty...")),
      );
    }
    else if(password!=cpassword){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("password and confirm password are not same..")),
      );
    }
    else{
      signUp(email,password);
    }
  }

  void signUp(String email,String password) async{
    UserCredential? credential;
    try{
      credential=await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password);
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
    if(credential!=null){
      String uid=credential.user!.uid;
      UserModel newUser=UserModel(
          uid, "", email, "");
      await FirebaseFirestore.instance.collection("User").doc(uid).set(newUser.toMap()).then((value){
        print(" New User Created...");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("New User Created")),
        );
        Navigator.of(context).popUntil((route)=>route.isFirst);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>
          Completeprofile(newUser,credential!.user)
        ));
      });
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
                    SizedBox(height: 10.0,),
                    Container(
                      child: Column(
                        children: [
                          SizedBox(height: 25,),
                          Text("Chat App",style: TextStyle(fontSize: 36,color: Colors.blue,fontWeight: FontWeight.bold),),
                          SizedBox(height: 20.0,),
                          SizedBox(
                            height: 200,
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
                    SizedBox(height: 20.0,),
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
                    SizedBox(height: 10.0,),
                    TextField(
                      focusNode: cpasswordFocusNode,
                      controller: _cpasswordcontroller,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: "Confirm Password",
                          hintText: "Enter the password"
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    CupertinoButton(
                        color: Colors.blue,
                        disabledColor: Colors.indigoAccent,
                        child: Text("Sign Up",style: TextStyle(color: Colors.white),),
                        onPressed: (){
                          checkValues();
                          //Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Completeprofile()));
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have a account ?"),
              CupertinoButton(child: Text("Sign In",style: TextStyle(color: Colors.blue),), onPressed: (){
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>Loginpage()));
              }),
            ],
          ),
        )
    );
  }
}
