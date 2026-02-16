import 'package:flutter_test/flutter_test.dart';
import 'package:servis_now_veli_mobile/features/home/data/models/home_status_model.dart';

void main() {
  test('HomeStatusModel parses camelCase payload', () {
    final model = HomeStatusModel.fromJson({
      'tripStatus': 'to_school',
      'minutesLeft': 8,
      'driverName': 'Ali Yilmaz',
      'driverPhone': '5551112233',
      'plateNumber': '34 ABC 123',
      'busId': 'bus-1',
    });

    expect(model.tripStatus, 'to_school');
    expect(model.minutesLeft, 8);
    expect(model.driverName, 'Ali Yilmaz');
    expect(model.driverPhone, '5551112233');
    expect(model.plateNumber, '34 ABC 123');
    expect(model.busId, 'bus-1');
  });

  test('HomeStatusModel parses snake_case and eta aliases', () {
    final model = HomeStatusModel.fromJson({
      'trip_status': 'to_home',
      'eta_minutes': '12',
      'driver_name': 'Mehmet Demir',
      'driver_phone': '5554443322',
      'plate_number': '06 XYZ 987',
      'bus_id': 'bus-2',
    });

    expect(model.tripStatus, 'to_home');
    expect(model.minutesLeft, 12);
    expect(model.driverName, 'Mehmet Demir');
    expect(model.driverPhone, '5554443322');
    expect(model.plateNumber, '06 XYZ 987');
    expect(model.busId, 'bus-2');
  });
}
