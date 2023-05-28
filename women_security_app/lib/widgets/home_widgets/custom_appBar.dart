
import 'package:flutter/material.dart';
import 'package:women_security_app/utils/quotes.dart';

// ignore: must_be_immutable
class custom_appBar extends StatelessWidget {
  // const CustomAppBar({super.key});
  //To change the quotes while clicking on it
  Function? onTap;
  int? quotesIndex;
  custom_appBar({this.onTap, this.quotesIndex});

  @override
  Widget build(BuildContext context) {
  //inkwell: widget lai clickable banauna wrap with widget garera inkwell
    return InkWell(
      onTap: () {
        onTap!();
      },

      child: Container(
        child: Text(
        quotes[quotesIndex!],
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
      ),
      ),
        
      ),
    );
  }
}