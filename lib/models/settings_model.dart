class SettingsModel {
  String googleDriveLink;

  SettingsModel({required this.googleDriveLink});

  // Convert Firebase data to a SettingsModel instance
  factory SettingsModel.fromMap(Map<dynamic, dynamic> map) {
    return SettingsModel(
      googleDriveLink: map['googleDriveLink'] ?? '',
    );
  }

  // Convert SettingsModel instance to a Firebase-compatible map
  Map<String, dynamic> toMap() {
    return {
      'googleDriveLink': googleDriveLink,
    };
  }
}
