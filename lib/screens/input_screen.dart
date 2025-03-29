import 'dart:io'; // Add this import
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_api_availability/google_api_availability.dart';
import '../models/patient_model.dart';
import '../models/lab_model.dart';
import '../services/firebase_service.dart';
import 'search_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';  // Add this import for PlatformException

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
  var isReadOnly = false.obs;
  var includeLabDetails = false.obs;
  var showUploadSuccess = false.obs; 
  var isUploading = false.obs;

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
    _initializeFromArguments();
  }

  void _initializeFromArguments() {
    showUploadSuccess.value = false;
    final arguments = Get.arguments;
    if (arguments != null) {
      final PatientModel? patient = arguments['patient'];
      isReadOnly.value = arguments['isReadOnly'] ?? false;
      
      if (patient != null) {
        opNoController.text = patient.opNo;
        nameController.text = patient.name;
        phoneController.text = patient.phone ?? '';
        placeController.text = patient.place ?? '';
        caseSheetUrl.value = patient.caseSheet;
        
        if (patient.treatmentHistory != null) {
          treatmentHistory.value = patient.treatmentHistory!;
        }
      }
    }
  }

  void fetchLabs() async {
    try {
      labs.value = await _firebaseService.getLabs();
    } catch (e) {
      Get.snackbar(
        "Error", 
        "Failed to fetch labs: ${e.toString()}",
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void updateWorkTypes() {
    workTypes.value = selectedLab.value?.workTypes ?? [];
    selectedWorkType.value = null;
  }

  Future<bool> _checkAndroidPermissions() async {
  if (!Platform.isAndroid) return true;
  
  try {
    // Check Google Play Services availability
    final googleApiAvailability = GoogleApiAvailability.instance;
    final status = await googleApiAvailability.checkGooglePlayServicesAvailability();
    
    if (status != 0) {  // 0 means SERVICE_AVAILABLE
      // This just shows the dialog to users - it doesn't return a value
      await googleApiAvailability.makeGooglePlayServicesAvailable();
      
      // Check status again after user attempts to resolve
      final newStatus = await googleApiAvailability.checkGooglePlayServicesAvailability();
      return newStatus == 0;
    }

    // Check storage permissions
    final permissionStatus = await Permission.storage.request();
    return permissionStatus.isGranted;
    
  } on PlatformException catch (e) {
    Get.snackbar(
      "Error", 
      "Permission check failed: ${e.message}",
      backgroundColor: Colors.red,
      snackPosition: SnackPosition.BOTTOM,
    );
    return false;
  }
}

void pickFile() async {
  if (isReadOnly.value) return;
  
  try {
    // Check permissions on Android
    if (!kIsWeb && Platform.isAndroid && !await _checkAndroidPermissions()) {
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 90,
    );

    if (file != null) {
      isUploading.value = true;
      try {
        final String? uploadedUrl = await FirebaseService.uploadCaseSheet(file);
        caseSheetUrl.value = uploadedUrl;
        showUploadSuccess.value = uploadedUrl != null;

        if (uploadedUrl == null) {
          Get.snackbar(
            "Error", 
            "File upload failed",
            backgroundColor: Colors.red,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            "Success", 
            "File uploaded to Google Drive",
            backgroundColor: Colors.green,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        Get.snackbar(
          "Error", 
          "File upload failed: ${e.toString()}",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        isUploading.value = false;
      }
    }
  } catch (e) {
    Get.snackbar(
      "Error", 
      "Failed to pick file: ${e.toString()}",
      backgroundColor: Colors.red,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

  void toggleTreatmentInputs() {
    if (isReadOnly.value) return;
    showTreatmentInputs.value = !showTreatmentInputs.value;
  }

  void toggleIncludeLabDetails(bool? value) {
    if (value != null) {
      includeLabDetails.value = value;
      if (!value) {
        selectedLab.value = null;
        selectedWorkType.value = null;
      }
    }
  }

  void addOrUpdateTreatmentHistory() {
    if (isReadOnly.value) return;
    
    final String today = DateTime.now().toIso8601String().split("T")[0];
    final bool isTodayEntry = treatmentHistory.containsKey(today);

    if (treatmentController.text.trim().isEmpty) {
      Get.snackbar(
        "Error", 
        "Treatment notes cannot be empty",
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final String entryDate = editingKey.value ?? today;

    treatmentHistory[entryDate] = {
      "notes": treatmentController.text.trim(),
      "lab": includeLabDetails.value ? (selectedLab.value?.labName ?? "") : "",
      "workType": includeLabDetails.value ? (selectedWorkType.value ?? "") : "",
      "date": entryDate,
    };

    treatmentController.clear();
    selectedLab.value = null;
    selectedWorkType.value = null;
    showTreatmentInputs.value = false;
    editingKey.value = null;
    includeLabDetails.value = false;

    Get.snackbar(
      "Success", 
      "Treatment history ${isTodayEntry ? "updated" : "added"}",
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void editTreatmentHistory(String key, Map<String, String> details) {
    if (isReadOnly.value) return;
    
    treatmentController.text = details["notes"] ?? "";
    if (details["lab"]?.isNotEmpty ?? false) {
      includeLabDetails.value = true;
      selectedLab.value = labs.firstWhereOrNull((lab) => lab.labName == details["lab"]);
      updateWorkTypes();
      selectedWorkType.value = details["workType"];
    } else {
      includeLabDetails.value = false;
    }
    showTreatmentInputs.value = true;
    editingKey.value = key;
  }

  void savePatient() async {
    if (isReadOnly.value || !formKey.currentState!.validate()) return;
    isLoading.value = true;

    try {
      final String opNo = opNoController.text.trim();
      final PatientModel? existingPatient = await FirebaseService.getPatientByOpNo(opNo);

      final Map<String, dynamic> updatedHistory = existingPatient?.treatmentHistory ?? {};
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

      Get.snackbar(
        "Success", 
        "Patient saved successfully!",
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.off(() => SearchScreen());
    } on PlatformException catch (e) {
      Get.snackbar(
        "Error", 
        e.message ?? "Platform error while saving",
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        "Error", 
        "Failed to save patient. Please try again!",
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

class InputScreen extends StatelessWidget {
  final InputController controller = Get.put(InputController());

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.off(() => SearchScreen()),
                    ),
                    const SizedBox(width: 10),
                    Obx(() => Text(
                      controller.isReadOnly.value ? "View Patient" : "Add/Edit Patient",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Form(
                        key: controller.formKey,
                        child: Column(
                          children: [
                            _buildModernTextField(
                              controller.opNoController, 
                              "OP No", 
                              Icons.numbers,
                              controller.isReadOnly.value,
                            ),
                            const SizedBox(height: 15),
                            _buildModernTextField(
                              controller.nameController, 
                              "Name", 
                              Icons.person,
                              controller.isReadOnly.value,
                            ),
                            const SizedBox(height: 15),
                            _buildModernTextField(
                              controller.phoneController, 
                              "Phone", 
                              Icons.phone, 
                              controller.isReadOnly.value,
                              TextInputType.phone,
                            ),
                            const SizedBox(height: 15),
                            _buildModernTextField(
                              controller.placeController, 
                              "Place", 
                              Icons.location_on,
                              controller.isReadOnly.value,
                            ),
                            const SizedBox(height: 20),
                            _buildUploadButton(),
                            const SizedBox(height: 20),
                            _buildTreatmentSection(theme),
                            const SizedBox(height: 20),
                            _buildSaveButton(),
                          ],
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
    );
  }

  Widget _buildUploadButton() {
    return Obx(() => !controller.isReadOnly.value
        ? Column(
            children: [
              ElevatedButton(
                onPressed: controller.isUploading.value ? null : controller.pickFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isUploading.value 
                      ? Colors.blue.shade400 
                      : Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (controller.isUploading.value)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    else
                      const Icon(Icons.upload, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      controller.isUploading.value 
                          ? "Uploading..." 
                          : "Upload Case Sheet",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              if (controller.showUploadSuccess.value)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    "File uploaded to Google Drive",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
            ],
          )
        : const SizedBox());
  }

  Widget _buildSaveButton() {
    return Obx(() => controller.isLoading.value
        ? const CircularProgressIndicator(color: Colors.white)
        : !controller.isReadOnly.value
            ? ElevatedButton(
                onPressed: controller.savePatient,
                child: const Text("Save Patient", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  minimumSize: const Size(double.infinity, 50),
                ),
              )
            : const SizedBox());
  }

  Widget _buildModernTextField(
    TextEditingController controller, 
    String label, 
    IconData icon,
    bool isReadOnly, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      readOnly: isReadOnly,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
      validator: (value) => isReadOnly ? null : (value == null || value.isEmpty ? "$label cannot be empty" : null),
    );
  }

  Widget _buildTreatmentSection(ThemeData theme) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!controller.isReadOnly.value)
          ElevatedButton(
            onPressed: controller.toggleTreatmentInputs,
            child: Text(
              controller.showTreatmentInputs.value ? "Hide Treatment History" : "Add Treatment History",
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        if (controller.showTreatmentInputs.value && !controller.isReadOnly.value) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                TextFormField(
                  controller: controller.treatmentController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Treatment Notes",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Checkbox(
                      value: controller.includeLabDetails.value,
                      onChanged: controller.toggleIncludeLabDetails,
                      activeColor: Colors.blue,
                    ),
                    const Text(
                      "Include Lab Details",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                if (controller.includeLabDetails.value) ...[
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => DropdownButtonFormField<LabModel>(
                          value: controller.selectedLab.value,
                          dropdownColor: Colors.grey[900],
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Lab",
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: controller.labs.map((lab) => DropdownMenuItem<LabModel>(
                            value: lab,
                            child: Text(lab.labName, style: const TextStyle(color: Colors.white)),
                          )).toList(),
                          onChanged: (LabModel? lab) {
                            controller.selectedLab.value = lab;
                            controller.updateWorkTypes();
                          },
                        )),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(() => DropdownButtonFormField<String>(
                          value: controller.selectedWorkType.value,
                          dropdownColor: Colors.grey[900],
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Work Type",
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: controller.workTypes.map((workType) => DropdownMenuItem<String>(
                            value: workType,
                            child: Text(workType, style: const TextStyle(color: Colors.white)),
                          )).toList(),
                          onChanged: (String? workType) => controller.selectedWorkType.value = workType,
                        )),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: controller.addOrUpdateTreatmentHistory,
                  child: const Text("Save Treatment Notes", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (controller.treatmentHistory.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text("Treatment History", style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 10),
          ...controller.treatmentHistory.entries.map((entry) {
            final isToday = entry.key == DateTime.now().toIso8601String().split("T")[0];
            return Card(
              color: Colors.white.withOpacity(0.1),
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                title: Text(
                  isToday ? "Today's Treatment" : "Date: ${entry.key}",
                  style: const TextStyle(color: Colors.white),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.value["notes"] ?? "",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        if ((entry.value["lab"]?.isNotEmpty ?? false) || 
                            (entry.value["workType"]?.isNotEmpty ?? false)) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (entry.value["lab"]?.isNotEmpty ?? false)
                                Text(
                                  "Lab: ${entry.value["lab"]}",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              if (entry.value["workType"]?.isNotEmpty ?? false) ...[
                                const SizedBox(width: 15),
                                Text(
                                  "Work: ${entry.value["workType"]}",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ],
                          ),
                        ],
                        Obx(() => !controller.isReadOnly.value
                            ? Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue.shade200),
                                  onPressed: () => controller.editTreatmentHistory(entry.key, entry.value),
                                ),
                              )
                            : const SizedBox()),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    ));
  }
}