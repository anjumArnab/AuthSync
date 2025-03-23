class UserModel {
  final String? id;
  final String fullName;
  final String gender;
  final String dateOfBirth;
  final String bloodGroup;
  final String preferredLanguage;
  final String phoneNumber;
  final String emergencyContact;
  final String mailingAddress;
  final String highSchool;
  final String college;
  final String undergradInstitution;
  
  UserModel({
    this.id,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.bloodGroup,
    required this.preferredLanguage,
    required this.phoneNumber,
    required this.emergencyContact,
    required this.mailingAddress,
    required this.highSchool,
    required this.college,
    required this.undergradInstitution,
  });
  
  // Convert UserModel to Map for database operations or API calls
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'bloodGroup': bloodGroup,
      'preferredLanguage': preferredLanguage,
      'phoneNumber': phoneNumber,
      'emergencyContact': emergencyContact,
      'mailingAddress': mailingAddress,
      'highSchool': highSchool,
      'college': college,
      'undergradInstitution': undergradInstitution,
    };
  }
  
  // Create UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      fullName: map['fullName'] ?? '',
      gender: map['gender'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      preferredLanguage: map['preferredLanguage'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      emergencyContact: map['emergencyContact'] ?? '',
      mailingAddress: map['mailingAddress'] ?? '',
      highSchool: map['highSchool'] ?? '',
      college: map['college'] ?? '',
      undergradInstitution: map['undergradInstitution'] ?? '',
    );
  }

  
  // For debugging and logging purposes
  @override
  String toString() {
    return 'UserModel(id: $id, fullName: $fullName, gender: $gender, dateOfBirth: $dateOfBirth, bloodGroup: $bloodGroup, '
        'preferredLanguage: $preferredLanguage, phoneNumber: $phoneNumber, emergencyContact: $emergencyContact, '
        'mailingAddress: $mailingAddress, highSchool: $highSchool, college: $college, undergradInstitution: $undergradInstitution)';
  }
}