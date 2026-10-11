import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import 'lock_record.dart';
import 'photo_stamper.dart';

/// Entry point. The whole app is a single screen, see [HomePage].
void main() => runApp(const BikeLockApp());

/// Root widget: sets up the Material theme (light and dark) and [HomePage].
class BikeLockApp extends StatelessWidget {
  const BikeLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bike Lock Proof',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

/// The only screen: shows the current [LockRecord] (or an empty state) and
/// offers the "New photo" and "Share" actions.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _storage = LockStorage();
  final _picker = ImagePicker();

  LockRecord? _record;
  bool _loading = true;
  String? _busyMessage;

  @override
  void initState() {
    super.initState();
    _storage.load().then((record) {
      if (mounted) {
        setState(() {
          _record = record;
          _loading = false;
        });
      }
    });
  }

  /// Takes a photo, gathers time and location, stamps the photo and replaces
  /// the previously stored one. Cancelling the camera changes nothing.
  Future<void> _takePhoto() async {
    // Start fetching the location right away so it is ready (or close to it)
    // by the time the photo has been taken.
    final positionFuture = _getPosition();

    final XFile? shot;
    try {
      shot = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2560,
        maxHeight: 2560,
        imageQuality: 95,
      );
    } catch (e) {
      _showMessage('Could not open camera: $e');
      return;
    }
    if (shot == null) return; // Cancelled: keep the existing photo.

    final timestamp = DateTime.now();
    setState(() => _busyMessage = 'Getting location…');

    try {
      final position = await positionFuture;
      String? address;
      if (position != null) {
        address = await _reverseGeocode(position);
      }

      setState(() => _busyMessage = 'Saving photo…');
      final stamped = await PhotoStamper.stamp(
        sourceBytes: await shot.readAsBytes(),
        timestamp: timestamp,
        latitude: position?.latitude,
        longitude: position?.longitude,
        accuracy: position?.accuracy,
        address: address,
      );

      final record = await _storage.replace(
        jpegBytes: stamped,
        timestamp: timestamp,
        latitude: position?.latitude,
        longitude: position?.longitude,
        accuracy: position?.accuracy,
        address: address,
      );

      if (!mounted) return;
      setState(() => _record = record);
      if (position == null) {
        _showMessage('Photo saved, but the location could not be determined.');
      }
    } catch (e) {
      _showMessage('Saving failed: $e');
    } finally {
      // Remove the camera's temporary copy; the app keeps its own private one.
      unawaited(File(shot.path).delete().then((_) {}, onError: (_) {}));
      if (mounted) setState(() => _busyMessage = null);
    }
  }

  /// Asks for location permission if needed and returns the current GPS
  /// position, or `null` if location is unavailable. Never throws.
  Future<Position?> _getPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showMessage('Location services are turned off.');
        return null;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showMessage('Location permission denied.');
        return null;
      }
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 30),
          ),
        );
      } on TimeoutException {
        return await Geolocator.getLastKnownPosition();
      }
    } catch (_) {
      return null;
    }
  }

  /// Turns coordinates into a short "street, postcode city" string using the
  /// platform geocoder. Needs internet; returns `null` on any failure.
  Future<String?> _reverseGeocode(Position position) async {
    try {
      final placemarks = await Geocoding()
          .placemarkFromCoordinates(position.latitude, position.longitude)
          .timeout(const Duration(seconds: 8));
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      final street = [p.street].whereType<String>().where((s) => s.isNotEmpty);
      final city = [
        p.postalCode,
        p.locality,
      ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
      final parts = [...street, if (city.isNotEmpty) city];
      return parts.isEmpty ? null : parts.join(', ');
    } catch (_) {
      return null; // Offline or no geocoder: coordinates are still saved.
    }
  }

  /// Opens the system share sheet with the photo and a text summary.
  /// [buttonContext] anchors the share popover on iPad.
  Future<void> _share(BuildContext buttonContext) async {
    final record = _record;
    if (record == null) return;
    final box = buttonContext.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(record.photoPath, mimeType: 'image/jpeg')],
        text: record.shareText,
        subject: 'Bike lock ${record.formattedDateTime}',
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  /// Shows the photo full screen with pinch-to-zoom.
  void _openFullScreen() {
    final record = _record;
    if (record == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: InteractiveViewer(
            maxScale: 6,
            child: Center(child: Image.file(File(record.photoPath))),
          ),
        ),
      ),
    );
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final record = _record;
    final busy = _busyMessage != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Bike Lock Proof')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                record == null
                    ? const _EmptyState()
                    : _RecordView(record: record, onTapPhoto: _openFullScreen),
                if (busy)
                  ColoredBox(
                    color: Colors.black54,
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(_busyMessage!),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: busy ? null : _takePhoto,
                  icon: const Icon(Icons.photo_camera),
                  label: Text(record == null ? 'Take photo' : 'New photo'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Builder(
                  builder: (buttonContext) => OutlinedButton.icon(
                    onPressed: busy || record == null
                        ? null
                        : () => _share(buttonContext),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown before the first photo has been taken.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pedal_bike, size: 96, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('No photo yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Take a photo of your locked bike. Date, time and location '
              'are saved with it. Each new photo replaces the previous one.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the stored photo and its date, address and GPS details.
class _RecordView extends StatelessWidget {
  const _RecordView({required this.record, required this.onTapPhoto});

  final LockRecord record;
  final VoidCallback onTapPhoto;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GestureDetector(
          onTap: onTapPhoto,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(record.photoPath), fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(record.formattedDateTime),
                subtitle: const Text('Date & time'),
              ),
              if (record.address != null)
                ListTile(
                  leading: const Icon(Icons.place),
                  title: Text(record.address!),
                  subtitle: const Text('Address'),
                ),
              ListTile(
                leading: const Icon(Icons.gps_fixed),
                title: Text(record.formattedCoordinates),
                subtitle: Text(
                  record.accuracy != null
                      ? 'GPS (±${record.accuracy!.round()} m)'
                      : 'GPS',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
