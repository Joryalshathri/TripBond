import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'DestinationLandingPage.dart';
import 'Bonder.dart';
import 'profile.dart';
import 'group_suggested_itinerary.dart';
import '../core/animations/animation_constants.dart';

class NearActivity {
  final String name;
  final String arrival;
  final int minutes;

  const NearActivity(
      {required this.name, required this.arrival, required this.minutes});
}

const List<NearActivity> _activities = [
  NearActivity(name: 'Ithra', arrival: '10:30', minutes: 6),
  NearActivity(name: 'Ajdan Walk', arrival: '10:35', minutes: 12),
  NearActivity(name: 'Norman ATM', arrival: '10:35', minutes: 14),
];

class CloseSpots extends StatelessWidget {
  const CloseSpots({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              _buildMap(),
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  child: _buildActivityList(),
                ),
              ),
            ],
          ),
          _buildBottomNav(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF4675B8),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: const Center(
        child: Text(
          'Close Activtes',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: Duration(milliseconds: AnimationConstants.normal),
          curve: AnimationConstants.cubicEaseOut,
        )
        .slideY(
          begin: -0.2,
          end: 0,
          duration: Duration(milliseconds: AnimationConstants.normal),
          curve: AnimationConstants.cubicEaseOut,
        );
  }

  Widget _buildMap() {
    return Container(
      height: 300,
      color: const Color(0xFFE0E5EC),
      child: Stack(
        children: [
          Center(
            child: Icon(Icons.map, size: 80, color: Colors.grey.shade400),
          ),
          _buildPin(80, 60),
          _buildPin(190, 40),
          _buildPin(230, 100),
          _buildPin(270, 30),
          _buildPin(140, 200),
        ],
      ),
    );
  }

  Widget _buildPin(double left, double top) {
    return Positioned(
      left: left,
      top: top,
      child: const Icon(Icons.location_on, size: 28, color: Color(0xFF4675B8))
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.2, 1.2),
            duration: 1200.ms,
            curve: Curves.easeInOut,
          ),
    );
  }

  Widget _buildActivityList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Near Planned Activity',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ..._activities.map((a) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF4675B8), width: 2),
                      ),
                      child: const Icon(Icons.location_on,
                          size: 14, color: Color(0xFF4675B8)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.name,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Arrival ${a.arrival}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${a.minutes} min',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )),
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
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFF4675B8),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navIcon(Icons.search, onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DestinationLandingPage()));
            }),
            _navIcon(Icons.location_on_outlined, active: true),
            _navIcon(Icons.airplanemode_active, onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const GroupSuggestedItinerary()));
            }),
            _navIcon(Icons.group_outlined, onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const Bonders()));
            }),
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
