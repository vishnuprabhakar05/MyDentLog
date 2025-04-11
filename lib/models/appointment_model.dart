class AppointmentModel {
  String appointId;
  String opNo;
  String patientName;
  String patientPhone;
  String doctorName;
  String doctorNumber;
  String reason;
  String appointDateTime;
  bool completed;

  AppointmentModel({
    required this.appointId,
    required this.opNo,
    required this.patientName,
    required this.patientPhone,
    required this.doctorName,
    required this.doctorNumber,
    required this.reason,
    required this.appointDateTime,
    required this.completed,
  });

  // Convert AppointmentModel to Map (for Firebase)
  Map<String, dynamic> toMap() {
    return {
      'appointId': appointId,
      'opNo': opNo,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'doctorName': doctorName,
      'doctorNumber': doctorNumber,
      'reason': reason,
      'appointDateTime': appointDateTime,
      'completed': completed,
    };
  }

  // Convert Firebase Map to AppointmentModel
  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      appointId: map['appointId'] ?? '',
      opNo: map['opNo'] ?? '',
      patientName: map['patientName'] ?? '',
      patientPhone: map['patientPhone'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorNumber: map['doctorNumber'] ?? '',
      reason: map['reason'] ?? '',
      appointDateTime: map['appointDateTime'] ?? '',
      completed: map['completed'] ?? false,
    );
  }

  // Add a copyWith method for updating specific fields
  AppointmentModel copyWith({
    String? appointId,
    String? opNo,
    String? patientName,
    String? patientPhone,
    String? doctorName,
    String? doctorNumber,
    String? reason,
    String? appointDateTime,
    bool? completed,
  }) {
    return AppointmentModel(
      appointId: appointId ?? this.appointId,
      opNo: opNo ?? this.opNo,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      doctorName: doctorName ?? this.doctorName,
      doctorNumber: doctorNumber ?? this.doctorNumber,
      reason: reason ?? this.reason,
      appointDateTime: appointDateTime ?? this.appointDateTime,
      completed: completed ?? this.completed,
    );
  }
}
