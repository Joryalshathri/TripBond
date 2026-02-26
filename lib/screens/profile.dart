import 'package:flutter/material.dart';
import 'settings.dart';
import 'editProfile.dart';

class TripCard {
  final String name;
  final String image;
  final String location;

  const TripCard({required this.name, required this.image, required this.location});
}

const List<TripCard> _pastTrips = [
  TripCard(name: 'Family Trip', image: 'assets/images/Khobar2.png', location: 'Al Khobar'),
  TripCard(name: 'Business Trip', image: 'assets/images/Riyadh.png', location: 'Riyadh'),
  TripCard(name: 'Relaxing trip', image: 'assets/images/AlUla.png', location: 'AlUla'),
];

const List<String> _tabs = ['Past Trips', 'Liked Trips', 'Favorites'];

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _activeTab = 'Past Trips';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 90),
            child: Column(
              children: [
                _buildTopBar(),
                _buildProfileInfo(),
                _buildTabs(),
                _buildContent(),
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const editprofile())),
            child: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF1E1E1E)),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Settings())),
            child: const Icon(Icons.more_vert, size: 20, color: Color(0xFF1E1E1E)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF4675B8), width: 3),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/profile.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.person, size: 48, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Sarah Mohamed',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC4A44A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
            elevation: 0,
          ),
          child: const Text(
            'Follow',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStat('Trips', '50'),
            const SizedBox(width: 40),
            _buildStat('Followers', '503'),
            const SizedBox(width: 40),
            _buildStat('Following', '600'),
          ],
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey.shade400)),
        Text(value, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: _tabs.map((tab) {
          final isActive = tab == _activeTab;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = tab),
            child: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Column(
                children: [
                  Text(
                    tab,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: isActive ? Colors.black : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(height: 2, width: 50, color: isActive ? Colors.black : Colors.transparent),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    if (_activeTab == 'Liked Trips') {
      final images = ['assets/images/Khobar2.png', 'assets/images/jeddah.png', 'assets/images/AlUla.png'];
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: images.map((img) => SizedBox(
            width: (MediaQuery.of(context).size.width - 44) / 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(img, height: 130, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 130, color: Colors.grey.shade300, child: const Icon(Icons.image, color: Colors.grey)),
              ),
            ),
          )).toList(),
        ),
      );
    }

    if (_activeTab == 'Favorites') {
      final favs = [
        {'name': 'Alula', 'image': 'assets/images/AlUla.png'},
        {'name': 'Abha', 'image': 'assets/images/Abha.png'},
      ];
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: favs.map((f) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF4675B8),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                Image.asset(f['image']!, width: 56, height: 56, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 56, height: 56, color: Colors.grey.shade300),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(f['name']!, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white))),
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.favorite, size: 20, color: Color(0xFFEF4444)),
                ),
              ],
            ),
          )).toList(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _pastTrips.map((trip) => SizedBox(
          width: (MediaQuery.of(context).size.width - 44) / 2,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  trip.image,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 100,
                    color: Colors.grey.shade300,
                    child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.name,
                        style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 10, color: Color(0xFF4675B8)),
                          const SizedBox(width: 4),
                          Text(
                            trip.location,
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
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
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, -4))],
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
