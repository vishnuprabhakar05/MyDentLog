import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_dentlog_app/models/appointment_model.dart';
import 'package:my_dentlog_app/services/firebase_service.dart';

class AppointmentController extends GetxController {
  var appointments = <AppointmentModel>[].obs;
  var filteredAppointments = <AppointmentModel>[].obs;
  var isLoading = false.obs;
  var isUpdatingStatus = false.obs;
  var selectedAppointment = Rxn<AppointmentModel>();


  // Form controllers
  final opNoController = TextEditingController();
  final patientNameController = TextEditingController();
  final patientPhoneController = TextEditingController();
  final doctorNameController = TextEditingController();
  final doctorNumberController = TextEditingController();
  final reasonController = TextEditingController();
  final dateTimeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchAppointments();
  }

  @override
  void onClose() {
    opNoController.dispose();
    patientNameController.dispose();
    patientPhoneController.dispose();
    doctorNameController.dispose();
    doctorNumberController.dispose();
    reasonController.dispose();
    dateTimeController.dispose();
    super.onClose();
  }

  void fetchAppointments() {
    isLoading.value = true;

    FirebaseService.getAppointmentsStream().listen((appointmentsList) {
      appointments.value = appointmentsList;
      sortAppointments();
      filteredAppointments.value = [...appointments];
      isLoading.value = false;
    }, onError: (error) {
      print("Error fetching appointments: $error");
      Get.snackbar("Error", "Failed to load appointments");
      isLoading.value = false;
    });
  }

  void sortAppointments() {
    appointments.sort((a, b) {
      // Incomplete first
      if (a.completed != b.completed) {
        return a.completed ? 1 : -1;
      }
      // Then sort by date
      return a.appointDateTime.compareTo(b.appointDateTime);
    });
  }

  void filterAppointments(String query) {
    query = query.toLowerCase();
    filteredAppointments.value = appointments.where((appointment) =>
        appointment.patientName.toLowerCase().contains(query) ||
        appointment.opNo.toLowerCase().contains(query) ||
        appointment.doctorName.toLowerCase().contains(query) ||
        appointment.reason.toLowerCase().contains(query)
    ).toList();
  }

  void filterByStatus(bool? completed) {
    if (completed == null) {
      filteredAppointments.value = [...appointments];
    } else {
      filteredAppointments.value =
          appointments.where((app) => app.completed == completed).toList();
    }
  }

  Future<void> saveAppointment(AppointmentModel appointment) async {
    try {
      isLoading.value = true;
      await FirebaseService.addOrUpdateAppointment(appointment);
      Get.back(); // Go back after saving
      Get.snackbar("Success", "Appointment saved successfully");
    } catch (e) {
      print("Error saving appointment: $e");
      Get.snackbar("Error", "Failed to save appointment");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAppointment(String appointId) async {
    try {
      isLoading.value = true;
      await FirebaseService.deleteAppointment(appointId);
      appointments.removeWhere((app) => app.appointId == appointId);
      filteredAppointments.removeWhere((app) => app.appointId == appointId);
      Get.back(); // Close dialog
      Get.snackbar("Deleted", "Appointment deleted successfully");
    } catch (e) {
      print("Error deleting appointment: $e");
      Get.snackbar("Error", "Failed to delete appointment");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleAppointmentStatus(String appointId, bool currentStatus) async {
    try {
      isUpdatingStatus.value = true;
      await FirebaseService.toggleAppointmentStatus(appointId, !currentStatus);

      int index = appointments.indexWhere((a) => a.appointId == appointId);
      if (index != -1) {
        var updated = appointments[index].copyWith(completed: !currentStatus);
        appointments[index] = updated;
        filteredAppointments.value = [...appointments];
      }
    } catch (e) {
      print("Error updating appointment status: $e");
      Get.snackbar("Error", "Failed to update status");
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  void loadAppointmentData(AppointmentModel appointment) {
    opNoController.text = appointment.opNo;
    patientNameController.text = appointment.patientName;
    patientPhoneController.text = appointment.patientPhone;
    doctorNameController.text = appointment.doctorName;
    doctorNumberController.text = appointment.doctorNumber;
    reasonController.text = appointment.reason;
    dateTimeController.text = appointment.appointDateTime;
  }

  void clearForm() {
    opNoController.clear();
    patientNameController.clear();
    patientPhoneController.clear();
    doctorNameController.clear();
    doctorNumberController.clear();
    reasonController.clear();
    dateTimeController.clear();
  }

  AppointmentModel prepareAppointment({String appointId = ''}) {
    return AppointmentModel(
      appointId: appointId.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : appointId,
      opNo: opNoController.text.trim(),
      patientName: patientNameController.text.trim(),
      patientPhone: patientPhoneController.text.trim(),
      doctorName: doctorNameController.text.trim(),
      doctorNumber: doctorNumberController.text.trim(),
      reason: reasonController.text.trim(),
      appointDateTime: dateTimeController.text.trim(),
      completed: false,
    );
  }

  Future<void> addOrUpdateAppointment(AppointmentModel appointment) async {
  await saveAppointment(appointment);
}
}
