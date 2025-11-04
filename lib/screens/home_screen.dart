import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../widgets/bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _sending = false;

  Future<Position?> _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  Future<void> _sendSOS() async {
    setState(() => _sending = true);
    try {
      // Haptic feedback if enabled
      if (SettingsService.sosVibration.value) {
        await HapticFeedback.heavyImpact();
      }

      final includeLocation = SettingsService.autoLocationSharing.value;
      final pos = includeLocation ? await _getLocation() : null;
      final lat = pos?.latitude;
      final lng = pos?.longitude;
      final mapsLink = (lat != null && lng != null)
          ? 'https://maps.google.com/?q=$lat,$lng'
          : (includeLocation ? 'Location unavailable' : 'Location disabled');

      final message = Uri.encodeComponent('SOS: I need help. My location: $mapsLink');

      final smsUri = Uri.parse('sms:?body=$message');
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SOS sent')), 
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.warning, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text(
              'Undeme',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF030213),
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Экстренная помощь',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF717182),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context).t('sos_title'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF030213),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).t('sos_hint'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF717182),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _sending ? null : _sendSOS,
              child: Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  color: Color(0xFFD4183D),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 15,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: _sending
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '🚨',
                            style: TextStyle(fontSize: 36),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'SOS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 64),
            _contactsSection(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Color(0xFF717182),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).t('info_location'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF717182),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  Widget _contactsSection() {
    return FutureBuilder(
      future: AuthService.getContacts(),
      builder: (context, snapshot) {
        final contacts = (snapshot.data as List?) ?? [];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x80ECECF0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).t('your_contacts'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF030213),
                ),
              ),
              const SizedBox(height: 8),
              if (contacts.isEmpty) ...[
                Text(
                  AppLocalizations.of(context).t('no_contacts'),
                  style: const TextStyle(fontSize: 14, color: Color(0xFF717182)),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  child: Text(AppLocalizations.of(context).t('add_contacts')),
                ),
              ] else ...[
                for (int i = 0; i < contacts.length; i++) ...[
                  _contactRow(index: i + 1, name: contacts[i].name, phone: contacts[i].phone, relationship: contacts[i].relationship),
                  if (i != contacts.length - 1) const SizedBox(height: 8),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _contactRow({required int index, required String name, required String phone, required String relationship}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$index. $name (${relationship.isNotEmpty ? relationship : 'Контакт'}) - $phone',
            style: const TextStyle(fontSize: 14, color: Color(0xFF030213)),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.phone, size: 18, color: Color(0xFF030213)),
          onPressed: () async {
            final uri = Uri.parse('tel:$phone');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.sms, size: 18, color: Color(0xFF030213)),
          onPressed: () async {
            final msg = Uri.encodeComponent('SOS: I need help');
            final uri = Uri.parse('sms:$phone?body=$msg');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
        ),
      ],
    );
  }
}
