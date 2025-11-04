import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import '../services/settings_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _isLoginMode = true;
  bool _submitting = false;
  String? _error;
  
  bool _sosVibration = true;
  bool _autoLocationSharing = true;
  bool _emergencyNotifications = true;
  bool _soundAlerts = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadSettings();
  }

  Future<void> _loadCurrentUser() async {
    try {
      await AuthService.init();
      final user = AuthService.currentUser;
      if (user != null) {
        setState(() {
          _name.text = user.name;
          _email.text = user.email;
          _phone.text = user.phone;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadSettings() async {
    setState(() {
      _sosVibration = SettingsService.sosVibration.value;
      _autoLocationSharing = SettingsService.autoLocationSharing.value;
      _emergencyNotifications = SettingsService.emergencyNotifications.value;
      _soundAlerts = SettingsService.soundAlerts.value;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future _showError(String message) async {
    setState(() => _error = message);
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _error = null);
  }

  Future<void> _submitAuth() async {
    setState(() { _submitting = true; _error = null; });
    try {
      if (_isLoginMode) {
        await _login();
      } else {
        await _register();
      }
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Профиль и настройки',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF030213),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Управляйте своей информацией и экстренными контактами',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF717182),
              ),
            ),
            const SizedBox(height: 24),
            _buildAuthOrProfileCard(),
            const SizedBox(height: 24),
            _buildContactsCard(),
            const SizedBox(height: 24),
            _buildCard(
              icon: Icons.settings_outlined,
              title: 'Настройки приложения',
              children: [
                _buildSwitchTile(
                  title: 'SOS Button Vibration',
                  subtitle: 'Vibrate when SOS is activated',
                  value: _sosVibration,
                  onChanged: (val) async {
                    setState(() => _sosVibration = val);
                    await SettingsService.setSosVibration(val);
                  },
                ),
                Divider(color: Colors.black.withValues(alpha: 0.1), height: 1),
                _buildSwitchTile(
                  title: 'Auto Location Sharing',
                  subtitle: 'Automatically share location in SOS',
                  value: _autoLocationSharing,
                  onChanged: (val) async {
                    setState(() => _autoLocationSharing = val);
                    await SettingsService.setAutoLocationSharing(val);
                  },
                ),
                Divider(color: Colors.black.withValues(alpha: 0.1), height: 1),
                _buildSwitchTile(
                  title: 'Emergency Notifications',
                  subtitle: 'Get alerts about nearby emergencies',
                  value: _emergencyNotifications,
                  onChanged: (val) async {
                    setState(() => _emergencyNotifications = val);
                    await SettingsService.setEmergencyNotifications(val);
                  },
                ),
                Divider(color: Colors.black.withValues(alpha: 0.1), height: 1),
                _buildSwitchTile(
                  title: 'Sound Alerts',
                  subtitle: 'Play sound when SOS is activated',
                  value: _soundAlerts,
                  onChanged: (val) async {
                    setState(() => _soundAlerts = val);
                    await SettingsService.setSoundAlerts(val);
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Язык / Тіл / Language',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF030213)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _langChip('kk', 'Қазақша'),
                    _langChip('ru', 'Русский'),
                    _langChip('en', 'English'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildCard(
              icon: Icons.security_outlined,
              title: 'Конфиденциальность и безопасность',
              children: [
                _buildPrivacyItem('🔒 Your location is only shared when you activate SOS'),
                const SizedBox(height: 12),
                _buildPrivacyItem('📱 Emergency contacts are stored securely on your device'),
                const SizedBox(height: 12),
                _buildPrivacyItem('🚫 We never share your personal information with third parties'),
                const SizedBox(height: 12),
                _buildPrivacyItem('🗑️ You can delete your data at any time'),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 4),
    );
  }

  // ====== Аутентификация и профиль ======
  Future<void> _login() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) throw Exception('Введите email и пароль');

    final user = await AuthService.login(email: email, password: password);
    setState(() {
      _name.text = user.name;
      _email.text = user.email;
      _phone.text = user.phone;
    });
  }

  Future<void> _register() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final phone = _phone.text.trim();
    final password = _password.text;
    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      throw Exception('Заполните все поля');
    }
    final user = await AuthService.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
    setState(() {
      _name.text = user.name;
      _email.text = user.email;
      _phone.text = user.phone;
      _isLoginMode = true;
    });
  }

  Widget _buildAuthOrProfileCard() {
    final bool loggedIn = AuthService.currentUser != null;

    if (!loggedIn) {
      return _buildCard(
        icon: Icons.lock_outline,
        title: _isLoginMode ? 'Вход' : 'Регистрация',
        children: [
          if (!_isLoginMode) ...[
            _buildTextField('Полное имя', _name),
            const SizedBox(height: 16),
          ],
          _buildTextField('Email', _email),
          if (!_isLoginMode) ...[
            const SizedBox(height: 16),
            _buildTextField('Номер телефона', _phone),
          ],
          const SizedBox(height: 16),
          _buildPasswordField('Пароль', _password),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submitAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF030213),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(_isLoginMode ? 'Войти' : 'Зарегистрироваться'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _submitting
                ? null
                : () => setState(() => _isLoginMode = !_isLoginMode),
            child: Text(_isLoginMode
                ? 'Нет аккаунта? Регистрация'
                : 'Уже есть аккаунт? Войти'),
          ),
        ],
      );
    }

    // Профиль
    return _buildCard(
      icon: Icons.person_outline,
      title: 'Личная информация',
      children: [
        _buildTextField('Полное имя', _name),
        const SizedBox(height: 16),
        _buildTextField('Email', _email),
        const SizedBox(height: 16),
        _buildTextField('Номер телефона', _phone),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _submitting ? null : () async {
                  setState(() => _submitting = true);
                  try {
                    final updated = await AuthService.updateProfile(
                      name: _name.text.trim(),
                      phone: _phone.text.trim(),
                    );
                    setState(() {
                      _name.text = updated.name;
                      _phone.text = updated.phone;
                    });
                  } catch (e) {
                    _showError(e.toString());
                  } finally {
                    if (mounted) setState(() => _submitting = false);
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Сохранить'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _submitting ? null : () async {
                try {
                  await AuthService.logout();
                  setState(() {
                    _name.clear();
                    _email.clear();
                    _phone.clear();
                  });
                } catch (e) {
                  _showError(e.toString());
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Выйти'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF030213)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF030213),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    final isEmail = label.toLowerCase().contains('email');
    final isPhone = label.toLowerCase().contains('телефон');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF030213),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF030213),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactsCard() {
    return FutureBuilder(
      future: AuthService.getContacts(),
      builder: (context, snapshot) {
        final contacts = (snapshot.data as List?)?.cast<dynamic>() ?? [];
        return _buildCard(
          icon: Icons.contacts_outlined,
          title: 'Экстренные контакты',
          children: [
            const Text(
              'Добавьте до 3 доверенных контактов, которым придёт уведомление при SOS',
              style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
            ),
            const SizedBox(height: 16),
            for (final c in contacts) ...[
              _buildContactTile(c.id as String, c.name as String, c.phone as String, c.relationship as String),
              const SizedBox(height: 12),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: (contacts.length >= 3)
                    ? null
                    : () => _showAddOrEditContactDialog(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Добавить контакт'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactTile(String id, String name, String phone, String relationship) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF030213)),
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => _showAddOrEditContactDialog(
                      id: id,
                      name: name,
                      phone: phone,
                      relationship: relationship,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Edit'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () async {
                      await AuthService.removeContact(id);
                      if (mounted) setState(() {});
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Remove'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone, size: 12, color: Color(0xFF717182)),
              const SizedBox(width: 8),
              Text(phone, style: const TextStyle(fontSize: 14, color: Color(0xFF717182))),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.person, size: 12, color: Color(0xFF717182)),
              const SizedBox(width: 8),
              Text(relationship, style: const TextStyle(fontSize: 14, color: Color(0xFF717182))),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showAddOrEditContactDialog({String? id, String? name, String? phone, String? relationship}) async {
    final nameCtrl = TextEditingController(text: name ?? '');
    final phoneCtrl = TextEditingController(text: phone ?? '');
    final relCtrl = TextEditingController(text: relationship ?? '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == null ? 'Добавить контакт' : 'Редактировать контакт'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Имя', nameCtrl),
              const SizedBox(height: 12),
              _buildTextField('Телефон', phoneCtrl),
              const SizedBox(height: 12),
              _buildTextField('Отношение (родство)', relCtrl),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                if ((nameCtrl.text.trim()).isEmpty || (phoneCtrl.text.trim()).isEmpty) return;
                if (id == null) {
                  await AuthService.addContact(
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    relationship: relCtrl.text.trim(),
                  );
                } else {
                  // Получим текущий список и обновим один
                  final contacts = await AuthService.getContacts();
                  final updated = contacts.map((c) => c.id == id
                      ? c.copyWith(name: nameCtrl.text.trim(), phone: phoneCtrl.text.trim(), relationship: relCtrl.text.trim())
                      : c).toList();
                  // Сохраним полностью массив (упрощенно)
                  await AuthService.removeContact(id);
                  for (final c in updated) {
                    if (c.id == id) {
                      await AuthService.addContact(name: c.name, phone: c.phone, relationship: c.relationship);
                    }
                  }
                }
                if (mounted) setState(() {});
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF030213),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF717182),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF030213),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF030213),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF030213),
            ),
          ),
        ),
      ],
    );
  }

  Widget _langChip(String code, String label) {
    final current = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final isSelected = current == code;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) async {
        await LanguageService.setLocale(Locale(code));
        if (mounted) setState(() {});
      },
    );
  }

  Widget _buildPrivacyItem(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF030213),
      ),
    );
  }
}
