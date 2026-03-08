import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'settings.dart';
import 'editProfile.dart';
import 'DestinationLandingPage.dart';
import 'Bonder.dart'; // to access globalBonders 
import 'close_spots.dart';
import 'plans_list.dart';
import 'AI_Plan.dart';
//import '../core/animations/animation_constants.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

class TripCard {
  final String name;
  final String image;
  final String location;

  const TripCard({required this.name, required this.image, required this.location});
}

const List<TripCard> _pastTrips = [
  TripCard(name: 'Family Trip', image: 'assets/images/cities/khobar2.png', location: 'Al Khobar'),
  TripCard(name: 'Business Trip', image: 'assets/images/cities/Riyadh.png', location: 'Riyadh'),
  TripCard(name: 'Relaxing trip', image: 'assets/images/cities/AlUla.png', location: 'AlUla'),
];

const List<String> _tabs = ['Past Trips', 'Liked Trips'];

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _activeTab = 'Past Trips';
  bool _isFollowing = false;
  int _followerCount = 503;
  final int _followingCount = 600;
  final int _tripCount = 50;

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
      _followerCount += _isFollowing ? 1 : -1;
    });

    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(
        message: _isFollowing ? 'Following Sarah Mohamed' : 'Unfollow Sarah Mohamed',
        backgroundColor: const Color.fromARGB(255, 112, 204, 76),
        icon: const Icon(Icons.check, color: Colors.transparent),
      ),
      displayDuration: const Duration(seconds: 2),
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
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PlansList()));
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
          _buildBottomNav(context),
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
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color.fromARGB(255, 244, 242, 242), width: 3),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/people/profile.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.person, size: 48, color: Colors.grey),
              ),
            ),
          ),
        ).animate().scale(delay: 100.ms).fadeIn(),
        const SizedBox(height: 12),
        const Text(
          'Sarah Mohamed',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 20),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFollowing ? Colors.grey[300] : const Color(0xFFC4A44A),
                foregroundColor: _isFollowing ? Colors.black87 : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              ),
              child: Text(_isFollowing ? 'Following' : 'Follow', style: const TextStyle(fontFamily: 'Poppins')),
            ),
            if (_isFollowing) ...[
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  // Added async/await and setState to refresh state after chat
                  await Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (_) => const ChatPage(
                        name: 'Sarah Mohamed', 
                        imagePath: 'assets/images/people/profile.png'
                      )
                    )
                  );
                  setState(() {}); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4675B8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                ),
                child: const Text('Message', style: TextStyle(fontFamily: 'Poppins')),
              ).animate().fadeIn().scale(),
            ],
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStat('Trips', _tripCount.toString(), _showTripsList),
            const SizedBox(width: 40),
            _buildStat('Followers', _followerCount.toString(), _showFollowersList),
            const SizedBox(width: 40),
            _buildStat('Following', _followingCount.toString(), _showFollowingList),
          ],
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey.shade400)),
          Text(value, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _tabs.map((tab) {
          final isActive = tab == _activeTab;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = tab),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(tab, style: TextStyle(fontFamily: 'Poppins', color: isActive ? Colors.black : Colors.grey.shade400, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  Container(height: 2, width: 60, color: isActive ? Colors.black : Colors.transparent),
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
      if (likedPosts.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Text(
              "No liked trips yet! Like a post to see it here.",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: likedPosts.asMap().entries.map((entry) {
            int index = entry.key;
            var trip = entry.value;

            return SizedBox(
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
                    Stack(
                      children: [
                        Image.asset(
                          trip['image'] ?? '',
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 100, 
                            color: Colors.grey.shade300, 
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                String removedTrip = trip['name'] ?? 'Trip';
                                likedPosts.removeAt(index);
                                showTopSnackBar(
                                  Overlay.of(context),
                                  CustomSnackBar.success(
                                    message: 'Removed $removedTrip from Liked Trips',
                                    backgroundColor: const Color(0xFFEF4444),
                                    icon: const Icon(Icons.delete, color: Colors.transparent),
                                  ),
                                  displayDuration: const Duration(seconds: 2),
                                );
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white70, 
                                shape: BoxShape.circle
                              ),
                              child: const Icon(
                                Icons.favorite, 
                                size: 18, 
                                color: Color(0xFFEF4444)
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip['name'] ?? 'No Name', 
                            style: const TextStyle(
                              fontFamily: 'Poppins', 
                              fontWeight: FontWeight.w700, 
                              fontSize: 13, 
                              color: Colors.black
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 10, color: Color(0xFF4675B8)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  trip['location'] ?? 'Location', 
                                  style: TextStyle(
                                    fontFamily: 'Poppins', 
                                    fontSize: 11, 
                                    color: Colors.grey.shade500
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
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
                Image.asset(trip.image, height: 100, width: double.infinity, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.name, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 10, color: Color(0xFF4675B8)),
                          const SizedBox(width: 4),
                          Text(trip.location, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Color(0xFF9E9E9E))),
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

  Widget _buildBottomNav(BuildContext context) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFF4675B8),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navIcon(Icons.search, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DestinationLandingPage()))),
            _navIcon(Icons.location_on_outlined, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CloseSpots()))),
            _navIcon(Icons.airplanemode_active, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AI_Plan()))),
            _navIcon(Icons.group_outlined, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Bonders()))),
            _navIcon(Icons.person_outline, active: true),
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
            Container(width: 20, height: 2, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(1))),
          ],
        ],
      ),
    );
  }

  Widget _buildFollowersModal() { return Container(color: Colors.white, padding: const EdgeInsets.all(20), child: const Text("Followers List")); }
  Widget _buildFollowingModal() { return Container(color: Colors.white, padding: const EdgeInsets.all(20), child: const Text("Following List")); }
}