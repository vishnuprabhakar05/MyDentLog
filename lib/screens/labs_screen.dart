import 'package:flutter/material.dart';
import 'package:my_dentlog_app/models/lab_model.dart';
import 'package:my_dentlog_app/services/firebase_service.dart';
import 'package:my_dentlog_app/config/lab_config.dart';

class LabsScreen extends StatefulWidget {
  @override
  _LabsScreenState createState() => _LabsScreenState();
}

class _LabsScreenState extends State<LabsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  List<LabModel> _labs = [];
  List<LabModel> _filteredLabs = [];

  @override
  void initState() {
    super.initState();
    fetchLabs();
  }

  Future<void> fetchLabs() async {
    List<LabModel> labs = await _firebaseService.getLabs();
    setState(() {
      _labs = labs;
      _filteredLabs = labs;
    });
  }

  void _filterLabs(String query) {
    setState(() {
      _filteredLabs = _labs
          .where((lab) => lab.labName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showLabDialog({LabModel? lab}) {
    final _labNameController = TextEditingController(text: lab?.labName ?? "");
    final _phoneController = TextEditingController(text: lab?.phone ?? "");
    final _locationController = TextEditingController(text: lab?.location ?? "");
    List<String> selectedWorkTypes = List.from(lab?.workTypes ?? []);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(lab == null ? "Add New Lab" : "Edit Lab"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _labNameController,
                      decoration: InputDecoration(labelText: "Lab Name"),
                    ),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: "Phone"),
                      keyboardType: TextInputType.phone, // Numeric keyboard
                    ),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(labelText: "Location"),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      children: LabConfig.workTypes.map((work) {
                        return FilterChip(
                          label: Text(work),
                          selected: selectedWorkTypes.contains(work),
                          onSelected: (bool selected) {
                            setState(() {
                              selected
                                  ? selectedWorkTypes.add(work)
                                  : selectedWorkTypes.remove(work);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_labNameController.text.isNotEmpty) {
                      LabModel newLab = LabModel(
                        labId: lab?.labId,
                        labName: _labNameController.text,
                        phone: _phoneController.text,
                        location: _locationController.text,
                        workTypes: selectedWorkTypes,
                      );

                      if (lab == null) {
                        await _firebaseService.addLab(newLab);
                      } else {
                        await _firebaseService.updateLab(newLab);
                      }

                      fetchLabs();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(lab == null ? "Add" : "Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteLab(String labId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete this lab?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _firebaseService.deleteLab(labId);
              fetchLabs();
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Labs")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search Labs",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _filterLabs,
            ),
          ),
          Expanded(
            child: _filteredLabs.isEmpty
                ? Center(child: Text("No labs found."))
                : ListView.builder(
                    itemCount: _filteredLabs.length,
                    itemBuilder: (context, index) {
                      LabModel lab = _filteredLabs[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Text(lab.labName),
                          subtitle: Text("${lab.phone ?? "No phone"} - ${lab.location ?? "No location"}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showLabDialog(lab: lab),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDeleteLab(lab.labId!),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLabDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
