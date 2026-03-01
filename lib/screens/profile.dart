import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'settings.dart';
import 'editProfile.dart';
import 'DestinationLandingPage.dart';
import 'Bonder.dart';
import 'close_spots.dart';
import 'group_suggested_itinerary.dart';
import 'plans_list.dart';
import '../core/animations/animation_constants.dart';

class TripCard {
  final String name;
  final String image;
  final String location;

  const TripCard(
      {required this.name, required this.image, required this.location});
}

const List<TripCard> _pastTrips = [
  TripCard(
      name: 'Family Trip',
      image: 'assets/images/Khobar2.png',
      location: 'Al Khobar'),
  TripCard(
      name: 'Business Trip',
      image: 'assets/images/Riyadh.png',
      location: 'Riyadh'),
  TripCard(
      name: 'Relaxing trip',
      image: 'assets/images/AlUla.png',
      location: 'AlUla'),
];

const List<String> _tabs = ['Past Trips', 'Liked Trips', 'Favorites'];

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _activeTab = 'Past Trips';
  bool _isFollowing = false;
  int _followerCount = 503;
  int _followingCount = 600;
  int _tripCount = 50;

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
      _followerCount += _isFollowing ? 1 : -1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFollowing ? 'Following Sarah Mohamed' : 'Unfollowed Sarah Mohamed',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF4675B8),
      ),
    );
  }

  void _showFollowersList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFollowersModal(),
    );
  }

  void _showFollowingList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFollowingModal(),
    );
  }

  void _showTripsList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlansList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  _buildTopBar(),
                  _buildProfileInfo(),
                  _buildTabs(),
                  _buildContent(),
                ],
              ),
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
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const editprofile())),
            child: const Icon(Icons.edit_outlined,
                size: 20, color: Color(0xFF1E1E1E)),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const Settings())),
            child:
                const Icon(Icons.more_vert, size: 20, color: Color(0xFF1E1E1E)),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          duration: Duration(milliseconds: AnimationConstants.normal),
          curve: AnimationConstants.cubicEaseOut,
        )
        .slideY(
          begin: -0.1,
          end: 0,
          duration: Duration(milliseconds: AnimationConstants.normal),
          curve: AnimationConstants.cubicEaseOut,
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
        )
            .animate()
            .scale(
              delay: Duration(milliseconds: 100),
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: Duration(milliseconds: AnimationConstants.medium),
              curve: AnimationConstants.cubicEaseOut,
            )
            .fadeIn(
              delay: Duration(milliseconds: 100),
              duration: Duration(milliseconds: AnimationConstants.normal),
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
          onPressed: _toggleFollow,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isFollowing ? Colors.grey[300] : const Color(0xFFC4A44A),
            foregroundColor: _isFollowing ? Colors.black87 : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
            elevation: _isFollowing ? 0 : 2,
          ),
          child: Text(
            _isFollowing ? 'Following' : 'Follow',
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStat('Trips', _tripCount.toString(), _showTripsList),
            const SizedBox(width: 40),
            _buildStat(
                'Followers', _followerCount.toString(), _showFollowersList),
            const SizedBox(width: 40),
            _buildStat(
                'Following', _followingCount.toString(), _showFollowingList),
          ],
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey.shade400)),
            Text(value,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
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
                  Container(
                      height: 2,
                      width: 50,
                      color: isActive ? Colors.black : Colors.transparent),
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
      final images = [
        'assets/images/Khobar2.png',
        'assets/images/jeddah.png',
        'assets/images/AlUla.png'
      ];
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: images
              .map((img) => SizedBox(
                    width: (MediaQuery.of(context).size.width - 44) / 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        img,
                        height: 130,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            height: 130,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image, color: Colors.grey)),
                      ),
                    ),
                  ))
              .toList(),
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
          children: favs
              .map((f) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4675B8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      children: [
                        Image.asset(
                          f['image']!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              width: 56,
                              height: 56,
                              color: Colors.grey.shade300),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Text(f['name']!,
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.white))),
                        const Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Icon(Icons.favorite,
                              size: 20, color: Color(0xFFEF4444)),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _pastTrips
            .map((trip) => SizedBox(
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
                            child: const Center(
                                child: Icon(Icons.image, color: Colors.grey)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.name,
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Colors.black),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 10, color: Color(0xFF4675B8)),
                                  const SizedBox(width: 4),
                                  Text(
                                    trip.location,
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFF4675B8),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, -8)),
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
            _navIcon(Icons.group_outlined, onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const Bonders()));
            }),
            _navIcon(Icons.person_outline, active: true),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowersModal() {
    final List<Map<String, String>> followers = [
      {
        'name': 'Ahmed Al-Said',
        'username': '@ahmed_said',
        'image': 'assets/images/profile.png'
      },
      {
        'name': 'Fatima Hassan',
        'username': '@fatima_h',
        'image': 'assets/images/profile.png'
      },
      {
        'name': 'Mohammed Ali',
        'username': '@mo_ali',
        'image': 'assets/images/profile.png'
      },
      {
        'name': 'Layla Ibrahim',
        'username': '@layla_i',
        'image': 'assets/images/profile.png'
      },
      {
        'name': 'Omar Khalid',
        'username': '@omar_k',
        'image': 'assets/images/profile.png'
      },
      {
        'name': 'Zainab Nasser',
        'username': '@zainab_n',
        'image': 'assets/images/profile.png'
      },
      {
        'name': 'Youssef Rahman',
        'username': '@youssef_r',
        'image': 'assets/images/profile.png'
      },
      {
        'name': 'Aisha Malik',
        'username': '@aisha_m',
        'image': 'assets/images/profile.png'
      },
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Followers',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _followerCount.toString(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: followers.length,
                itemBuilder: (context, index) {
                  final follower = followers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF4675B8),
                      child: Text(
                        follower['name']![0],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      follower['name']!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      follower['username']!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4675B8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Follow',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF4675B8),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: index * 50),
                        duration: const Duration(milliseconds: 300),
                      )
                      .slideX(
                        begin: 0.2,
                        end: 0,
                        delay: Duration(milliseconds: index * 50),
                        duration: const Duration(milliseconds: 300),
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowingModal() {
    final List<Map<String, String>> following = [
      {
        'name': 'Noura Al-Qahtani',
        'username': '@noura_q',
        'image': 'assets/images/profile.png'
      },
      {
        'name': 'Khalid Mansour',
        'username': '@khalid_m',
        'image': 'assets/images/profile.png'
      },
      {
        'name': 'Reem Abdullah',
        'username': '@reem_a',
        'image': 'assets/images/profile.png'
      },
      {
        'name': 'Sami Faisal',
        'username': '@sami_f',
        'image': 'assets/images/profile.png'
      },
      {
        'name': 'Hala Zayed',
        'username': '@hala_z',
        'image': 'assets/images/profile.png'
      },
      {
        'name': 'Tariq Nabil',
        'username': '@tariq_n',
        'image': 'assets/images/profile.png'
      },
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Following',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _followingCount.toString(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: following.length,
                itemBuilder: (context, index) {
                  final user = following[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFC4A44A),
                      child: Text(
                        user['name']![0],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      user['name']!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      user['username']!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Following',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: index * 50),
                        duration: const Duration(milliseconds: 300),
                      )
                      .slideX(
                        begin: 0.2,
                        end: 0,
                        delay: Duration(milliseconds: index * 50),
                        duration: const Duration(milliseconds: 300),
                      );
                },
              ),
            ),
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
