class MedicalRecord {
  final String dateOfBirth;
  final String bloodGroup;
  final String pastSurgeries;
  final String longTermMedications;
  final String ongoingIllnesses;
  final String allergies;
  final String otherIssues;
  final String emergencyContactName;
  final String emergencyContactNumber;

  MedicalRecord({
    required this.dateOfBirth,
    required this.bloodGroup,
    required this.pastSurgeries,
    required this.longTermMedications,
    required this.ongoingIllnesses,
    required this.allergies,
    required this.otherIssues,
    required this.emergencyContactName,
    required this.emergencyContactNumber,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      dateOfBirth: json['date_of_birth'],
      bloodGroup: json['blood_group'],
      pastSurgeries: json['past_surgeries'],
      longTermMedications: json['long_term_medications'],
      ongoingIllnesses: json['ongoing_illnesses'],
      allergies: json['allergies'],
      otherIssues: json['other_issues'],
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactNumber: json['emergency_contact_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date_of_birth': dateOfBirth,
      'blood_group': bloodGroup,
      'past_surgeries': pastSurgeries,
      'long_term_medications': longTermMedications,
      'ongoing_illnesses': ongoingIllnesses,
      'allergies': allergies,
      'other_issues': otherIssues,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_number': emergencyContactNumber,
    };
  }
}
