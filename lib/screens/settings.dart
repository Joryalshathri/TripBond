import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<Settings> {
  bool _notificationsOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, size: 24, color: Color(0xFF1E1E1E)),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Account'),
              _buildArrowItem(Icons.info_outline, 'security'),
              _buildToggleItem(Icons.notifications_outlined, 'Notifications'),
              _buildArrowItem(Icons.lock_outline, 'Privacy'),
              const SizedBox(height: 24),
              _buildSectionTitle('Support & About'),
              _buildArrowItem(Icons.inventory_2_outlined, 'My Subscribtion'),
              _buildArrowItem(Icons.help_outline, 'Help & Support'),
              _buildArrowItem(Icons.info_outline, 'Terms and Policies'),
              const SizedBox(height: 24),
              _buildSectionTitle('Cache & cellular'),
              _buildArrowItem(Icons.inventory_2_outlined, 'Free up space'),
              _buildArrowItem(Icons.speed, 'Data Saver'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5)))),
      margin: const EdgeInsets.only(bottom: 4),
      child: Text(title, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
    );
  }

  Widget _buildArrowItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1E1E1E)),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black))),
          const Icon(Icons.chevron_right, size: 16, color: Color(0xFF999999)),
        ],
      ),
    );
  }

  Widget _buildToggleItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1E1E1E)),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black))),
          Switch(
            value: _notificationsOn,
            onChanged: (v) => setState(() => _notificationsOn = v),
            activeColor: const Color(0xFF4675B8),
          ),
        ],
      ),
    );
  }
}
