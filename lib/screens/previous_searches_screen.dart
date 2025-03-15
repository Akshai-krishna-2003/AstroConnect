import 'package:flutter/material.dart';
import '../services/db_service.dart';
import 'dart:io';

class PreviousSearchesScreen extends StatefulWidget {
  @override
  _PreviousSearchesScreenState createState() => _PreviousSearchesScreenState();
}

class _PreviousSearchesScreenState extends State<PreviousSearchesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _individualHistory = [];
  List<Map<String, dynamic>> _compatibilityHistory = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    try {
      List<Map<String, dynamic>> individual = await _dbHelper.getHistory(
        "individual",
      );
      List<Map<String, dynamic>> compatibility = await _dbHelper.getHistory(
        "compatibility",
      );

      setState(() {
        _individualHistory = individual;
        _compatibilityHistory = compatibility;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print("❌ Error fetching history: $e");
    }
  }

  void _clearUserHistory() async {
    await _dbHelper.deleteUserHistory();
    _loadHistory();
  }

  Widget _buildHistoryList(
    List<Map<String, dynamic>> historyList,
    String type,
  ) {
    return ExpansionTile(
      title: Text(
        type,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      children:
          historyList.isEmpty
              ? [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "No history available.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ]
              : historyList.map((history) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "👤 Name: ${history['name']}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("📅 DOB: ${history['dob']}"),
                        Text("⏳ Time: ${history['time_of_birth']}"),
                        Text("📍 Place: ${history['place_of_birth']}"),
                        if (history['image_path'] != null &&
                            File(history['image_path']).existsSync())
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(history['image_path']),
                                width: double.infinity,
                                height: 200, // Increased height for better fit
                                fit:
                                    BoxFit.cover, // Ensures image fits properly
                              ),
                            ),
                          ),
                        SizedBox(height: 5),
                        Text(
                          "🔮 Prediction:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: 150, // Fixed height for scrollable response
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Text(history['response']),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📜 Previous Searches")),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        _buildHistoryList(
                          _individualHistory,
                          "🔮 Individual Horoscope History",
                        ),
                        _buildHistoryList(
                          _compatibilityHistory,
                          "💑 Compatibility History",
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: ElevatedButton(
                      onPressed: _clearUserHistory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text("🗑️ Clear My History"),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
    );
  }
}
