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
    setState(() {
      _loading = true;
    });

    String prompt =
        "Check the astrology compatibility between ${_brideNameController.text} "
        "and ${_groomNameController.text}. Bride details: DOB ${_brideDobController.text}, "
        "Time of Birth ${_brideTimeController.text}, Place of Birth ${_bridePlaceController.text}. "
        "Groom details: DOB ${_groomDobController.text}, Time of Birth ${_groomTimeController.text}, "
        "Place of Birth ${_groomPlaceController.text}. Provide a detailed compatibility analysis.";

    String response = await _aiService.getCompatibilityPrediction(prompt);
    response = response.replaceAll(prompt, "").trim();

    setState(() {
      _loading = false;
    });

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("❌ Error: No user ID found. Skipping DB insert.");
      return;
    }

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

    _showResponsePopup(response);
  }

  void _showResponsePopup(String response) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.red, size: 28),
                    onPressed: () {
                      Navigator.pop(context);
                      _clearInputs();
                    },
                  ),
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
      appBar: AppBar(title: Text("💑 Partner Compatibility")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bride Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _brideNameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: _brideDobController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Date of Birth",
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, _brideDobController),
                ),
              ),
            ),
            TextField(
              controller: _brideTimeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Time of Birth",
                suffixIcon: IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () => _selectTime(context, _brideTimeController),
                ),
              ),
            ),
            TextField(
              controller: _bridePlaceController,
              decoration: InputDecoration(labelText: "Place of Birth"),
            ),

            SizedBox(height: 16),
            Text(
              "Groom Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _groomNameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: _groomDobController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Date of Birth",
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, _groomDobController),
                ),
              ),
            ),
            TextField(
              controller: _groomTimeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Time of Birth",
                suffixIcon: IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () => _selectTime(context, _groomTimeController),
                ),
              ),
            ),
            TextField(
              controller: _groomPlaceController,
              decoration: InputDecoration(labelText: "Place of Birth"),
            ),

            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkCompatibility,
              child: Text("Check Compatibility"),
            ),
            SizedBox(height: 16),
            _loading ? Center(child: CircularProgressIndicator()) : SizedBox(),
          ],
        ),
      ),
    );
  }
}
