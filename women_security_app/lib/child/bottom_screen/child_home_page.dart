// ignore_for_file: unused_field

import 'dart:math';

import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shake/shake.dart';
import 'package:women_security_app/db/db_services.dart';
import 'package:women_security_app/model/contactsm.dart';
import 'package:women_security_app/widgets/home_widgets/custom_appBar.dart';
import 'package:women_security_app/widgets/home_widgets/custom_slider.dart';
import 'package:women_security_app/widgets/home_widgets/emergency.dart';
import 'package:women_security_app/widgets/live_safe.dart';

import '../../widgets/home_widgets/safe_home/safehome.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int qIndex = 0;
  Position? _currentPosition;
  String? _currentAddress;
  LocationPermission? permission;

  _getPermission() async {
    var status = await Permission.sms.request();
    return status.isGranted;
  }

  _isPermissionGranted() async {
    var status = await Permission.sms.status;
    return status.isGranted;
  }

  _sendSms(String phoneNumber, String message, {int? simSlot}) async {
    SmsStatus result = await BackgroundSms.sendMessage(
      phoneNumber: phoneNumber,
      message: message,
      simSlot: 1,
    );
    if (result == SmsStatus.sent) {
      print("Sent");
      Fluttertoast.showToast(msg: "SEND");
    } else {
      Fluttertoast.showToast(msg: "FAILED");
    }
  }

  _getCurrentLocation() async {
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(msg: "Location permission is permanently denied");
      } else {
        Fluttertoast.showToast(msg: "Location permission is denied");
      }
    } else if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: "Location permission is permanently denied");
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
      );
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLon();
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to get current location");
    }
  }

  _getAddressFromLatLon() async {
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
      Fluttertoast.showToast(msg: "Failed to get address");
    }
  }

  getRandomQuote() {
    Random random = Random();
    setState(() {
      qIndex = random.nextInt(5);
    });
  }

  getAndSendSms() async {
    if (_currentPosition != null && await _isPermissionGranted()) {
      List<TContact> contactList = await DatabaseHelper().getContactList();
      String messageBody =
          "https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude},${_currentPosition!.longitude}";
      contactList.forEach((element) {
        _sendSms("${element.number}", "I am in trouble $messageBody");
      });
    } else {
      Fluttertoast.showToast(msg: "Unable to send SMS");
    }
  }

  @override
  void initState() {
    getRandomQuote();
    super.initState();
    _getCurrentLocation();
    _getPermission();

    // SHAKE FEATURE
    ShakeDetector.autoStart(
      onPhoneShake: () {
        getAndSendSms();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shake!'),
          ),
        );
        // Do stuff on phone shake
      },
      minimumShakeCount: 1,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: 2.7,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              custom_appBar(
                quotesIndex: qIndex,
                onTap: () {
                  getRandomQuote();
                },
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    custom_slider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Emergency",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Emergency(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Explore LiveSafe",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    LiveSafe(),
                    SafeHome(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
