import 'package:flutter/material.dart';
import 'package:gpt_vision_leaf_detect/constants/constants.dart'; // Assuming your constants are in this file

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Display an icon or placeholder message here
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
                // Navigate back to the Dashboard or perform an action
                Navigator.pop(context); // Example: Go back to previous screen
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
      ),
    );
  }
}
