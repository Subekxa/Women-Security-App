import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:women_security_app/child/child_login_screen.dart';
import 'package:women_security_app/components/custom_textfield.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameC = TextEditingController();
  final key = GlobalKey<FormState>();
  String? id;
  String? profilePic;
  String? downloadURL;
  bool isSaving = false;

  getDate() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        nameC.text = value.docs.first['name'];
        id = value.docs.first.id;
        profilePic = value.docs.first['profilePic'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isSaving == true
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.pink,
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: SingleChildScrollView(
                  child: Center(
                    child: Form(
                      key: key,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "UPDATE YOUR PROFILE",
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                          SizedBox(height: 30),
                          GestureDetector(
                            onTap: () async {
                              final XFile? pickImage = await ImagePicker().pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 50,
                              );
                              if (pickImage != null) {
                                setState(() {
                                  profilePic = pickImage.path;
                                });
                              }
                            },
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                              ),
                              child: profilePic == null
                                  ? Center(
                                      child: Icon(
                                        Icons.add_photo_alternate,
                                        size: 35,
                                        color: Colors.white,
                                      ),
                                    )
                                  : profilePic!.contains('http')
                                      ? CircleAvatar(
                                          backgroundImage: NetworkImage(profilePic!),
                                          radius: 75,
                                        )
                                      : CircleAvatar(
                                          backgroundImage: FileImage(File(profilePic!)),
                                          radius: 75,
                                        ),
                            ),
                          ),
                          SizedBox(height: 30),
                          CustomTextField(
                            controller: nameC,
                            hintText: nameC.text,
                            validate: (v) {
                              if (v!.isEmpty) {
                                return 'Please enter your updated name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () async {
                              if (key.currentState!.validate()) {
                                SystemChannels.textInput.invokeMethod('TextInput.hide');
                                profilePic == null
                                    ? Fluttertoast.showToast(msg: 'Please select a profile picture')
                                    : update();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:  Color(0xfff290a7),
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              textStyle: TextStyle(fontSize: 16),
                            ),
                            child: Text("UPDATE"),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                await FirebaseAuth.instance.signOut();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              } catch (e) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Error"),
                                    content: Text(e.toString()),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:  Color(0xfff290a7),
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              textStyle: TextStyle(fontSize: 16),
                            ),
                            child: Text("SIGN OUT"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Future<String?> uploadImage(String filePath) async {
    try {
      final fileName = Uuid().v4();
      final Reference fbStorage = FirebaseStorage.instance.ref('profile').child(fileName);
      final UploadTask uploadTask = fbStorage.putFile(File(filePath));
      await uploadTask.then((p0) async {
        downloadURL = await fbStorage.getDownloadURL();
      });
      return downloadURL;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    return null;
  }

  update() async {
    setState(() {
      isSaving = true;
    });
    uploadImage(profilePic!).then((value) {
      Map<String, dynamic> data = {
        'name': nameC.text,
        'profilePic': downloadURL,
      };
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(data)
          .then((_) {
        setState(() {
          isSaving = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Success"),
            content: Text("Profile updated successfully."),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      });
    });
  }
}
