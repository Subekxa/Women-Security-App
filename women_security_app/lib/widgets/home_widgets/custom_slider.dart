
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:women_security_app/utils/quotes.dart';
import 'package:women_security_app/widgets/home_widgets/custom_webview.dart';

class custom_slider extends StatelessWidget {
  const custom_slider({Key? key}) : super(key: key);

  void navigateToRoute(BuildContext context, Widget route) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => route));
  }
  
 @override
 Widget build(BuildContext context) {
  return Container(
    child: CarouselSlider(
      options: CarouselOptions(
        aspectRatio: 2.0,
        autoPlay: true,
        enlargeCenterPage: true,

      ),
      items: List.generate(
        imageSliders.length,
        (index) => Card(
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            ),


            child: InkWell(
              onTap:() {
                if (index == 0) {
                  navigateToRoute(
                    context,
                    custom_webview(
                      url:
                      "https://www.careerride.com/view/are-women-security-apps-really-useful-18415.aspx"));
                } else if (index == 1) {
                  navigateToRoute(
                    context,
                    custom_webview(
                      url:
                      "https://www.unwomen.org/en/news-stories/explainer/2023/02/power-on-how-we-can-supercharge-an-equitable-digital-future?gclid=CjwKCAjw3ueiBhBmEiwA4BhspAr9p3lzglrOClsQTeudKMM76ZfAzShTmd0YvT9CGXtWJMTsuImEixoCIJcQAvD_BwE"));
                } else if (index == 2) {
                  navigateToRoute(
                    context,
                    custom_webview(
                      url:
                      "https://about.fb.com/news/2021/06/partnering-with-experts-to-promote-womens-safety/"));
                } else  {
                  navigateToRoute(
                    context,
                    custom_webview(
                      url:
                      "https://equaleverywhere.org/story/creating-opportunities-for-women-to-grow-lady-tees-journey-to-advocacy/?gclid=CjwKCAjw3ueiBhBmEiwA4BhspBM_Qwu3DkqWHTweOTO3ml2YtRuOnBGcKhyqpwB8HOREw1jgyZUqUxoCikcQAvD_BwE"));
                }


              },
              child: Container(
                decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      imageSliders[index],
                    ))),
                 child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(colors:
                    [Colors.black.withOpacity(0.5),
                    Colors.transparent,
                    
                    ]),
                  ),
                   child: Align(
                    alignment: Alignment.bottomLeft,
                     child: Padding(
                       padding: const EdgeInsets.only(bottom: 8, left: 8),
                       child: Text(
                        articleTitle[index],
                        style: TextStyle(fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        ),
                       ),
                     ),
                   ),
                 ),
            
            
            
              ),
            ),
        ),
    
       ),
      ),
    
  );

 }

}