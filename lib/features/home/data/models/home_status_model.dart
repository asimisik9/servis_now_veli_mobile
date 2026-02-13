class HomeStatusModel {
  final String? tripStatus; // "to_school", "to_home", "inactive"
  final int? minutesLeft;
  final String? driverName;
  final String? driverPhone;
  final String? plateNumber;
  final String? busId;

  HomeStatusModel({
    this.tripStatus,
    this.minutesLeft,
    this.driverName,
    this.driverPhone,
    this.plateNumber,
    this.busId,
  });

  factory HomeStatusModel.fromJson(Map<String, dynamic> json) {
    return HomeStatusModel(
      tripStatus: json['tripStatus']?.toString(),
      minutesLeft: (json['minutesLeft'] as num?)?.toInt(),
      driverName: json['driverName']?.toString(),
      driverPhone: json['driverPhone']?.toString(),
      plateNumber: json['plateNumber']?.toString(),
      busId: json['busId']?.toString(),
    );
  }
}

class Student {
  final String id;
  final String fullName;
  final String studentNumber;
  final String? schoolId;
  final String? schoolName;
  final String? address;

  Student({
    required this.id,
    required this.fullName,
    required this.studentNumber,
    this.schoolId,
    this.schoolName,
    this.address,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: (json['id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      studentNumber: (json['student_number'] ?? '').toString(),
      schoolId: json['school_id']?.toString(),
      schoolName: json['school_name']?.toString(),
      address: json['address']?.toString(),
    );
  }
}
