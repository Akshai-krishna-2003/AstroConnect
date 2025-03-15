import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/huggingface2_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PartnerCompatibilityScreen extends StatefulWidget {
  @override
  _PartnerCompatibilityScreenState createState() =>
      _PartnerCompatibilityScreenState();
}

class _PartnerCompatibilityScreenState
    extends State<PartnerCompatibilityScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final HuggingFaceService _aiService = HuggingFaceService();

  final TextEditingController _brideNameController = TextEditingController();
  final TextEditingController _brideDobController = TextEditingController();
  final TextEditingController _brideTimeController = TextEditingController();
  final TextEditingController _bridePlaceController = TextEditingController();

  final TextEditingController _groomNameController = TextEditingController();
  final TextEditingController _groomDobController = TextEditingController();
  final TextEditingController _groomTimeController = TextEditingController();
  final TextEditingController _groomPlaceController = TextEditingController();

  bool _loading = false;

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        controller.text = pickedTime.format(context);
      });
    }
  }

  void _checkCompatibility() async {
    setState(() => _loading = true);

    String prompt =
        "Check the astrology compatibility between ${_brideNameController.text} "
        "and ${_groomNameController.text}. Bride details: DOB ${_brideDobController.text}, "
        "Time of Birth ${_brideTimeController.text}, Place of Birth ${_bridePlaceController.text}. "
        "Groom details: DOB ${_groomDobController.text}, Time of Birth ${_groomTimeController.text}, "
        "Place of Birth ${_groomPlaceController.text}. Provide a detailed compatibility analysis.";

    String response = await _aiService.getCompatibilityPrediction(prompt);
    response = response.replaceAll(prompt, "").trim();

    setState(() => _loading = false);

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _dbHelper.insertHistory({
        "user_id": userId,
        "name": "${_brideNameController.text} & ${_groomNameController.text}",
        "dob": "${_brideDobController.text} - ${_groomDobController.text}",
        "gender": "Both",
        "time_of_birth":
            "${_brideTimeController.text} - ${_groomTimeController.text}",
        "place_of_birth":
            "${_bridePlaceController.text} - ${_groomPlaceController.text}",
        "response": response,
        "type": "compatibility",
      });
    }

    _showResponsePopup(response);
  }

  void _showResponsePopup(String response) {
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
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            "💑 Compatibility Results",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[800],
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            response,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.amber[100],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    ).then((_) => _clearInputs());
  }

  void _clearInputs() {
    setState(() {
      _brideNameController.clear();
      _brideDobController.clear();
      _brideTimeController.clear();
      _bridePlaceController.clear();
      _groomNameController.clear();
      _groomDobController.clear();
      _groomTimeController.clear();
      _groomPlaceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "💑 Partner Compatibility",
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
            child: Column(
              children: [
                _buildSection(
                  title: "Bride Details",
                  nameController: _brideNameController,
                  dobController: _brideDobController,
                  timeController: _brideTimeController,
                  placeController: _bridePlaceController,
                ),
                SizedBox(height: 25),
                _buildSection(
                  title: "Groom Details",
                  nameController: _groomNameController,
                  dobController: _groomDobController,
                  timeController: _groomTimeController,
                  placeController: _groomPlaceController,
                ),
                SizedBox(height: 30),
                _loading
                    ? CircularProgressIndicator(color: Colors.amber[100])
                    : ElevatedButton(
                      onPressed: _checkCompatibility,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[800]!.withOpacity(0.8),
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Check Compatibility",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.amber[50],
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required TextEditingController nameController,
    required TextEditingController dobController,
    required TextEditingController timeController,
    required TextEditingController placeController,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.amber[100],
            ),
          ),
          SizedBox(height: 15),
          _buildInputField(
            controller: nameController,
            label: "Name",
            icon: Icons.person_outline,
          ),
          SizedBox(height: 15),
          _buildDateField(dobController),
          SizedBox(height: 15),
          _buildTimeField(timeController),
          SizedBox(height: 15),
          _buildInputField(
            controller: placeController,
            label: "Place of Birth",
            icon: Icons.location_on_outlined,
          ),
        ],
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

  Widget _buildDateField(TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      style: TextStyle(color: Colors.amber[50]),
      decoration: InputDecoration(
        labelText: "Date of Birth",
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
          onPressed: () => _selectDate(context, controller),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }

  Widget _buildTimeField(TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      style: TextStyle(color: Colors.amber[50]),
      decoration: InputDecoration(
        labelText: "Time of Birth",
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
          onPressed: () => _selectTime(context, controller),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }
}
