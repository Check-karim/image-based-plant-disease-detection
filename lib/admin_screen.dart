import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _diseasePrediction;
  final TextEditingController _diseaseController = TextEditingController();

  Future<void> _requestPermissions() async {
    final status = await Permission.photos.request();

    if (status.isGranted) {
      await _pickImage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission to access photos is required')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        await _predictDisease();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected')),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image')),
      );
    }
  }

  Future<void> _predictDisease() async {
    if (_image == null) return;

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:5000/predict_disease'),
      );
      request.files
          .add(await http.MultipartFile.fromPath('image', _image!.path));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final result = jsonDecode(String.fromCharCodes(responseData));
      setState(() {
        _diseasePrediction = result['disease'];
      });
    } catch (e) {
      print('Error predicting disease: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error predicting disease')),
      );
    }
  }

  Future<void> _saveDiseaseInfo() async {
    final diseaseInfo = _diseaseController.text;

    if (_diseasePrediction == null || diseaseInfo.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/save_disease_info'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'disease': _diseasePrediction!,
          'info': diseaseInfo,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Disease information saved successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save information')),
        );
      }
    } catch (e) {
      print('Error saving disease info: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving disease info')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Dashboard'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Upload Image'),
              Tab(text: 'Disease Info'),
              Tab(text: 'Save Info'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _image != null
                      ? Image.file(_image!)
                      : Text('No image selected.'),
                  ElevatedButton(
                    onPressed: _requestPermissions,
                    child: Text('Pick Image'),
                  ),
                  if (_diseasePrediction != null)
                    Text('Disease Prediction: $_diseasePrediction'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _diseaseController,
                decoration: InputDecoration(
                  labelText: 'Add more information about the disease',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: _saveDiseaseInfo,
                child: Text('Save Disease Info'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
