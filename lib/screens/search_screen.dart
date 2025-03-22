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

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Patients'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search by OP No, Name, Phone, or Place",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterPatients,
            ),
          ),
          Expanded(
            child: patientProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredPatients.isEmpty
                    ? Center(child: Text("No patients found"))
                    : ListView.builder(
                        itemCount: filteredPatients.length,
                        itemBuilder: (context, index) {
                          return PatientListItem(
                              patient: filteredPatients[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InputScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: "Create New Patient",
      ),
    );
  }
}
