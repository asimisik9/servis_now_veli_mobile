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
      tripStatus: json['tripStatus'],
      minutesLeft: json['minutesLeft'],
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      plateNumber: json['plateNumber'],
      busId: json['busId'],
    );
  }
}

class Student {
  final String id;
  final String fullName;
  final String studentNumber;
  final String schoolId;
  final String? schoolName;
  final String? address;

  Student({
    required this.id,
    required this.fullName,
    required this.studentNumber,
    required this.schoolId,
    this.schoolName,
    this.address,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      fullName: json['full_name'],
      studentNumber: json['student_number'],
      schoolId: json['school_id'],
      schoolName: json['school_name'],
      address: json['address'],
    );
  }
}
