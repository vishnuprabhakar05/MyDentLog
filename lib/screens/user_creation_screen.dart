import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_dentlog_app/models/user_model.dart';
import 'package:my_dentlog_app/services/firebase_service.dart';
import 'package:my_dentlog_app/controllers/user_controller.dart';
import 'package:my_dentlog_app/screens/login_screen.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  final UserController userController = UserController();
  final theme = Theme.of(Get.context!);

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  Future<void> _fetchUsers() async {
    List<UserModel> users = await FirebaseService.getUsers();
    setState(() {
      _users = users;
      _filteredUsers = users;
    });
  }

  void _filterUsers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _editUser(UserModel user) {
    TextEditingController nameController = TextEditingController(text: user.name);
    TextEditingController emailController = TextEditingController(text: user.email);
    String selectedRole = user.role;
    bool isAdmin = user.admin;

    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text("Edit User", style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Email/Staff ID",
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    dropdownColor: Colors.grey[900],
                    style: TextStyle(color: Colors.white),
                    items: ["Doctor", "Staff"]
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role, style: TextStyle(color: Colors.white)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null)
                        setDialogState(() => selectedRole = value);
                    },
                    decoration: InputDecoration(
                      labelText: "Role",
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  SwitchListTile(
                    title: Text("Admin Privileges", style: TextStyle(color: Colors.white)),
                    value: isAdmin,
                    activeColor: Colors.blue,
                    inactiveTrackColor: Colors.grey,
                    onChanged: (value) {
                      setDialogState(() => isAdmin = value!);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                UserModel updatedUser = UserModel(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  role: selectedRole,
                  admin: isAdmin,
                );
                await FirebaseService.updateUser(user.email, updatedUser);
                await _fetchUsers();
                Get.back();
              },
              child: Text("Update"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteUser(String email) async {
    bool confirm = await _showDeleteConfirmationDialog();
    if (confirm) {
      await FirebaseService.deleteUser(email);
      await _fetchUsers();
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await Get.dialog(
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text("Delete User", style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
              content: Text("Are you sure you want to delete this user?", style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text("Cancel", style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  child: Text("Delete", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  void _showUserCreationDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    String selectedRole = "Doctor";
    bool isAdmin = false;

    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text("Create New User", style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Email/Staff ID",
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    dropdownColor: Colors.grey[900],
                    style: TextStyle(color: Colors.white),
                    items: ["Doctor", "Staff"]
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role, style: TextStyle(color: Colors.white)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null)
                        setDialogState(() => selectedRole = value);
                    },
                    decoration: InputDecoration(
                      labelText: "Role",
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  SwitchListTile(
                    title: Text("Admin Privileges", style: TextStyle(color: Colors.white)),
                    value: isAdmin,
                    activeColor: Colors.blue,
                    inactiveTrackColor: Colors.grey,
                    onChanged: (value) {
                      setDialogState(() => isAdmin = value!);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    emailController.text.trim().isEmpty) {
                  Get.snackbar(
                    "Error",
                    "Please enter all details",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                String name = nameController.text
                    .trim()
                    .split(" ")
                    .map((word) => word.isNotEmpty
                        ? word[0].toUpperCase() +
                            word.substring(1).toLowerCase()
                        : "")
                    .join(" ");

                if (selectedRole.toLowerCase() == "doctor" &&
                    !name.toLowerCase().startsWith("dr. ")) {
                  name = "Dr. $name";
                }

                await userController.createUser(
                  name,
                  emailController.text.trim(),
                  isAdmin,
                  selectedRole,
                );
                await _fetchUsers();
                
                bool addMore = await _showAddMoreDialog();
                if (addMore) {
                  nameController.clear();
                  emailController.clear();
                  setState(() {
                    selectedRole = "Doctor";
                    isAdmin = false;
                  });
                } else {
                  Get.back();
                }
              },
              child: Text("Create"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showAddMoreDialog() async {
    return await Get.dialog<bool>(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text("Success", style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
          content: Text("User created successfully! Add another user?", style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text("No", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: Text("Yes"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.offAll(() => LoginScreen()),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "User Management",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search users...",
                          hintStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: _filteredUsers.isEmpty
                            ? Center(
                                child: Text(
                                  "No users found",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: EdgeInsets.all(16),
                                itemCount: _filteredUsers.length,
                                separatorBuilder: (_, __) => Divider(
                                  color: Colors.white.withOpacity(0.3),
                                  height: 16,
                                ),
                                itemBuilder: (context, index) {
                                  UserModel user = _filteredUsers[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                    tileColor: Colors.white.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue.shade800,
                                      child: Text(
                                        user.name[0].toUpperCase(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    title: Text(
                                      user.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${user.email} • ${user.role}",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                        if (user.admin)
                                          Container(
                                            margin: EdgeInsets.only(top: 4),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade800,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              "ADMIN",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Colors.blue.shade200),
                                          onPressed: () => _editUser(user),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red.shade200),
                                          onPressed: () => _deleteUser(user.email),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUserCreationDialog,
        backgroundColor: Colors.blue.shade800,
        child: Icon(Icons.add, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}