import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  File? _image;
  String _username = '';
  String _email = '';
  String _password = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    User? user = _auth.currentUser;
    if (user == null) {
      // Handle the case where no user is signed in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user is currently signed in')),
      );
      return;
    }

    DocumentSnapshot adminData = await _firestore.collection('users').doc(user.uid).get();

    if (adminData.exists && adminData['userType'] == 'admin') {
      setState(() {
        _username = adminData['username'] ?? '';
        _email = user.email ?? '';
      });
    } else {
      // Handle case where the user is not an admin
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not an admin')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _scanAndAddInfo() async {
    if (_image == null) return;

    // Upload image to Firebase Storage
    String fileName = 'plants/${DateTime.now().millisecondsSinceEpoch}.png';
    UploadTask uploadTask = _storage.ref().child(fileName).putFile(_image!);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    // Assume the disease detection process returns "Leaf Spot"
    String detectedDisease = 'Leaf Spot';

    // Add the scanned data to Firestore
    await _firestore.collection('plant_diseases').add({
      'image_url': downloadUrl,
      'disease_name': detectedDisease,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Disease detected: $detectedDisease. Data saved.')),
    );
  }

  Future<void> _updateAccount() async {
    User? user = _auth.currentUser;
    if (user == null) {
      // Handle the case where no user is signed in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user is currently signed in')),
      );
      return;
    }

    if (_email.isNotEmpty) {
      await user.updateEmail(_email);
    }
    if (_password.isNotEmpty) {
      await user.updatePassword(_password);
    }

    await _firestore.collection('users').doc(user.uid).update({
      'username': _username,
      'email': _email,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Account updated successfully.')),
    );
  }

  Widget _buildImageUploadTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _image == null
            ? Text('No image selected.')
            : Image.file(_image!),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Pick an Image'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _scanAndAddInfo,
          child: Text('Scan and Add Info'),
        ),
      ],
    );
  }

  Widget _buildAccountUpdateTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Username'),
            onChanged: (value) {
              setState(() {
                _username = value;
              });
            },
            controller: TextEditingController(text: _username),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Email'),
            onChanged: (value) {
              setState(() {
                _email = value;
              });
            },
            controller: TextEditingController(text: _email),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            onChanged: (value) {
              setState(() {
                _password = value;
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _updateAccount,
            child: Text('Update Account'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Screen'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Upload Image'),
            Tab(text: 'Update Account'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildImageUploadTab(),
          _buildAccountUpdateTab(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}
