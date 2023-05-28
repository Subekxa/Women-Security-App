import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:women_security_app/child/bottom_page.dart';
import 'package:women_security_app/child/child_register.dart';
import 'package:women_security_app/components/custom_textfield.dart';
import 'package:women_security_app/components/primarybutton.dart';
import 'package:women_security_app/components/secondarybutton.dart';
import 'package:women_security_app/db/share_pref.dart';
import 'package:women_security_app/parent/parent_home_screen.dart';
import 'package:women_security_app/parent/parent_register_screen.dart';
import 'package:women_security_app/utils/constrants.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordShown = true;
  final _formkey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();
  bool isLoading = false;

  _onSubmit() async {
    _formkey.currentState!.save();
      try {
        setState(() {
          isLoading = true;
        });
        UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
          email: _formData['email'].toString(),
          password: _formData['password'].toString());
        if (userCredential.user != null) {
          setState(() {
            isLoading = false;
          });
          FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get()
        .then((value){
          if (value['type'] == 'Parent') {
            print(value['type']);
            MySharedPreference.saveUserType('Parent');
            goTo(context, ParentHomeScreen());

          } else {
            MySharedPreference.saveUserType('Child');
             goTo(context, BottomPage());

          }
        });
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
            isLoading = false;
          });
          if (e.code == 'user-not-found') {
            dialogueBox(context, 'No user found for that email.');
            print('No user found for that email.');
          } else if (e.code == 'wrong-password') {
            dialogueBox(context, 'Wrong password provided for that user.');
            print('Wrong password provided for that user.');
        }
      }
    print(_formData['email']);
    print(_formData['password']);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              isLoading
                ? progressIndicator(context)
                : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height*0.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("EMPOWERSAFE",
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            ),
                          ),
                           Image.asset('assets/logo.png',
                           height: 100,
                           width: 100,
                           ),
                        ],
                      ),
                    ),
              
                     
                    Container(
                      height: MediaQuery.of(context).size.height*0.4,
                      child: Form(
                        key: _formkey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomTextField(
                              hintText: 'Enter your email',
                              textInputAction: TextInputAction.next,
                              keyboardtype: TextInputType.emailAddress,
                              prefix: Icon(Icons.email),
                              onsave: (email) {
                                _formData['email'] = email?? "";
                              },
                              validate: (email) {
                                if (email! .isEmpty ||
                                  email.length < 3 ||
                                  !email.contains("@")) {
                                  return 'Enter correct email';
                                }
                                return null;
                              },
                            ),
                          CustomTextField(
                            hintText: 'Enter your password',
                            isPassword: isPasswordShown,
                            prefix: Icon(Icons.lock),
                            onsave: (password) {
                                _formData['password'] = password ?? "";
                              },
                            validate: (password) {
                                if (
                                  password! .isEmpty ||
                                  password.length < 6
                                  ) {
                                  return 'Enter correct password';
                                }
                                return null;
                              },
                            suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  isPasswordShown = !isPasswordShown;
                                  
                                });
                                
                            },icon:isPasswordShown?Icon(Icons.visibility_off)
                            : Icon(Icons.visibility),),
                          ),
                          PrimaryButton(title: 'LOGIN',
                          onPressed: () {
                            // progressIndicator(context);

                            if (_formkey.currentState!.validate()) {
                               _onSubmit();

                            }

                          }),
                          ],
                        ),
                      ),
                    ),
                    
                    // Container(
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Text("Forgot Password?",
                    //       style: TextStyle(fontSize: 18),
                    //       ),
                    //       SecondaryButton(title: 'CLICK HERE', onPressed: () {}),
                    //     ],
                    //   ),
                    // ),
                    SecondaryButton(
                      title: 'Register as CHILD',
                      onPressed: () {
                        goTo(
                        context,
                        RegisterUserScreen());
                    }),
                    SecondaryButton(
                      title: 'Register as GUARDIAN ',
                      onPressed: () {
                        goTo(
                        context,
                        RegisterParentScreen());
                    }),
     
                  ],
                ),
              ),
            ],
          ),
        )),

     
    );
  }
}