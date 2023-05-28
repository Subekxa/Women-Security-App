import 'package:flutter/material.dart';
import 'package:women_security_app/child/bottom_screen/add_contacts.dart';
import 'package:women_security_app/child/bottom_screen/chat_page.dart';
import 'package:women_security_app/child/bottom_screen/child_home_page.dart';
import 'package:women_security_app/child/bottom_screen/profile_page.dart';
import 'package:women_security_app/child/bottom_screen/review_page.dart';

class BottomPage extends StatefulWidget {
BottomPage({Key? key}) : super(key: key);

  @override
  State<BottomPage> createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  int currentIndex = 0;
  List<Widget> pages = [
    HomeScreen(),
    AddContactsPage(),
    ChatPage(),
    ProfilePage(),
    ReviewPage(),
  ];
  
  onTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar:BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: onTapped,
        items: [
          BottomNavigationBarItem(
            label: 'home',
            icon: Icon(
              Icons.home,
              )),
          BottomNavigationBarItem(
            label: 'Contacts',
            icon: Icon(
              Icons.contacts,
              )),
          BottomNavigationBarItem(
            label: 'Chats',
            icon: Icon(
              Icons.chat,
              )),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(
              Icons.person,
              )),
          BottomNavigationBarItem(
            label: 'Reviews',
            icon: Icon(
              Icons.reviews,
              )),
        ]) ,
    );
  }
}