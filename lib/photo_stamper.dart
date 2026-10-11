import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart' show DateFormat;

import 'l10n/app_localizations.dart';
import 'lock_record.dart' show formatTimestamp;

/// Burns date, time and location into the photo and also writes them as
/// EXIF metadata, so the information travels with the image when shared.
class PhotoStamper {
  /// Returns a JPEG of [sourceBytes] with a text strip along the bottom edge
  /// and EXIF date/GPS tags. Location values are optional; when missing the
  /// strip says "Location unavailable". The strip text is in the language of
  /// [l10n].
  ///
  /// Drawing uses Flutter's canvas (proper fonts, umlauts etc.); the slow JPEG
  /// encoding runs in a background isolate via [compute].
  static Future<Uint8List> stamp({
    required Uint8List sourceBytes,
    required DateTime timestamp,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? address,
    required AppLocalizations l10n,
  }) async {
    // Flutter's decoder applies the EXIF orientation, so the result is upright.
    final codec = await ui.instantiateImageCodec(sourceBytes);
    final source = (await codec.getNextFrame()).image;
    final width = source.width;
    final height = source.height;

    final coordinates = latitude != null && longitude != null
        ? '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}'
        : null;
    final lines = <String>[
      formatTimestamp(timestamp, l10n),
      if (address != null && address.isNotEmpty) address,
      if (coordinates == null)
        l10n.stampLocationUnavailable
      else if (accuracy != null)
        l10n.stampGpsWithAccuracy(coordinates, accuracy.round())
      else
        l10n.stampGps(coordinates),
    ];

    final shortSide = width < height ? width : height;
    final fontSize = shortSide * 0.035;
    final padding = fontSize * 0.6;

    final painter = TextPainter(
      text: TextSpan(
        text: lines.join('\n'),
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - 2 * padding);

    final bandHeight = painter.height + 2 * padding;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImage(source, Offset.zero, Paint());
    canvas.drawRect(
      Rect.fromLTWH(0, height - bandHeight, width.toDouble(), bandHeight),
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );
    painter.paint(canvas, Offset(padding, height - bandHeight + padding));

    final stamped = await recorder.endRecording().toImage(width, height);
    final rgba = await stamped.toByteData(format: ui.ImageByteFormat.rawRgba);
    source.dispose();
    stamped.dispose();
    painter.dispose();

    return compute(
      _encodeJpeg,
      _EncodeRequest(
        rgba: rgba!.buffer.asUint8List(),
        width: width,
        height: height,
        timestamp: timestamp,
        latitude: latitude,
        longitude: longitude,
        description: lines.join(' | '),
      ),
    );
  }
}

/// Data handed to the background isolate for JPEG encoding.
class _EncodeRequest {
  _EncodeRequest({
    required this.rgba,
    required this.width,
    required this.height,
    required this.timestamp,
    required this.description,
    this.latitude,
    this.longitude,
  });

  final Uint8List rgba;
  final int width;
  final int height;
  final DateTime timestamp;
  final String description;
  final double? latitude;
  final double? longitude;
}

/// Encodes raw RGBA pixels as JPEG and adds EXIF date, description and GPS.
Uint8List _encodeJpeg(_EncodeRequest r) {
  final image = img.Image.fromBytes(
    width: r.width,
    height: r.height,
    bytes: r.rgba.buffer,
    numChannels: 4,
  );

  final exifDate = DateFormat('yyyy:MM:dd HH:mm:ss').format(r.timestamp);
  image.exif.imageIfd['DateTime'] = exifDate;
  image.exif.imageIfd['ImageDescription'] = r.description;
  image.exif.exifIfd['DateTimeOriginal'] = exifDate;
  if (r.latitude != null && r.longitude != null) {
    image.exif.gpsIfd.setGpsLocation(
      latitude: r.latitude!,
      longitude: r.longitude!,
    );
  }

  return img.encodeJpg(image, quality: 90);
}
