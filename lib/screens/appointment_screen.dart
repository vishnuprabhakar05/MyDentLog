import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_dentlog_app/controllers/appointment_controller.dart';
import 'package:my_dentlog_app/widgets/appointment_list_item.dart';
import '../screens/add_edit_appointment_screen.dart';
import 'dart:ui';

class AppointmentScreen extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final AppointmentController _controller = Get.find();

  AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient (matches your search screen)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blueAccent.shade200],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Search bar with filter options
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            // Search bar
                            TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Search by patient, doctor, or reason",
                                hintStyle: TextStyle(color: Colors.white70),
                                prefixIcon: Icon(Icons.search, color: Colors.white),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: _controller.filterAppointments,
                            ),
                            const SizedBox(height: 10),
                            // Status filter chips
                            Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FilterChip(
                                  label: const Text('All', style: TextStyle(color: Colors.white)),
                                  selected: _controller.filteredAppointments.value == _controller.appointments.value,
                                  onSelected: (_) => _controller.filterByStatus(null),
                                  backgroundColor: Colors.blue.shade800,
                                  selectedColor: Colors.blueAccent,
                                ),
                                FilterChip(
                                  label: const Text('Upcoming', style: TextStyle(color: Colors.white)),
                                  selected: _controller.filteredAppointments.any((a) => !a.completed) &&
                                      _controller.filteredAppointments.any((a) => a.completed),
                                  onSelected: (_) => _controller.filterByStatus(false),
                                  backgroundColor: Colors.blue.shade800,
                                  selectedColor: Colors.blueAccent,
                                ),
                                FilterChip(
                                  label: const Text('Completed', style: TextStyle(color: Colors.white)),
                                  selected: _controller.filteredAppointments.isNotEmpty &&
                                      _controller.filteredAppointments.every((a) => a.completed),
                                  onSelected: (_) => _controller.filterByStatus(true),
                                  backgroundColor: Colors.blue.shade800,
                                  selectedColor: Colors.blueAccent,
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Appointment list
                Expanded(
                  child: Obx(() {
                    if (_controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    } else if (_controller.filteredAppointments.isEmpty) {
                      return Center(
                        child: Text(
                          _controller.appointments.isEmpty
                              ? "No appointments found"
                              : "No matching appointments",
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: _controller.filteredAppointments.length,
                        itemBuilder: (context, index) {
                          return AppointmentListItem(
                            appointment: _controller.filteredAppointments[index],
                            onComplete: () => _controller.toggleAppointmentStatus(
                              _controller.filteredAppointments[index].appointId,
                              _controller.filteredAppointments[index].completed,
                            ),
                          );
                        },
                      );
                    }
                  }),
                ),
              ],
            ),
          ),
        ],
      ),

      // Floating action button for adding new appointment
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _controller.clearForm();
          Get.to(() => AddEditAppointmentScreen());
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Appointment", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent.shade700,
      ),
    );
  }
}
