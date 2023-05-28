import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class custom_webview extends StatelessWidget {
  final String? url;
  custom_webview({this.url});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WebView(
        initialUrl: url,
        
    
      ),
    );
  }
}