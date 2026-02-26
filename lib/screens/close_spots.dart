import 'package:flutter/material.dart';

class NearActivity {
  final String name;
  final String arrival;
  final int minutes;

  const NearActivity({required this.name, required this.arrival, required this.minutes});
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
                  padding: const EdgeInsets.only(bottom: 90),
                  child: _buildActivityList(),
                ),
              ),
            ],
          ),
          _buildBottomNav(),
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
      child: const Icon(Icons.location_on, size: 28, color: Color(0xFF4675B8)),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        border: Border.all(color: const Color(0xFF4675B8), width: 2),
                      ),
                      child: const Icon(Icons.location_on, size: 14, color: Color(0xFF4675B8)),
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

  Widget _buildBottomNav() {
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
          children: const [
            Icon(Icons.search, size: 24, color: Colors.white),
            Icon(Icons.location_on_outlined, size: 24, color: Colors.white),
            Icon(Icons.airplanemode_active, size: 24, color: Colors.white),
            Icon(Icons.group_outlined, size: 24, color: Colors.white),
            Icon(Icons.person_outline, size: 24, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
