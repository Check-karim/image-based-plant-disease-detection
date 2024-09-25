import 'package:flutter/material.dart';
import 'package:gpt_vision_leaf_detect/constants/constants.dart'; // Assuming your constants are in this file
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor, // Use the theme color
        title: Text(
          'Report',
          style: TextStyle(color: textColor),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Fetch the precautions from Firestore in real-time
        stream: FirebaseFirestore.instance.collection('precautions').snapshots(),
        builder: (context, snapshot) {
          // Check for loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Check if there are any precautions available
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.assessment, // Example icon for reports
                    size: 100,
                    color: themeColor,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No Reports Available',
                    style: TextStyle(
                      fontSize: 18,
                      color: themeColor,
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor, // Match the theme
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text('Go Back', style: TextStyle(color: textColor)),
                  ),
                ],
              ),
            );
          }

          // List of precautions
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              String diseaseName = document['diseaseName'];
              String precautions = document['precautions'];
              String imageUrl = document['imageUrl']; // Get the image URL
              Timestamp timestamp = document['date'];
              DateTime date = timestamp.toDate();

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                elevation: 5,
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.image_not_supported, color: themeColor), // Placeholder if no image
                  title: Text(
                    diseaseName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Precautions: $precautions'),
                      Text('Date: ${date.toLocal()}'),
                    ],
                  ),
                  trailing: Icon(Icons.local_hospital, color: themeColor),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
