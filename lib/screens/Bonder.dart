import 'package:flutter/material.dart';

class Bonders extends StatelessWidget {
  const Bonders({super.key});

  static const bonders = [
    {'name': 'Leen', 'image': 'assets/images/persone4.png'},
    {'name': 'Khalid', 'image': 'assets/images/persone5.png'},
    {'name': 'Huda', 'image': 'assets/images/persone6.png'},
    {'name': 'Ziyad', 'image': 'assets/images/persone7.png'},
    {'name': 'Friends', 'image': 'assets/images/friends.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 100),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(child: SizedBox()),
                        const Text(
                          'Bonders',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        const Icon(Icons.group_outlined, size: 24, color: Color(0xFF1E1E1E)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ...bonders.map((b) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade100, width: 2),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                b['image']!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.person, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            b['name']!,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
