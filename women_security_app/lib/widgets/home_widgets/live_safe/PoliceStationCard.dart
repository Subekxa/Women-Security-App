

import 'package:flutter/material.dart';

class PoliceStationCard extends StatelessWidget {
  final Function? onMapFunction;
  const PoliceStationCard({Key? key, this.onMapFunction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              onMapFunction!('Police Stations near me ');

            },
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
                ),
                child: Container(
                  height: 50,
                  width: 60,
                  child: Center(
                    child: Image.asset('assets/policeicon.png',
                    height: 35,
              
                    ),
                  ),
                ),
            ),
          ),
          Text('Police stations'),  
        ],
    
      ),
    );       
  }
}