import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:women_security_app/components/custom_textfield.dart';
import 'package:women_security_app/components/primarybutton.dart';

class ReviewPage extends StatefulWidget {
  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  TextEditingController locationC = TextEditingController();
  TextEditingController viewsC = TextEditingController();
  bool isSaving = false;

  showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Review your place"),
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomTextField(
                      hintText: 'enter location',
                      controller: locationC,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomTextField(
                      controller: viewsC,
                      hintText: 'enter review',
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            PrimaryButton(
              title: "SAVE",
              onPressed: () {
                saveReview();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  saveReview() async {
    setState(() {
      isSaving = true;
    });
    await FirebaseFirestore.instance
        .collection('reviews')
        .add({'location': locationC.text, 'views': viewsC.text})
        .then((value) {
      setState(() {
        isSaving = false;
        Fluttertoast.showToast(msg: 'Review uploaded successfully');
      });
    });
  }

  deleteReview(String reviewId) async {
    await FirebaseFirestore.instance
        .collection('reviews')
        .doc(reviewId)
        .delete()
        .then((value) {
      Fluttertoast.showToast(msg: 'Review deleted successfully');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isSaving == true
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Text(
                    "Reviews",
                    style: TextStyle(fontSize: 30, color: Colors.black),
                  ),
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('reviews')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            final data = snapshot.data!.docs[index];
                            final reviewId = data.id;

                            return Dismissible(
                              key: Key(reviewId),
                              onDismissed: (direction) {
                                deleteReview(reviewId);
                              },
                              background: Container(
                                color: Colors.red,
                                child: Icon(Icons.delete),
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Card(
                                  elevation: 10,
                                  child: ListTile(
                                    title: Text(
                                      data['location'],
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(data['views']),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xfff290a7),
        onPressed: () {
          showAlert(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
