import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/patient_model.dart';
import '../models/lab_model.dart';
import '../services/firebase_service.dart';
import 'search_screen.dart';

class InputController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final opNoController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final placeController = TextEditingController();
  final treatmentController = TextEditingController();

  var caseSheetUrl = RxnString();
  var iopaUrl = RxnString(); // IOPA File URL
  var isLoading = false.obs;
  var showTreatmentInputs = false.obs;
  var treatmentHistory = <String, Map<String, String>>{}.obs;
  var enableLabWorkType = false.obs;

  final FirebaseService _firebaseService = FirebaseService();

  var selectedLab = Rxn<LabModel>();
  var selectedWorkType = RxnString();
  var labs = <LabModel>[].obs;
  var workTypes = <String>[].obs;

  var editingKey = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchLabs();
  }

  void fetchLabs() async {
    labs.value = await _firebaseService.getLabs();
  }

  void updateWorkTypes() {
    workTypes.value = selectedLab.value?.workTypes ?? [];
    selectedWorkType.value = null;
  }

  // Pick and upload Case Sheet file
  void pickFile() async {
    final ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      isLoading.value = true;
      String? uploadedUrl = await FirebaseService.uploadCaseSheet(file);
      caseSheetUrl.value = uploadedUrl;
      isLoading.value = false;

      if (uploadedUrl == null) {
        Get.snackbar("Error", "File upload failed", backgroundColor: Colors.red, snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  // Pick and upload IOPA file
  void pickIOPAFile() async {
    final ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      isLoading.value = true;
      String? uploadedUrl = await FirebaseService.uploadCaseSheet(file); // Change this if there's a separate method for IOPA upload
      iopaUrl.value = uploadedUrl;
      isLoading.value = false;

      if (uploadedUrl == null) {
        Get.snackbar("Error", "IOPA upload failed", backgroundColor: Colors.red, snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void toggleTreatmentInputs() {
    showTreatmentInputs.toggle();
  }

  void addOrUpdateTreatmentHistory() {
    String date = DateTime.now().toIso8601String().split("T")[0];

    if (treatmentController.text.trim().isEmpty) {
      Get.snackbar("Error", "Treatment notes cannot be empty", backgroundColor: Colors.red, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    treatmentHistory[editingKey.value ?? date] = {
      "notes": treatmentController.text.trim(),
      "lab": enableLabWorkType.value ? (selectedLab.value?.labName ?? "") : "",
      "workType": enableLabWorkType.value ? (selectedWorkType.value ?? "") : ""
    };

    // Reset fields
    treatmentController.clear();
    selectedLab.value = null;
    selectedWorkType.value = null;
    showTreatmentInputs.value = false;
    editingKey.value = null;
    enableLabWorkType.value = false;

    Get.snackbar("Success", "Treatment notes updated", backgroundColor: Colors.green, snackPosition: SnackPosition.BOTTOM);
  }

  void savePatient() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;

    try {
      String opNo = opNoController.text.trim();
      PatientModel? existingPatient = await FirebaseService.getPatientByOpNo(opNo);

      Map<String, dynamic> updatedHistory = existingPatient?.treatmentHistory ?? {};
      updatedHistory.addAll(treatmentHistory);

      final patient = PatientModel(
        opNo: opNo,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        place: placeController.text.trim(),
        caseSheet: caseSheetUrl.value ?? existingPatient?.caseSheet ?? '',
        timestamp: DateTime.now().toIso8601String(),
        treatmentHistory: updatedHistory.map((key, value) => MapEntry(key, Map<String, String>.from(value))),
      );

      await FirebaseService.addOrUpdatePatient(patient);

      Get.snackbar("Success", "Patient saved successfully!", backgroundColor: Colors.green, snackPosition: SnackPosition.BOTTOM);
      isLoading.value = false;
      Get.off(() => SearchScreen());
    } catch (error) {
      Get.snackbar("Error", "Failed to save patient. Please try again!", backgroundColor: Colors.red, snackPosition: SnackPosition.BOTTOM);
      isLoading.value = false;
    }
  }
}

class InputScreen extends StatelessWidget {
  final InputController controller = Get.put(InputController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add / Edit Patient")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(controller.opNoController, "OP No", Icons.numbers),
              SizedBox(height: 15),
              _buildTextField(controller.nameController, "Name", Icons.person),
              SizedBox(height: 15),
              _buildTextField(controller.phoneController, "Phone", Icons.phone, TextInputType.phone),
              SizedBox(height: 15),
              _buildTextField(controller.placeController, "Place", Icons.location_on),
              SizedBox(height: 20),

              // Upload Case Sheet & Upload IOPA Buttons in Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.pickFile,
                      icon: Icon(Icons.upload_file),
                      label: Text("Upload Case Sheet"),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.pickIOPAFile,
                      icon: Icon(Icons.image),
                      label: Text("Upload IOPA"),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: controller.toggleTreatmentInputs,
                child: Obx(() => Text(controller.showTreatmentInputs.value ? "Hide Treatment Notes" : "Add Treatment Notes")),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.savePatient,
                child: Text("Save Patient"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
      validator: (value) => value == null || value.isEmpty ? "$label cannot be empty" : null,
    );
  }
}
