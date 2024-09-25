import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gpt_vision_leaf_detect/constants/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add FirebaseAuth for logout functionality
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../services/api_service.dart';
import 'home.dart'; // Import the HomeScreen for navigation after logout

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  final apiService = ApiService();
  File? _selectedImage;
  String diseaseName = '';
  String diseasePrecautions = '';
  bool detecting = false;
  bool precautionLoading = false;

  // Reset information when selecting new image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _selectedImage = null;
      diseaseName = '';
      diseasePrecautions = '';
    });

    final pickedFile =
    await ImagePicker().pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to detect disease using the image
  detectDisease() async {
    setState(() {
      detecting = true;
    });
    try {
      diseaseName =
      await apiService.sendImageToGPT4Vision(image: _selectedImage!);
    } catch (error) {
      _showErrorSnackBar(error);
    } finally {
      setState(() {
        detecting = false;
      });
    }
  }

  // Function to show disease precautions
  showPrecautions() async {
    setState(() {
      precautionLoading = true;
    });
    try {
      if (diseasePrecautions == '') {
        diseasePrecautions =
        await apiService.sendMessageGPT(diseaseName: diseaseName);
      }
      _showSuccessDialog(diseaseName, diseasePrecautions);
    } catch (error) {
      _showErrorSnackBar(error);
    } finally {
      setState(() {
        precautionLoading = false;
      });
    }
  }

  // Show error message
  void _showErrorSnackBar(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error.toString()),
      backgroundColor: Colors.red,
    ));
  }

  // Show dialog with success information
  void _showSuccessDialog(String title, String content) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: title,
      desc: content,
      btnOkText: 'Got it',
      btnOkColor: themeColor,
      btnOkOnPress: () async {
        if (_selectedImage != null) {
          // Save the image, precautions, and date to Firebase
          await _savePrecautionAndImageToFirebase(
              diseaseName, diseasePrecautions, _selectedImage!);

          // Reset the state after saving to Firestore
          setState(() {
            _selectedImage = null; // Reset the selected image
            diseaseName = ''; // Reset the disease name
            diseasePrecautions = ''; // Reset the precautions
          });
        }
      },
    ).show();
  }

  // Function to save precautions and image to Firebase
  Future<void> _savePrecautionAndImageToFirebase(
      String diseaseName, String precautions, File imageFile) async {
    try {
      // Upload the image to Firebase Storage
      String imageUrl = await _uploadImageToFirebase(imageFile);

      // Save the data to Firestore
      await FirebaseFirestore.instance.collection('precautions').add({
        'diseaseName': diseaseName,
        'precautions': precautions,
        'imageUrl': imageUrl, // Store the uploaded image URL
        'date': DateTime.now(), // Store the current date
      });
      print('Precaution and image saved to Firebase');
    } catch (error) {
      _showErrorSnackBar('Failed to save precaution and image: $error');
    }
  }

  // Function to upload image to Firebase
  Future<String> _uploadImageToFirebase(File imageFile) async {
    try {
      // Create a unique file name for the image
      String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload the image to Firebase Storage
      UploadTask uploadTask =
      FirebaseStorage.instance.ref(fileName).putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get the image URL after upload
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (error) {
      _showErrorSnackBar('Image upload failed: $error');
      rethrow; // Re-throw to handle it in the calling method
    }
  }

  // Logout function to sign out the user and navigate to the home screen
  void _logout() async {
    await FirebaseAuth.instance.signOut(); // Log out the user
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false, // Clear the navigation stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Disease Detection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout, // Add logout button functionality
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.23,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(50.0),
                  ),
                  color: themeColor,
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.2,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(50.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        _pickImage(ImageSource.gallery);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'OPEN GALLERY',
                            style: TextStyle(color: textColor),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.image, color: textColor),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _pickImage(ImageSource.camera);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('START CAMERA',
                              style: TextStyle(color: textColor)),
                          const SizedBox(width: 10),
                          Icon(Icons.camera_alt, color: textColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _selectedImage == null
              ? Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Image.asset('assets/images/pick1.png'),
          )
              : Expanded(
            child: Container(
              width: double.infinity,
              decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (_selectedImage != null)
            detecting
                ? SpinKitWave(
              color: themeColor,
              size: 30,
            )
                : Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: 0, horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  detectDisease();
                },
                child: const Text(
                  'DETECT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (diseaseName != '')
            Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DefaultTextStyle(
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                        child: AnimatedTextKit(
                            isRepeatingAnimation: false,
                            repeatForever: false,
                            displayFullTextOnTap: true,
                            totalRepeatCount: 1,
                            animatedTexts: [
                              TyperAnimatedText(
                                diseaseName.trim(),
                              ),
                            ]),
                      )
                    ],
                  ),
                ),
                precautionLoading
                    ? const SpinKitWave(
                  color: Colors.blue,
                  size: 30,
                )
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  onPressed: () {
                    showPrecautions();
                  },
                  child: Text(
                    'PRECAUTION',
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
