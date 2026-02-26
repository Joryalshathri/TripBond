import 'package:flutter/material.dart';

class editprofile extends StatefulWidget {
  const editprofile({super.key});

  @override
  State<editprofile> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<editprofile> {
  final _fullNameController = TextEditingController(text: 'Sarah Mohammad');
  final _dobController = TextEditingController(text: '22 - 10 - 2003');
  final _emailController = TextEditingController(text: 'youremail@domain.com');
  final _phoneController = TextEditingController(text: '+966 546944064');
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _gender = 'Female';

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 24, color: Color(0xFF1E1E1E)),
                  ),
                  const Expanded(
                    child: Text(
                      'Edit profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Personal Information:', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black)),
              const SizedBox(height: 16),
              _buildField('Full name', _fullNameController, Icons.person_outline),
              _buildField('Date of Birth', _dobController, Icons.calendar_today_outlined),
              _buildField('E-Mail', _emailController, Icons.email_outlined),
              _buildField('Phone number', _phoneController, Icons.phone_android),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                ),
                child: Row(
                  children: ['Female', 'Male'].map((g) {
                    final selected = _gender == g;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _gender = g),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFF4675B8) : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            g,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: selected ? Colors.white : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Password:', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black)),
              const SizedBox(height: 16),
              _buildPasswordField('Current Password', '********************', readOnly: true, icon: Icons.visibility_off_outlined),
              _buildPasswordField('New Password', '', controller: _newPasswordController),
              _buildPasswordField('Confirm New Password', '', controller: _confirmPasswordController),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4675B8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    elevation: 0,
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey.shade400)),
                TextField(
                  controller: controller,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                ),
              ],
            ),
          ),
          Icon(icon, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, String initial, {bool readOnly = false, IconData? icon, TextEditingController? controller}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey.shade400)),
                TextField(
                  controller: controller ?? TextEditingController(text: initial),
                  readOnly: readOnly,
                  obscureText: true,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                ),
              ],
            ),
          ),
          Icon(icon ?? Icons.lock_outline, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}
