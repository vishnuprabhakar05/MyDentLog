import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/patient_model.dart';
import '../services/firebase_service.dart';
import 'search_screen.dart';

class InputController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final opNoController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final placeController = TextEditingController();
  var caseSheetUrl = RxnString();
  var isLoading = false.obs;
  var treatmentHistory = <String, String>{}.obs;

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

  void openCaseSheet() {
    String date = DateTime.now().toIso8601String().split("T")[0];
    TextEditingController caseNotesController = TextEditingController(text: treatmentHistory[date] ?? '');

    Get.dialog(
      AlertDialog(
        title: Text("Treatment History - $date"),
        content: TextField(
          controller: caseNotesController,
          maxLines: 8,
          decoration: InputDecoration(hintText: "Enter treatment details...", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              treatmentHistory[date] = caseNotesController.text;
              Get.back();
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void savePatient() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      String opNo = opNoController.text.trim();
      PatientModel? existingPatient = await FirebaseService.getPatientByOpNo(opNo);
      Map<String, String> updatedHistory = existingPatient?.treatmentHistory ?? {};
      updatedHistory.addAll(treatmentHistory);

      final patient = PatientModel(
        opNo: opNo,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        place: placeController.text.trim(),
        caseSheet: caseSheetUrl.value ?? existingPatient?.caseSheet ?? '',
        timestamp: DateTime.now().toIso8601String(),
        treatmentHistory: updatedHistory,
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
              Text("Patient Details", style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 15),
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
              Obx(() => controller.caseSheetUrl.value != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text("Uploaded File: ${controller.caseSheetUrl.value}",
                          style: TextStyle(fontSize: 14, color: Colors.green), overflow: TextOverflow.ellipsis),
                    )
                  : SizedBox.shrink()),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: controller.openCaseSheet,
                icon: Icon(Icons.edit_note),
                label: Text("Treatment History"),
              ),
              SizedBox(height: 20),
              Obx(() => controller.treatmentHistory.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Past Visits:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ...controller.treatmentHistory.keys.map((date) => ListTile(
                              title: Text(date),
                              trailing: Icon(Icons.arrow_forward),
                              onTap: () {
                                Get.dialog(
                                  AlertDialog(
                                    title: Text("Case Sheet - $date"),
                                    content: TextField(
                                      controller: TextEditingController(text: controller.treatmentHistory[date]),
                                      maxLines: 8,
                                      readOnly: true,
                                      decoration: InputDecoration(border: OutlineInputBorder()),
                                    ),
                                    actions: [TextButton(onPressed: () => Get.back(), child: Text("Close"))],
                                  ),
                                );
                              },
                            )),
                      ],
                    )
                  : SizedBox.shrink()),
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.savePatient,
                      child: controller.isLoading.value ? CircularProgressIndicator(color: Colors.white) : Text("Save Patient"),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, [TextInputType? keyboardType]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder()),
      validator: (value) => value!.isEmpty ? 'Required' : null,
    );
  }
}
