import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _image;
  String? _username;
  String? _email;

  // Controllers for the input fields
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    try {
      String userId = _auth.currentUser!.uid;
      String fileName =
          'images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = _storage.ref().child(fileName).putFile(_image!);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Save the image URL, username, city, district, and phone number in Firestore
      await _firestore.collection('images').add({
        'userId': userId,
        'username': _auth.currentUser!.email,
        'imageUrl': downloadUrl,
        'city': _cityController.text,
        'district': _districtController.text,
        'phoneNumber': _phoneController.text,
      });

      // Reset the input fields
      setState(() {
        _image = null;
        _cityController.clear();
        _districtController.clear();
        _phoneController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  Future<void> _updateAccountInfo() async {
    try {
      String userId = _auth.currentUser!.uid;

      // Update email
      if (_email != null && _email!.isNotEmpty) {
        await _auth.currentUser!.updateEmail(_email!);
      }

      // Update username in Firestore
      if (_username != null && _username!.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update({
          'username': _username,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account information updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update account information: $e')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUserUploads() async {
    String userId = _auth.currentUser!.uid;
    QuerySnapshot snapshot = await _firestore
        .collection('images')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Updated length to 3 for the new tab
      child: Scaffold(
        appBar: AppBar(
          title: Text('User Screen'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Upload Image'),
              Tab(text: 'Update Account'),
              Tab(text: 'My Uploads'), // New Tab
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Upload Image Tab
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _image == null
                      ? Text('No image selected.')
                      : Image.file(_image!),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Pick Image'),
                  ),
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(labelText: 'City'),
                  ),
                  TextFormField(
                    controller: _districtController,
                    decoration: InputDecoration(labelText: 'District'),
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _uploadImage,
                    child: Text('Upload Image'),
                  ),
                ],
              ),
            ),

            // Update Account Tab
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Username'),
                    onChanged: (value) => _username = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    onChanged: (value) => _email = value,
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _updateAccountInfo,
                    child: Text('Update Account'),
                  ),
                ],
              ),
            ),

            // My Uploads Tab
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchUserUploads(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<Map<String, dynamic>> uploads = snapshot.data!;

                if (uploads.isEmpty) {
                  return Center(child: Text('No uploads found.'));
                }

                return ListView.builder(
                  itemCount: uploads.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> upload = uploads[index];
                    return ListTile(
                      leading: Image.network(upload['imageUrl']),
                      title: Text(upload['username']),
                      subtitle: Text('City: ${upload['city']}, District: ${upload['district']}, Phone: ${upload['phoneNumber']}'),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
