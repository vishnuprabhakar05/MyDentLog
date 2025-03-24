class LabModel {
  String? labId;
  String labName;
  String? phone;
  String? location;
  List<String> workTypes; // Added workTypes

  LabModel({
    this.labId,
    required this.labName,
    this.phone,
    this.location,
    this.workTypes = const [], // Default empty list
  });

  // Convert LabModel to Map (for Firebase)
  Map<String, dynamic> toMap() {
    return {
      'labId': labId,
      'labName': labName,
      'phone': phone ?? "",
      'location': location ?? "",
      'workTypes': workTypes, // Store workTypes as a list
    };
  }

  // Convert Firebase Map to LabModel
  factory LabModel.fromMap(Map<String, dynamic> map) {
    return LabModel(
      labId: map['labId'],
      labName: map['labName'],
      phone: map['phone'],
      location: map['location'],
      workTypes: List<String>.from(map['workTypes'] ?? []), // Read workTypes
    );
  }
}
