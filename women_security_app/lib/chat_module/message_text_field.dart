import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class MessageTextField extends StatefulWidget {
  final String? currentId;
  final String? friendId;

  const MessageTextField({Key? key, this.currentId, this.friendId})
      : super(key: key);

  @override
  State<MessageTextField> createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  TextEditingController _controller = TextEditingController();
  Position? _currentPosition;
  String? _currentAddress;
  String? _message;
  File? imageFile;

  LocationPermission? _permission;
  StreamController<Position> _positionStreamController =
      StreamController<Position>();

  @override
  void dispose() {
    _controller.dispose();
    _positionStreamController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  Future getImage() async {
    ImagePicker _picker = ImagePicker();
    await _picker.pickImage(source: ImageSource.gallery).then((XFile? xFile) {
      imageFile = File(xFile!.path);
      uploadImage();
    });
  }

  Future getImageFromCamera() async {
    ImagePicker _picker = ImagePicker();
    await _picker.pickImage(source: ImageSource.camera).then((XFile? xFile) {
      imageFile = File(xFile!.path);
      uploadImage();
    });
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;
    var ref = FirebaseStorage.instance
        .ref()
        .child('images')
        .child("$fileName.jpg");
    var uploadTask = await ref.putFile(imageFile!);

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();
      await sendMessage(imageUrl, 'img');
    }
  }

  Future<void> _getCurrentLocation() async {
    _permission = await Geolocator.checkPermission();
    if (_permission == LocationPermission.denied) {
      _permission = await Geolocator.requestPermission();
      Fluttertoast.showToast(msg: "Location permissions are denied");
      if (_permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(
            msg: "Location permissions are permanently denied");
      }
    }
    if (_permission == LocationPermission.whileInUse ||
        _permission == LocationPermission.always) {
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        print(_currentPosition!.latitude);
        _getAddressFromLatLon();
        _positionStreamController.add(_currentPosition!);
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }

  Future<void> _getAddressFromLatLon() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.street}";
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> sendMessage(String message, String type) async {
    final currentId = widget.currentId;
    final friendId = widget.friendId;

    if (currentId != null && currentId.isNotEmpty && friendId != null && friendId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentId)
          .collection('messages')
          .doc(friendId)
          .collection('chats')
          .add({
        'senderId': currentId,
        'receiverId': friendId,
        'message': message,
        'type': type,
        'date': DateTime.now(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .collection('messages')
          .doc(currentId)
          .collection('chats')
          .add({
        'senderId': currentId,
        'receiverId': friendId,
        'message': message,
        'type': type,
        'date': DateTime.now(),
      });
    } else {
      print('Error sending message: currentId or friendId is null or empty');
      // Handle the error appropriately (e.g., show an error message to the user)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              cursorColor: Colors.blue,
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type your message',
                fillColor: Colors.grey[100],
                filled: true,
                prefixIcon: IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) => bottomsheet(),
                    );
                  },
                  icon: Icon(
                    Icons.add_box_rounded,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () async {
                _message = _controller.text;
                sendMessage(_message!, 'text');
                _controller.clear();
              },
              child: Icon(
                Icons.send,
                color: Colors.blue,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomsheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            chatsIcon(
              Icons.location_pin,
              "Send Location",
              () async {
                await _getCurrentLocation();
                if (_currentPosition != null) {
                  String locationUrl =
                      "https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude},${_currentPosition!.longitude}";
                  String locationMessage =
                      "$locationUrl\n$_currentAddress";
                  sendMessage(locationMessage, "live_location");
                }
              },
            ),
            chatsIcon(Icons.camera_alt, "Camera", () async {
              await getImageFromCamera();
            }),
            chatsIcon(Icons.insert_photo, "Photo", () async {
              getImage();
            }),
          ],
        ),
      ),
    );
  }

  Widget chatsIcon(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue,
            child: Icon(icon),
          ),
          Text(title),
        ],
      ),
    );
  }
}
