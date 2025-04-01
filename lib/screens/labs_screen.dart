import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:my_dentlog_app/models/lab_model.dart';
import 'package:my_dentlog_app/services/firebase_service.dart';
import 'package:my_dentlog_app/config/lab_config.dart';
import 'dart:ui';

class LabsScreen extends StatefulWidget {
  @override
  _LabsScreenState createState() => _LabsScreenState();
}

class _LabsScreenState extends State<LabsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<LabModel> _labs = [];
  List<LabModel> _filteredLabs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLabs();
  }

  Future<void> _loadLabs() async {
    setState(() => _isLoading = true);
    try {
      final labs = await _firebaseService.getLabs();
      setState(() {
        _labs = labs;
        _filteredLabs = labs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Failed to load labs: ${e.toString()}');
    }
  }

  void _filterLabs(String query) {
    setState(() {
      _filteredLabs = _labs
          .where((lab) => lab.labName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showLabDialog({LabModel? lab}) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: lab?.labName ?? '');
    final _phoneController = TextEditingController(text: lab?.phone ?? '');
    final _locationController = TextEditingController(text: lab?.location ?? '');
    List<String> _selectedWorkTypes = List.from(lab?.workTypes ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        lab == null ? 'Add New Lab' : 'Edit Lab',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Lab Name',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          prefixIcon: Icon(Icons.business, color: Colors.white),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _phoneController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          prefixIcon: Icon(Icons.phone, color: Colors.white),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _locationController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Location',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          prefixIcon: Icon(Icons.location_on, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Work Types',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: LabConfig.workTypes.map((work) {
                          return InputChip(
                            label: Text(work, style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.white 
                                  : Colors.blue.shade800,
                            )),

                            selected: _selectedWorkTypes.contains(work),
                            onSelected: (selected) {
                              setState(() {
                                selected
                                    ? _selectedWorkTypes.add(work)
                                    : _selectedWorkTypes.remove(work);
                              });
                            },
                            selectedColor: Colors.blueAccent.shade700.withOpacity(0.5),
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: _selectedWorkTypes.contains(work) 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                            ),
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: _selectedWorkTypes.contains(work)
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.3),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel', style: TextStyle(color: Colors.white)),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                side: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ?? false) {
                                  Navigator.pop(context);
                                  final newLab = LabModel(
                                    labId: lab?.labId,
                                    labName: _nameController.text,
                                    phone: _phoneController.text,
                                    location: _locationController.text,
                                    workTypes: _selectedWorkTypes,
                                  );

                                  try {
                                    if (lab == null) {
                                      await _firebaseService.addLab(newLab);
                                    } else {
                                      await _firebaseService.updateLab(newLab);
                                    }
                                    _loadLabs();
                                  } catch (e) {
                                    _showErrorSnackbar('Failed to save lab');
                                  }
                                }
                              },
                              child: Text(lab == null ? 'Add Lab' : 'Update'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                backgroundColor: Colors.blueAccent.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteLab(String labId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          title: Text('Delete Lab', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to delete this lab?', 
              style: TextStyle(color: Colors.white.withOpacity(0.8))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red[200]),
              ),
            ),
          ],
        ),
      ),
    );

    if (result ?? false) {
      try {
        await _firebaseService.deleteLab(labId);
        _loadLabs();
        _showSuccessSnackbar('Lab deleted successfully');
      } catch (e) {
        _showErrorSnackbar('Failed to delete lab');
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background like LoginScreen
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blueAccent.shade200],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Main content with blur effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: SafeArea(
              child: Column(
                children: [
                  // AppBar replacement
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            'Dental Labs',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh, color: Colors.white),
                          onPressed: _loadLabs,
                        ),
                      ],
                    ),
                  ),

                  // Search field
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Search labs...',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      ),
                      onChanged: _filterLabs,
                    ),
                  ),

                  // Labs list
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : _filteredLabs.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.business_outlined,
                                    size: 60,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No labs found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  if (_searchController.text.isNotEmpty)
                                    TextButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        _filterLabs('');
                                      },
                                      child: Text(
                                        'Clear search',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                ],
                              )
                            : RefreshIndicator(
                                onRefresh: _loadLabs,
                                backgroundColor: Colors.white.withOpacity(0.9),
                                color: Colors.blueAccent.shade700,
                                child: AnimationLimiter(
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: _filteredLabs.length,
                                    itemBuilder: (context, index) {
                                      final lab = _filteredLabs[index];
                                      return AnimationConfiguration.staggeredList(
                                        position: index,
                                        duration: Duration(milliseconds: 375),
                                        child: SlideAnimation(
                                          verticalOffset: 50,
                                          child: FadeInAnimation(
                                            child: Container(
                                              margin: EdgeInsets.only(bottom: 12),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.3),
                                                ),
                                              ),
                                              child: ListTile(
                                                contentPadding: EdgeInsets.symmetric(
                                                    horizontal: 16, vertical: 12),
                                                leading: Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Icon(
                                                    Icons.business_center,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                title: Text(
                                                  lab.labName,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    if (lab.phone?.isNotEmpty ?? false)
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 4),
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.phone, size: 14, color: Colors.white.withOpacity(0.7)),
                                                            SizedBox(width: 6),
                                                            Text(lab.phone!, style: TextStyle(color: Colors.white.withOpacity(0.7))),
                                                          ],
                                                        ),
                                                      ),
                                                    if (lab.location?.isNotEmpty ?? false)
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 4),
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.location_on, size: 14, color: Colors.white.withOpacity(0.7)),
                                                            SizedBox(width: 6),
                                                            Text(lab.location!, style: TextStyle(color: Colors.white.withOpacity(0.7))),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                trailing: PopupMenuButton(
                                                  icon: Icon(Icons.more_vert, color: Colors.white),
                                                  itemBuilder: (context) => [
                                                    PopupMenuItem(
                                                      child: Text('Edit', style: TextStyle(color: Colors.blue.shade900)),
                                                      value: 'edit',
                                                    ),
                                                    PopupMenuItem(
                                                      child: Text(
                                                        'Delete',
                                                        style: TextStyle(color: Colors.red),
                                                      ),
                                                      value: 'delete',
                                                    ),
                                                  ],
                                                  onSelected: (value) {
                                                    if (value == 'edit') {
                                                      _showLabDialog(lab: lab);
                                                    } else if (value == 'delete') {
                                                      _confirmDeleteLab(lab.labId!);
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLabDialog(),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blueAccent.shade700,
        elevation: 2,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}