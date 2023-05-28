import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:women_security_app/chat_module/chat_screen.dart';
import 'package:women_security_app/utils/constrants.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("CHAT WITH YOUR GUARDIAN"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('type', isEqualTo: 'Parent')
            .where('childEmail',
                isEqualTo: FirebaseAuth.instance.currentUser?.email)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: progressIndicator(context));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              final d = snapshot.data!.docs[index];
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
