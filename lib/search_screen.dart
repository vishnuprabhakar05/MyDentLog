import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'input_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("patient_details");
  List<Map<String, dynamic>> _searchResults = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAllPatients();
  }

  void _fetchAllPatients() {
    _dbRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> patients = event.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> patientList = patients.entries.map((entry) {
          return {
            "OP_NO": entry.key.toString(),
            ...Map<String, dynamic>.from(entry.value as Map)
          };
        }).toList();

        setState(() {
          _searchResults = patientList;
        });
      }
    });
  }

  void _searchPatients(String query) {
    _dbRef.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> patients = event.snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> filteredPatients = patients.entries
            .map((entry) => {
                  "OP_NO": entry.key.toString(),
                  ...Map<String, dynamic>.from(entry.value as Map)
            })
            .where((patient) =>
                patient["NAME"].toString().toLowerCase().contains(query.toLowerCase()) ||
                patient["PHONE"].toString().contains(query) ||
                patient["PLACE"].toString().toLowerCase().contains(query.toLowerCase()) ||
                patient["OP_NO"].contains(query))
            .toList();

        setState(() {
          _searchResults = filteredPatients;
        });
      }
    }).catchError((error) {
      print("Error fetching data: $error");
    });
  }

  void _deletePatient(String opNo) {
    _dbRef.child(opNo).remove().then((_) {
      setState(() {
        _searchResults.removeWhere((patient) => patient["OP_NO"] == opNo);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Patient deleted successfully")));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete: $error")));
    });
  }

  void _navigateToInputScreen(Map<String, dynamic>? patientData) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InputScreen(patientData: patientData)),
    ).then((_) => _fetchAllPatients()); // Refresh after returning
  }

  void _viewCaseSheet(String? caseSheetUrl) async {
    if (caseSheetUrl != null && caseSheetUrl.isNotEmpty) {
      Uri url = Uri.parse(caseSheetUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not open case sheet")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No case sheet available")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Patients")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _searchPatients, // ✅ Live search while typing
              decoration: InputDecoration(
                labelText: "Search by OP No, Name, Phone, or Place",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchPatients(_searchController.text.trim()),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final patient = _searchResults[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(patient["NAME"]),
                      subtitle: Text("OP No: ${patient["OP_NO"]} | Phone: ${patient["PHONE"]} | Place: ${patient["PLACE"]}"),
                      onTap: () => _navigateToInputScreen(patient),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (patient["CASE_SHEET"] != null && patient["CASE_SHEET"].isNotEmpty)
                            TextButton(
                              onPressed: () => _viewCaseSheet(patient["CASE_SHEET"]),
                              child: Text(
                                "View Case Sheet",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletePatient(patient["OP_NO"]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToInputScreen(null),
        child: Icon(Icons.add),
      ),
    );
  }
}
