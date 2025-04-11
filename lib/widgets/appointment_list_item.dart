import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_dentlog_app/models/appointment_model.dart';
import '../controllers/appointment_controller.dart';
import '../screens/add_edit_appointment_screen.dart';

class AppointmentListItem extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onComplete;

  const AppointmentListItem({
    super.key,
    required this.appointment,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.tryParse(appointment.appointDateTime) ?? DateTime.now();
    final formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
    final formattedTime = DateFormat('hh:mm a').format(dateTime);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.find<AppointmentController>().loadAppointmentData(appointment);
          Get.to(() => AddEditAppointmentScreen());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appointment.patientName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Chip(
                    label: Text(
                      appointment.completed ? 'Completed' : 'Upcoming',
                      style: TextStyle(
                        color: appointment.completed ? Colors.green : Colors.orange,
                      ),
                    ),
                    backgroundColor: appointment.completed 
                        ? Colors.green.shade50 
                        : Colors.orange.shade50,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'OP No: ${appointment.opNo}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'With ${appointment.doctorName}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(formattedDate),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(formattedTime),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Reason: ${appointment.reason}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!appointment.completed)
                    TextButton(
                      onPressed: onComplete,
                      child: const Text(
                        'Mark Complete',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      Get.find<AppointmentController>().loadAppointmentData(appointment);
                      Get.to(() => AddEditAppointmentScreen());
                    },
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
