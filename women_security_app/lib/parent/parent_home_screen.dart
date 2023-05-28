import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:women_security_app/chat_module/chat_screen.dart';
import 'package:women_security_app/child/child_login_screen.dart';
import 'package:women_security_app/utils/constrants.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Container(),
            ),
            ListTile(
              title: TextButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    goTo(context, LoginScreen());
                  } on FirebaseAuthException catch (e) {
                    dialogueBox(context, e.toString());
                  }
                },
                child: Text("SIGN OUT"),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("CHAT WITH YOUR CHILD"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('type', isEqualTo: 'Child')
            .where('parentEmail',
                isEqualTo: FirebaseAuth.instance.currentUser?.email)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No child data available'));
          }

          final data = snapshot.data!.docs;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              final d = data[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Color.fromARGB(255, 250, 163, 192),
                  child: ListTile(
                    onTap: () {
                      goTo(
                        context,
                        ChatScreen(
                          currentUserId:
                              FirebaseAuth.instance.currentUser?.uid ?? '',
                          friendId: d.id,
                          friendName: d['name'],
                        ),
                      );
                    },
                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(d['name']),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}






