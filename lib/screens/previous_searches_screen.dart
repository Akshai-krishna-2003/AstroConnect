import 'package:flutter/material.dart';
import '../services/db_service.dart';
import 'dart:io';
import 'package:intl/intl.dart';

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
      final individual = await _dbHelper.getHistory("individual");
      final compatibility = await _dbHelper.getHistory("compatibility");
      setState(() {
        _individualHistory = individual;
        _compatibilityHistory = compatibility;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      print("❌ Error fetching history: $e");
    }
  }

  void _clearUserHistory() async {
    await _dbHelper.deleteUserHistory();
    _loadHistory();
  }

  Widget _buildHistorySection(
    String title,
    List<Map<String, dynamic>> history,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.amber[100],
              letterSpacing: 1.1,
            ),
          ),
        ),
        if (history.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "No records found",
              style: TextStyle(color: Colors.amber[100]!.withOpacity(0.6)),
            ),
          )
        else
          ...history.map((entry) => _buildHistoryCard(entry)).toList(),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> history) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        collapsedTextColor: Colors.amber[100],
        textColor: Colors.amber[50],
        iconColor: Colors.amber[100],
        collapsedIconColor: Colors.amber[100],
        title: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          leading: Icon(
            history['type'] == 'individual' ? Icons.person : Icons.favorite,
            color: Colors.amber[100],
          ),
          title: Text(
            history['name'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.amber[100],
            ),
          ),
          subtitle: Text(
            DateFormat('MMM dd, yyyy').format(DateTime.now()),
            style: TextStyle(color: Colors.amber[100]!.withOpacity(0.7)),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow("Date of Birth", history['dob']),
                _buildDetailRow("Time of Birth", history['time_of_birth']),
                _buildDetailRow("Place of Birth", history['place_of_birth']),
                if (history['image_path'] != null &&
                    File(history['image_path']).existsSync())
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(history['image_path']),
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                const SizedBox(height: 15),
                Text(
                  "Prediction:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.amber[100],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      history['response'],
                      style: TextStyle(
                        color: Colors.amber[100]!.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              color: Colors.amber[100],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.amber[100]!.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search History",
          style: TextStyle(
            color: Colors.amber[100],
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.amber[100]),
      ),
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/internal_bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child:
                _loading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.amber[100],
                      ),
                    )
                    : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHistorySection(
                                  "Individual Readings",
                                  _individualHistory,
                                ),
                                _buildHistorySection(
                                  "Compatibility Checks",
                                  _compatibilityHistory,
                                ),
                                SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.delete_outline, size: 20),
                            label: Text("Clear All History"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[800]!.withOpacity(
                                0.8,
                              ),
                              foregroundColor: Colors.amber[50],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: _clearUserHistory,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
