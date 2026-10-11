import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

/// The single documented bike lock: the photo plus when and where it was taken.
class LockRecord {
  LockRecord({
    required this.photoPath,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.address,
  });

  final String photoPath;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final String? address;

  bool get hasLocation => latitude != null && longitude != null;

  String get formattedDateTime =>
      DateFormat('dd.MM.yyyy HH:mm:ss').format(timestamp);

  String get formattedCoordinates => hasLocation
      ? '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}'
      : 'Unknown location';

  String? get mapsUrl => hasLocation
      ? 'https://maps.google.com/?q=${latitude!.toStringAsFixed(6)},${longitude!.toStringAsFixed(6)}'
      : null;

  /// Text sent along with the photo when sharing.
  String get shareText {
    final lines = [
      'Bike locked on $formattedDateTime',
      ?address,
      'GPS: $formattedCoordinates'
          '${accuracy != null ? ' (±${accuracy!.round()} m)' : ''}',
      ?mapsUrl,
    ];
    return lines.join('\n');
  }

  Map<String, dynamic> toJson() => {
    'photoPath': photoPath,
    'timestamp': timestamp.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'address': address,
  };

  factory LockRecord.fromJson(Map<String, dynamic> json) => LockRecord(
    photoPath: json['photoPath'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    accuracy: (json['accuracy'] as num?)?.toDouble(),
    address: json['address'] as String?,
  );
}

/// Keeps exactly one [LockRecord] in the app's private documents directory.
///
/// Files there are not visible to the system gallery / Photos app.
class LockStorage {
  static const _recordFileName = 'lock_record.json';
  static const _photoPrefix = 'lock_photo_';

  /// `<app documents>/bike_lock`, created on first use.
  Future<Directory> _dir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/bike_lock');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Returns the stored record, or `null` if there is none or its photo is
  /// missing.
  Future<LockRecord?> load() async {
    final file = File('${(await _dir()).path}/$_recordFileName');
    if (!await file.exists()) return null;
    try {
      final record = LockRecord.fromJson(
        jsonDecode(await file.readAsString()) as Map<String, dynamic>,
      );
      if (!await File(record.photoPath).exists()) return null;
      return record;
    } catch (_) {
      return null;
    }
  }

  /// Writes the new photo and metadata, then deletes every older photo.
  Future<LockRecord> replace({
    required List<int> jpegBytes,
    required DateTime timestamp,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? address,
  }) async {
    final dir = await _dir();
    // Unique name per photo so Flutter's image cache never shows a stale one.
    final photo = File(
      '${dir.path}/$_photoPrefix${timestamp.millisecondsSinceEpoch}.jpg',
    );
    await photo.writeAsBytes(jpegBytes, flush: true);

    final record = LockRecord(
      photoPath: photo.path,
      timestamp: timestamp,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      address: address,
    );
    await File('${dir.path}/$_recordFileName')
        .writeAsString(jsonEncode(record.toJson()), flush: true);

    // Only remove the previous photo once the new one is safely stored.
    await for (final entity in dir.list()) {
      if (entity is File &&
          entity.path != photo.path &&
          entity.uri.pathSegments.last.startsWith(_photoPrefix)) {
        await entity.delete();
      }
    }
    return record;
  }
}
