import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_dentlog_app/controllers/appointment_controller.dart';
import 'package:my_dentlog_app/models/appointment_model.dart';
import 'package:my_dentlog_app/models/patient_model.dart';
import 'package:my_dentlog_app/models/user_model.dart';
import 'package:my_dentlog_app/services/firebase_service.dart';

class AddEditAppointmentScreen extends StatefulWidget {
  const AddEditAppointmentScreen({super.key});

  @override
  State<AddEditAppointmentScreen> createState() => _AddEditAppointmentScreenState();
}

class _AddEditAppointmentScreenState extends State<AddEditAppointmentScreen> {
  final AppointmentController _controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  final opNoController = TextEditingController();
  final patientNameController = TextEditingController();
  final patientPhoneController = TextEditingController();
  final doctorNumberController = TextEditingController();
  final reasonController = TextEditingController();
  final dateTimeController = TextEditingController();

  UserModel? selectedDoctor;
  List<UserModel> doctors = [];
  List<PatientModel> patients = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    final appointment = _controller.selectedAppointment.value;

    doctors = await FirebaseService.filterDoctorsForAppointments();
    patients = await FirebaseService.getPatients();

    if (appointment != null) {
      opNoController.text = appointment.opNo;
      patientNameController.text = appointment.patientName;
      patientPhoneController.text = appointment.patientPhone;
      doctorNumberController.text = appointment.doctorNumber;
      reasonController.text = appointment.reason;
      dateTimeController.text = appointment.appointDateTime;

      selectedDoctor = doctors.firstWhereOrNull((d) => d.name == appointment.doctorName);
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _controller.selectedAppointment.value != null;

    if (doctors.isEmpty || patients.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Appointment' : 'New Appointment'),
        backgroundColor: Colors.blueAccent.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAutoCompletePatientName(),
              _buildTextField(
                controller: patientPhoneController,
                label: 'Patient Phone',
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                controller: opNoController,
                label: 'OP Number',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserModel>(
                value: selectedDoctor,
                items: doctors.map((doctor) {
                  return DropdownMenuItem<UserModel>(
                    value: doctor,
                    child: Text(doctor.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDoctor = value;
                    doctorNumberController.text = value?.phone ?? '';
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Doctor Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? 'Please select a doctor' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: doctorNumberController,
                label: 'Doctor Number',
                keyboardType: TextInputType.phone,
                readOnly: true,
              ),
              _buildTextField(
                controller: reasonController,
                label: 'Reason for Visit',
              ),
              _buildTextField(
                controller: dateTimeController,
                label: 'Appointment Date & Time',
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.tryParse(dateTimeController.text) ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                        DateTime.tryParse(dateTimeController.text) ?? DateTime.now(),
                      ),
                    );

                    if (pickedTime != null) {
                      final combined = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      setState(() {
                        dateTimeController.text = combined.toIso8601String();
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Appointment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final updated = AppointmentModel(
                      appointId: _controller.selectedAppointment.value?.appointId ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      opNo: opNoController.text.trim(),
                      patientName: patientNameController.text.trim(),
                      patientPhone: patientPhoneController.text.trim(),
                      doctorName: selectedDoctor?.name ?? '',
                      doctorNumber: doctorNumberController.text.trim(),
                      reason: reasonController.text.trim(),
                      appointDateTime: dateTimeController.text.trim(),
                      completed: _controller.selectedAppointment.value?.completed ?? false,
                    );

                    await _controller.addOrUpdateAppointment(updated);
                    Get.back();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutoCompletePatientName() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Autocomplete<PatientModel>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<PatientModel>.empty();
          }
          return patients.where((p) => p.name
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase()));
        },
        displayStringForOption: (patient) => patient.name,
        onSelected: (PatientModel patient) {
          patientNameController.text = patient.name;
          patientPhoneController.text = patient.phone;
          opNoController.text = patient.opNo;
        },
        fieldViewBuilder:
            (context, controller, focusNode, onEditingComplete) {
          // This syncs the controller with the patientNameController
          controller.text = patientNameController.text;
          controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length));

          controller.addListener(() {
            patientNameController.text = controller.text;
          });

          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              labelText: 'Patient Name',
              border: OutlineInputBorder(),
            ),
            onEditingComplete: onEditingComplete,
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null,
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
