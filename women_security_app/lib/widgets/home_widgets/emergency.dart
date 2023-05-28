import 'package:flutter/material.dart';
import 'package:women_security_app/widgets/home_widgets/emergencies/AlertEmergency.dart';
import 'package:women_security_app/widgets/home_widgets/emergencies/AmbulanceEmergency.dart';
import 'package:women_security_app/widgets/home_widgets/emergencies/FirebrigadeEmergency.dart';
import 'package:women_security_app/widgets/home_widgets/emergencies/Policeemergency.dart';

class Emergency extends StatelessWidget {
  const Emergency({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 180,
      child: ListView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          PoliceEmergency(),
          AmbulanceEmergency(),
          FirebrigadeEmergency(),
          AlertEmergency(),
        ],
      ),
    );
    
  }

}