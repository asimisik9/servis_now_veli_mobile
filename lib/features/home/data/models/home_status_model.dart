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
    int? parseInt(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is num) {
          return value.toInt();
        }
        if (value is String) {
          final parsed = int.tryParse(value.trim());
          if (parsed != null) {
            return parsed;
          }
        }
      }
      return null;
    }

    String? parseString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) {
          continue;
        }
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
      return null;
    }

    return HomeStatusModel(
      tripStatus: parseString(['tripStatus', 'trip_status', 'tripType']),
      minutesLeft: parseInt([
        'minutesLeft',
        'minutes_left',
        'etaMinutes',
        'eta_minutes',
      ]),
      driverName: parseString(['driverName', 'driver_name']),
      driverPhone: parseString(['driverPhone', 'driver_phone']),
      plateNumber: parseString(['plateNumber', 'plate_number']),
      busId: parseString(['busId', 'bus_id']),
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
