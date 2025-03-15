import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/huggingface_service.dart';
import '../services/db_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AstrologyInputScreen extends StatefulWidget {
  @override
  _AstrologyInputScreenState createState() => _AstrologyInputScreenState();
}

class _AstrologyInputScreenState extends State<AstrologyInputScreen> {
  final MistralService _apiService = MistralService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _pobController = TextEditingController();

  bool _isLoading = false;
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  void _fetchAstrologyResponse() async {
    if (_nameController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _timeController.text.isEmpty ||
        _pobController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String result = await _apiService.getAstrologyResponse(
      _nameController.text,
      _dobController.text,
      _timeController.text,
      _pobController.text,
    );

    setState(() {
      _isLoading = false;
    });

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("❌ Error: No user ID found.");
      return;
    }

    _dbHelper.insertHistory({
      "user_id": userId,
      "name": _nameController.text,
      "dob": _dobController.text,
      "gender": "N/A",
      "time_of_birth": _timeController.text,
      "place_of_birth": _pobController.text,
      "response": result,
      "image_path": _selectedImage?.path,
      "type": "individual",
    });

    print("✅ Successfully stored individual astrology data for user: $userId");

    _showResponsePopup(result, _selectedImage);
  }

  void _showResponsePopup(String response, File? image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.75,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.red, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                if (image != null)
                  Container(
                    width: double.infinity,
                    height: 250, // Increased height for better fit
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        image,
                        fit: BoxFit.cover, // Ensures proper fit
                      ),
                    ),
                  ),
                SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          "🔮 Astrology Insights",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(response, textAlign: TextAlign.left),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Astrology Insights")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Enter Your Name"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _dobController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Select Date of Birth",
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _timeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Select Time of Birth",
                suffixIcon: IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () => _selectTime(context),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _pobController,
              decoration: InputDecoration(labelText: "Enter Place of Birth"),
            ),
            SizedBox(height: 10),

            // Image Selection Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera),
                  label: Text("Take Photo"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.image),
                  label: Text("Pick from Gallery"),
                ),
              ],
            ),

            // Display Selected Image
            if (_selectedImage != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover, // Ensures image fits properly
                    ),
                  ),
                ),
              ),

            SizedBox(height: 16),

            // Loading Indicator
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: _fetchAstrologyResponse,
                  child: Text("Get Astrology Insights"),
                ),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
