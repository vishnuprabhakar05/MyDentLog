class PatientModel {
  final String opNo;
  final String name;
  final String phone;
  final String place;
  final String caseSheet;
  final int timestamp;

  PatientModel({
    required this.opNo,
    required this.name,
    required this.phone,
    required this.place,
    required this.caseSheet,
    required this.timestamp,
  });

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      opNo: map['op_no'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      place: map['place'] ?? '',
      caseSheet: map['case_sheet'] ?? '',
      timestamp: map['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'op_no': opNo,
      'name': name,
      'phone': phone,
      'place': place,
      'case_sheet': caseSheet,
      'timestamp': timestamp,
    };
  }
}