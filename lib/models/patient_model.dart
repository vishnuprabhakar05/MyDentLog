class PatientModel {
  final String opNo;
  final String name;
  final String phone;
  final String place;
  final String caseSheet;
  final String timestamp; 

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
      opNo: map['OP_NO'] ?? '',  
      name: map['NAME'] ?? '',
      phone: map['PHONE'] ?? '',
      place: map['PLACE'] ?? '',
      caseSheet: map['CASE_SHEET'] ?? '',
      timestamp: map['TIMESTAMP'] ?? '', 
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
    };
  }
}
