class PatientModel {
  String opNo;
  String name;
  String phone;
  String place;
  String caseSheet;
  String timestamp;
  Map<String, Map<String, String>>? treatmentHistory; 

  PatientModel({
    required this.opNo,
    required this.name,
    required this.phone,
    required this.place,
    required this.caseSheet,
    required this.timestamp,
    this.treatmentHistory,
  });

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      opNo: map['OP_NO'] ?? '',
      name: map['NAME'] ?? '',
      phone: map['PHONE'] ?? '',
      place: map['PLACE'] ?? '',
      caseSheet: map['CASE_SHEET'] ?? '',
      timestamp: map['TIMESTAMP'] ?? '',
      treatmentHistory: map['TREATMENT_HISTORY'] != null
          ? Map<String, Map<String, String>>.from(
              (map['TREATMENT_HISTORY'] as Map).map(
                (key, value) => MapEntry(key, Map<String, String>.from(value)),
              ),
            )
          : {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'OP_NO': opNo,
      'NAME': name,
      'PHONE': phone,
      'PLACE': place,
      'CASE_SHEET': caseSheet,
      'TIMESTAMP': timestamp,
      'TREATMENT_HISTORY': treatmentHistory ?? {},
    };
  }
}
