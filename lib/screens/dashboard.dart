import 'package:flutter/material.dart';
import 'homepage.dart'; // Import the detection screen widget
import 'report.dart'; // Import the report screen widget
import 'package:gpt_vision_leaf_detect/constants/constants.dart'; // Assuming your constants are in a file named constants.dart

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text(
          'Dashboard',
          style: TextStyle(color: textColor),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Display the image at the top of the screen
            Image.asset(
              'assets/images/pick1.png', // Make sure the image path is correct
              height: 200,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Navigate to the detection screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HomePage(), // Replace with your actual DetectionScreen widget
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor, // Match the theme
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text('Go to Detection', style: TextStyle(color: textColor)),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Navigate to the report screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ReportScreen(), // Replace with your actual ReportScreen widget
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor, // Match the theme
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text('Go to Report', style: TextStyle(color: textColor)),
            ),
          ],
        ),
      ),
    );
  }
}
