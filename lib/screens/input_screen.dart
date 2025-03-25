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
  var isLoading = false.obs;
  var showTreatmentInputs = false.obs;
  var treatmentHistory = <String, Map<String, String>>{}.obs;
  var enableLabWorkType = false.obs; // Checkbox state

  final FirebaseService _firebaseService = FirebaseService();

  var selectedLab = Rxn<LabModel>();
  var selectedWorkType = RxnString();
  var labs = <LabModel>[].obs;
  var workTypes = <String>[].obs;

  var editingKey = RxnString(); // Track the key of the treatment being edited

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

  void editTreatmentHistory(String key, Map<String, String> details) {
    treatmentController.text = details["notes"] ?? "";
    selectedLab.value = labs.firstWhereOrNull((lab) => lab.labName == details["lab"]);
    updateWorkTypes();
    selectedWorkType.value = details["workType"];
    showTreatmentInputs.value = true;
    editingKey.value = key;
    enableLabWorkType.value = details["lab"]!.isNotEmpty;
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

              ElevatedButton.icon(
                onPressed: controller.pickFile,
                icon: Icon(Icons.camera_alt),
                label: Text("Upload Case Sheet"),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: controller.toggleTreatmentInputs,
                child: Obx(() => Text(controller.showTreatmentInputs.value ? "Hide Treatment Notes" : "Add Treatment Notes")),
              ),

              Obx(() => controller.showTreatmentInputs.value ? _buildTreatmentInputSection() : SizedBox.shrink()),

              SizedBox(height: 20),

              Obx(() => Column(
                children: controller.treatmentHistory.entries.map((entry) {
                  return ExpansionTile(
                    title: Text("Treatment Date: ${entry.key}"),
                    children: [_buildEditableTreatmentTile(entry.key, entry.value)],
                  );
                }).toList(),
              )),

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

  Widget _buildTreatmentInputSection() {
    return Column(
      children: [
        CheckboxListTile(
          title: Text("Enable Lab & Work Type"),
          value: controller.enableLabWorkType.value,
          onChanged: (value) => controller.enableLabWorkType.value = value ?? false,
        ),
        TextFormField(
          controller: controller.treatmentController,
          keyboardType: TextInputType.multiline,
          maxLines: 6,
          decoration: InputDecoration(labelText: "Treatment Notes", border: OutlineInputBorder()),
        ),
        SizedBox(height: 10),
        Obx(() => controller.enableLabWorkType.value
            ? Column(
                children: [
                  _buildDropdown("Lab", controller.labs.map((lab) => lab.labName).toList(), controller.selectedLab.value?.labName, (val) {
                    controller.selectedLab.value = controller.labs.firstWhere((lab) => lab.labName == val);
                    controller.updateWorkTypes();
                  }),
                  SizedBox(height: 10),
                  _buildDropdown("Work Type", controller.workTypes, controller.selectedWorkType.value, (val) => controller.selectedWorkType.value = val),
                ],
              )
            : SizedBox.shrink()),
        SizedBox(height: 10),
        ElevatedButton(onPressed: controller.addOrUpdateTreatmentHistory, child: Text("Save Notes")),
      ],
    );
  }
  Widget _buildEditableTreatmentTile(String key, Map<String, String> details) {
      return ListTile(
        title: Text(details["notes"] ?? ""),
        subtitle: Text("Lab: ${details["lab"]}, Work: ${details["workType"]}"),
        trailing: IconButton(icon: Icon(Icons.edit), onPressed: () => controller.editTreatmentHistory(key, details)),
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

    Widget _buildDropdown(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8),
    ),
    child: DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none, // Removes default dropdown border
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    ),
  );
}
}
