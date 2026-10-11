import 'package:flutter_test/flutter_test.dart';

import 'package:bike_lock_doc/lock_record.dart';

void main() {
  test('LockRecord survives a JSON round trip', () {
    final record = LockRecord(
      photoPath: '/tmp/lock_photo_1.jpg',
      timestamp: DateTime(2026, 10, 10, 18, 30, 5),
      latitude: 52.520008,
      longitude: 13.404954,
      accuracy: 4.2,
      address: 'Alexanderplatz 1, 10178 Berlin',
    );

    final copy = LockRecord.fromJson(record.toJson());

    expect(copy.photoPath, record.photoPath);
    expect(copy.timestamp, record.timestamp);
    expect(copy.latitude, record.latitude);
    expect(copy.longitude, record.longitude);
    expect(copy.address, record.address);
    expect(copy.formattedDateTime, '10.10.2026 18:30:05');
    expect(copy.shareText, contains('maps.google.com/?q=52.520008,13.404954'));
  });

  test('LockRecord without location', () {
    final record = LockRecord(
      photoPath: '/tmp/x.jpg',
      timestamp: DateTime(2026, 1, 1),
    );
    expect(record.hasLocation, isFalse);
    expect(record.mapsUrl, isNull);
    expect(record.shareText, contains('Unknown location'));
  });
}
