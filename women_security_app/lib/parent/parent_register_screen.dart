import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:women_security_app/child/child_login_screen.dart';
import 'package:women_security_app/components/custom_textfield.dart';
import 'package:women_security_app/components/primarybutton.dart';
import 'package:women_security_app/components/secondarybutton.dart';
import 'package:women_security_app/model/user_model.dart';
import 'package:women_security_app/parent/parent_home_screen.dart';
import 'package:women_security_app/utils/constrants.dart';

class RegisterParentScreen extends StatefulWidget {
  @override
  State<RegisterParentScreen> createState() => _RegisterParentScreenState();
}

class _RegisterParentScreenState extends State<RegisterParentScreen> {
  bool isPasswordShown = true;
  bool isRetypePasswordShown = true;

  final _formkey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();
  bool isLoading = false;


_onSubmit() async{
  _formkey.currentState!.save();
  if (_formData['password'] != _formData['rpassword']) {
    dialogueBox(context, 'Password and retype password should be equal');
  } else {
    progressIndicator(context);
    try {
       setState(() {
          isLoading = true;
      });
  UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: _formData['gemail'].toString(),
    password: _formData['password'].toString()
  );
  if (userCredential.user != null) {
    final v = userCredential.user!.uid;
    DocumentReference<Map<String, dynamic >> db =
            FirebaseFirestore.instance.collection('users').doc(v);

            final user = UserModel(
              name: _formData['name'].toString(),
              phone: _formData['phone'].toString(),
              childEmail: _formData['cemail'].toString(),
              parentEmail: _formData['gemail'].toString(),
              id: v,
              type: 'Parent',
            );
            final jsonData = user.toJson();
            await db.set(jsonData).whenComplete(() {
              // goTo(context, LoginScreen());
              goTo(context, ParentHomeScreen());
               setState(() {
                isLoading = false;
                });
            });
    
  }


} on FirebaseAuthException catch (e) {
  setState(() {
                isLoading = false;
                });
  if (e.code == 'weak-password') {
    print('The password provided is too weak.');
     dialogueBox(context, 'The password provided is too weak.');
  } else if (e.code == 'email-already-in-use') {
    print('The account already exists for that email.');
    dialogueBox(context, 'The account already exists for that email.');
  }
} catch (e) {
  setState(() {
    isLoading = false;
    });
  print(e);
  dialogueBox(context, e.toString());
}
   
      print(_formData['email']);
      print(_formData['password']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10
          ),
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
                                Text("REGISTER AS PARENT",
                                style: TextStyle(
                                  fontSize: 40,
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
                            height: MediaQuery.of(context).size.height * 0.75,
                            child: Form(
                              key: _formkey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomTextField(
                                  hintText: 'Enter your name',
                                  textInputAction: TextInputAction.next,
                                  keyboardtype: TextInputType.name,
                                  prefix: Icon(Icons.person),
                                  onsave: (name) {
                                    _formData['name'] = name?? "";
                                  },
                                  validate: (name) {
                                  if (name! .isEmpty ||
                                    name.length < 3) {
                                    return 'Enter correct name';
                                  }
                                  return null;
                                  },
                                  ),
                                  CustomTextField(
                                    hintText: 'Enter your phone number',
                                    textInputAction: TextInputAction.next,
                                    keyboardtype: TextInputType.phone,
                                    prefix: Icon(Icons.phone),
                                    onsave: (phone) {
                                      _formData['phone'] = phone?? "";
                                    },
                                    validate: (phone) {
                                      if (phone! .isEmpty ||
                                      phone.length < 10) {
                                      return 'Enter correct phone number';
                                    }
                                    return null;
                                  },
                                  ),
                                  CustomTextField(
                                    hintText: 'Enter your email',
                                    textInputAction: TextInputAction.next,
                                    keyboardtype: TextInputType.emailAddress,
                                    prefix: Icon(Icons.email),
                                    onsave: (email) {
                                      _formData['gemail'] = email?? "";
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
                                    hintText: 'Enter your child email',
                                    textInputAction: TextInputAction.next,
                                    keyboardtype: TextInputType.emailAddress,
                                    prefix: Icon(Icons.email),
                                    onsave: (cemail) {
                                      _formData['cemail'] = cemail?? "";
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
                                    textInputAction: TextInputAction.next,
                                    isPassword: isPasswordShown,
                                    prefix : Icon(Icons.lock),
                                    validate: (password) {
                                      if (
                                        password! .isEmpty ||
                                        password.length < 6
                                        ) {
                                          return 'Enter correct password';
                                          }
                                          return null;
                                          },
                                          onsave: (password) {
                                          _formData['password'] = password ?? "";
                                        },
                                          suffix: IconButton(
                                            onPressed: () {
                                              setState(() {
                                              isPasswordShown = !isPasswordShown;
                                              });
                                              },icon:isPasswordShown?Icon(Icons.visibility_off)
                                              : Icon(Icons.visibility),
                                              ),
                                              ),
              
                                  CustomTextField(
                                    hintText: 'Retype your password',
                                    isPassword: isRetypePasswordShown,
                                    prefix : Icon(Icons.lock),
                                    validate: (password) {
                                      if (
                                        password! .isEmpty ||
                                        password.length < 6
                                        ) {
                                          return 'Enter correct password';
                                          }
                                          return null;
                                          },
                                          onsave: (password) {
                                          _formData['rpassword'] = password ?? "";
                                        },
                                          suffix: IconButton(
                                            onPressed: () {
                                              setState(() {
                                              isRetypePasswordShown = !isRetypePasswordShown;
                                              });
                                              },icon:isRetypePasswordShown?Icon(
                                              Icons.visibility_off)
                                              : Icon(Icons.visibility),
                                              ),
                                              ),
              
                                  PrimaryButton(title: 'REGISTER', onPressed: () {
                                    if (_formkey.currentState!.validate()) {
                                     _onSubmit();
                                     }
                                     }),
                            ],
                          ),
                        ),
                      ),
              
                      SecondaryButton(
                        title: 'Login with your account',
                        onPressed: () {
                          goTo(
                          context,
                          LoginScreen());
                
                      }),
              
                ]),
              ),
            ],
          ),
        ),
      ),

    );
  }
}