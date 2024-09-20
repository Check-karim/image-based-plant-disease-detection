import 'package:flutter/material.dart';
import 'login.dart'; // Import your login screen widget
import 'register.dart'; // Import your register screen widget
import 'package:gpt_vision_leaf_detect/constants/constants.dart';

// const Color themeColor = Color(0xFF4CAF50); // Green theme color
// const Color textColor = Colors.white;

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text(
          'PLANT DISEASES DETECTION APP',
          style: TextStyle(color: textColor),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Display the image below the AppBar
            Image.asset(
              'assets/images/pick1.png', // Make sure to add this image to your assets
              height: 200,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Navigate to the login screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
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
              child: Text('Login', style: TextStyle(color: textColor)),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Navigate to the registration screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RegisterScreen(),
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
              child: Text('Register', style: TextStyle(color: textColor)),
            ),
          ],
        ),
      ),
    );
  }
}
