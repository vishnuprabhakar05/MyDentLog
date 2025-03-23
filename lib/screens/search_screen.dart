import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/patient_list_item.dart';
import '../screens/login_screen.dart';
import '../screens/input_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List filteredPatients = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider =
          Provider.of<PatientProvider>(context, listen: false);
      await provider.fetchPatients();
      setState(() {
        filteredPatients = provider.patients;
      });
    });
  }

  void _filterPatients(String query) {
    final provider = Provider.of<PatientProvider>(context, listen: false);
    setState(() {
      if (query.isEmpty) {
        filteredPatients = provider.patients;
      } else {
        filteredPatients = provider.patients
            .where((patient) =>
                patient.name.toLowerCase().contains(query.toLowerCase()) ||
                patient.opNo.toLowerCase().contains(query.toLowerCase()) ||
                patient.phone.toLowerCase().contains(query.toLowerCase()) ||
                patient.place.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _logout(BuildContext context) {
    Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      /// Gradient Background
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blueAccent.shade200],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// 🌟 Glassmorphism Card for Search & Logout
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            /// 🔍 Search Bar
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "Search OP No, Name, Phone, Place",
                                  hintStyle: TextStyle(color: Colors.white70),
                                  prefixIcon: Icon(Icons.search, color: Colors.white),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.2),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: _filterPatients,
                              ),
                            ),

                            SizedBox(width: 10),

                            /// 🚪 Logout Button
                            IconButton(
                              icon: Icon(Icons.logout, color: Colors.white),
                              onPressed: () => _logout(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                /// 📋 Patient List
                Expanded(
                  child: patientProvider.isLoading
                      ? Center(child: CircularProgressIndicator(color: Colors.white))
                      : filteredPatients.isEmpty
                          ? Center(child: Text("No patients found", style: TextStyle(color: Colors.white)))
                          : ListView.builder(
                              itemCount: filteredPatients.length,
                              itemBuilder: (context, index) {
                                return PatientListItem(patient: filteredPatients[index]);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),

      /// ➕ Floating Button for New Patient
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => InputScreen())),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("New Patient", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent.shade700,
      ),
    );
  }
}
