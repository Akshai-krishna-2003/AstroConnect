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
  FalconService _apiService = FalconService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _pobController = TextEditingController();

  bool _isLoading = false;
  File? _selectedImage;

  void _resetFields() {
    setState(() {
      _nameController.clear();
      _dobController.clear();
      _timeController.clear();
      _pobController.clear();
      _selectedImage = null;
    });
  }

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

    setState(() => _isLoading = true);

    try {
      String result = await _apiService.getAstrologyResponse(
        _nameController.text,
        _dobController.text,
        _timeController.text,
        _pobController.text,
      );

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await _dbHelper.insertHistory({
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
      }

      _showResponsePopup(result, _selectedImage);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showResponsePopup(String response, File? image) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  if (image != null)
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amber[100]!),
                      ),
                      child: ClipOval(
                        child: Image.file(image, fit: BoxFit.cover),
                      ),
                    ),
                  SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        response,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.amber[100],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    ).then((_) => _resetFields());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Astrology Insights',
          style: TextStyle(
            color: Colors.amber[100],
            fontWeight: FontWeight.w500,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.amber[100]),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/internal_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 80),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _buildInputField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                      ),
                      SizedBox(height: 20),
                      _buildDateField(),
                      SizedBox(height: 20),
                      _buildTimeField(),
                      SizedBox(height: 20),
                      _buildInputField(
                        controller: _pobController,
                        label: 'Place of Birth',
                        icon: Icons.location_on_outlined,
                      ),
                      SizedBox(height: 30),
                      _buildImageSection(),
                      SizedBox(height: 30),
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.amber[100])
                          : ElevatedButton(
                            onPressed: _fetchAstrologyResponse,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[800]!.withOpacity(
                                0.8,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Generate Insights',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.amber[50],
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.amber[50]),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber[100]),
        prefixIcon: Icon(icon, color: Colors.amber[100]),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: _dobController,
      readOnly: true,
      style: TextStyle(color: Colors.amber[50]),
      decoration: InputDecoration(
        labelText: 'Date of Birth',
        labelStyle: TextStyle(color: Colors.amber[100]),
        prefixIcon: Icon(
          Icons.calendar_month_outlined,
          color: Colors.amber[100],
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(Icons.edit_outlined, color: Colors.amber[100]),
          onPressed: () => _selectDate(context),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }

  Widget _buildTimeField() {
    return TextField(
      controller: _timeController,
      readOnly: true,
      style: TextStyle(color: Colors.amber[50]),
      decoration: InputDecoration(
        labelText: 'Time of Birth',
        labelStyle: TextStyle(color: Colors.amber[100]),
        prefixIcon: Icon(Icons.access_time_outlined, color: Colors.amber[100]),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(Icons.edit_outlined, color: Colors.amber[100]),
          onPressed: () => _selectTime(context),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildImageButton(
              icon: Icons.camera_alt_outlined,
              label: 'Camera',
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            SizedBox(width: 15),
            _buildImageButton(
              icon: Icons.photo_library_outlined,
              label: 'Gallery',
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
        SizedBox(height: 20),
        if (_selectedImage != null)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber[100]!, width: 3),
            ),
            child: ClipOval(
              child: Image.file(
                _selectedImage!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: Colors.amber[50]),
      label: Text(label, style: TextStyle(color: Colors.amber[50])),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber[800]!.withOpacity(0.7),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
