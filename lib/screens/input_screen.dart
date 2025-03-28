import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/patient_model.dart';
import '../models/lab_model.dart';
import '../models/settings_model.dart';
import '../services/firebase_service.dart';
import '../services/google_drive_service.dart';
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
  var isReadOnly = false.obs;
  var includeLabDetails = false.obs;
  var showUploadSuccess = false.obs;
  var uploadProgress = 0.0.obs;

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
    labs.value = await _firebaseService.getLabs();
  }

  void updateWorkTypes() {
    workTypes.value = selectedLab.value?.workTypes ?? [];
    selectedWorkType.value = null;
  }

  Future<void> pickFile() async {
    if (isReadOnly.value) return;
    
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      isLoading.value = true;
      uploadProgress.value = 0;
      
      try {
        // Get Google Drive folder from Firebase settings
        final settings = await FirebaseService.getGoogleDriveLinkFromSettings();
        if (settings.googleDriveLink.isEmpty) {
          throw Exception("Google Drive upload location not configured");
        }

        // Extract folder ID from the Google Drive link
        final folderId = GoogleDriveService.extractFolderIdFromUrl(settings.googleDriveLink);
        if (folderId == null) {
          throw Exception("Invalid Google Drive folder link");
        }

        // Upload to Google Drive
        final String? uploadedUrl = await GoogleDriveService.uploadFile(
          File(file.path),
          folderId: folderId,
          onProgress: (sent, total) {
            uploadProgress.value = sent / total;
          },
        );

        if (uploadedUrl != null) {
          caseSheetUrl.value = uploadedUrl;
          showUploadSuccess.value = true;
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
        caseSheetUrl.value = null;
        showUploadSuccess.value = false;
      } finally {
        isLoading.value = false;
        uploadProgress.value = 0;
      }
    }
  }

  // ... [keep all other existing methods unchanged]
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
                            Obx(() {
                              if (controller.isReadOnly.value) return const SizedBox();
                              
                              if (controller.isLoading.value) {
                                return Column(
                                  children: [
                                    CircularProgressIndicator(
                                      value: controller.uploadProgress.value > 0 
                                          ? controller.uploadProgress.value 
                                          : null,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Uploading: ${(controller.uploadProgress.value * 100).toStringAsFixed(1)}%',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                );
                              } else {
                                return ElevatedButton.icon(
                                  onPressed: controller.pickFile,
                                  icon: const Icon(Icons.upload, color: Colors.white),
                                  label: const Text("Upload Case Sheet", style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                  ),
                                );
                              }
                            }),
                            Obx(() => controller.showUploadSuccess.value
                                ? const Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Text(
                                      "File uploaded to Google Drive",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  )
                                : const SizedBox()),
                            const SizedBox(height: 20),
                            _buildTreatmentSection(theme),
                            const SizedBox(height: 20),
                            Obx(() => controller.isLoading.value
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
                                        ),
                                      )
                                    : const SizedBox()),
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

  // ... [keep all other existing widget methods unchanged]
}