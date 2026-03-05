import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'DestinationLandingPage.dart';
import 'profile.dart';
import 'close_spots.dart';
import 'group_suggested_itinerary.dart';
import '../core/animations/animation_constants.dart';

class Bonders extends StatelessWidget {
  const Bonders({super.key});

  static const bonders = [
    {'name': 'Leen', 'image': 'assets/images/people/persone4.png'},
    {'name': 'Khalid', 'image': 'assets/images/people/persone5.png'},
    {'name': 'Huda', 'image': 'assets/images/people/persone6.png'},
    {'name': 'Ziyad', 'image': 'assets/images/people/persone7.png'},
    {'name': 'Friends', 'image': 'assets/images/people/friends.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 90),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 100),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                child: const Icon(Icons.arrow_back,
                                    size: 24, color: Color(0xFF1E1E1E)),
                              ),
                            ),
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
                            const Icon(Icons.group_outlined,
                                size: 24, color: Color(0xFF1E1E1E)),
                          ],
                        )
                            .animate()
                            .fadeIn(
                              duration: Duration(
                                  milliseconds: AnimationConstants.normal),
                              curve: AnimationConstants.cubicEaseOut,
                            )
                            .slideY(
                              begin: -0.1,
                              end: 0,
                              duration: Duration(
                                  milliseconds: AnimationConstants.normal),
                              curve: AnimationConstants.cubicEaseOut,
                            ),
                        const SizedBox(height: 24),
                        ...bonders.asMap().entries.map((entry) {
                          final index = entry.key;
                          final b = entry.value;
                          return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const GroupSuggestedItinerary(),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.grey.shade100,
                                            width: 2),
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          b['image']!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            color: Colors.grey.shade300,
                                            child: const Icon(Icons.person,
                                                color: Colors.grey),
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
                              )
                                  .animate()
                                  .fadeIn(
                                    delay: Duration(
                                        milliseconds: 150 + (index * 80)),
                                    duration: Duration(
                                        milliseconds:
                                            AnimationConstants.normal),
                                    curve: AnimationConstants.cubicEaseOut,
                                  )
                                  .slideX(
                                    delay: Duration(
                                        milliseconds: 150 + (index * 80)),
                                    begin: 0.2,
                                    end: 0,
                                    duration: Duration(
                                        milliseconds:
                                            AnimationConstants.normal),
                                    curve: AnimationConstants.cubicEaseOut,
                                  ));
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          _buildBottomNav(context),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFF4675B8),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navIcon(Icons.search, onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DestinationLandingPage()));
            }),
            _navIcon(Icons.location_on_outlined, onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CloseSpots()));
            }),
            _navIcon(Icons.airplanemode_active, onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const GroupSuggestedItinerary()));
            }),
            _navIcon(Icons.group_outlined, active: true),
            _navIcon(Icons.person_outline, onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const Profile()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, {VoidCallback? onTap, bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.white),
          if (active) ...[
            const SizedBox(height: 4),
            Container(
              width: 20,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
