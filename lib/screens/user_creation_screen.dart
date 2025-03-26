import 'package:flutter/material.dart';
import 'package:my_dentlog_app/models/user_model.dart';
import 'package:my_dentlog_app/services/firebase_service.dart';
import 'package:my_dentlog_app/controllers/user_controller.dart';


class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  final UserController userController = UserController();

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
    TextEditingController nameController =
        TextEditingController(text: user.name);
    TextEditingController emailController =
        TextEditingController(text: user.email);
    String selectedRole = user.role;
    bool isAdmin = user.admin;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text("Edit User"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Name")),
                SizedBox(height: 10),
                TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: "Email/Staff ID")),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: ["Doctor", "Staff"]
                      .map((role) =>
                          DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null)
                      setDialogState(() => selectedRole = value);
                  },
                  decoration: InputDecoration(labelText: "Role"),
                ),
                SizedBox(height: 10),
                CheckboxListTile(
                  title: Text("Admin"),
                  value: isAdmin,
                  onChanged: (value) {
                    if (value != null) setDialogState(() => isAdmin = value);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel")),
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
                  Navigator.pop(context);
                },
                child: Text("Update"),
              ),
            ],
          );
        },
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
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Delete User"),
            content: Text("Are you sure you want to delete this user?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Cancel")),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("Delete", style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;
  }

  void _showUserCreationDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    String selectedRole = "Doctor";
    bool isAdmin = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text("Create New User"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Name")),
                SizedBox(height: 10),
                TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: "Email/Staff ID")),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: ["Doctor", "Staff"]
                      .map((role) =>
                          DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null)
                      setDialogState(() => selectedRole = value);
                  },
                  decoration: InputDecoration(labelText: "Role"),
                ),
                SizedBox(height: 10),
                CheckboxListTile(
                  title: Text("Admin"),
                  value: isAdmin,
                  onChanged: (value) {
                    if (value != null) setDialogState(() => isAdmin = value);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty ||
                      emailController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("⚠️ Please enter all details")));
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
                    name = "Dr.$name";
                  }

                  await userController.createUser(name,emailController.text.trim(),isAdmin,selectedRole);
                  await _fetchUsers();
                  Navigator.pop(context);
                },
                child: Text("Create"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Management")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Users",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: "Search by name or email"),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _filteredUsers.length,
                separatorBuilder: (_, __) => Divider(),
                itemBuilder: (context, index) {
                  UserModel user = _filteredUsers[index];
                  return ListTile(
                    title: Text(user.name,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${user.email} • ${user.role}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editUser(user)),
                        IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteUser(user.email)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUserCreationDialog,
        child: Icon(Icons.add),
        tooltip: "Create New User",
      ),
    );
  }
}
