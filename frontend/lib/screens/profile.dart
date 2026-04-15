import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'settings.dart';
import 'editProfile.dart';
import 'DestinationLandingPage.dart';
import 'Bonder.dart';
import 'close_spots.dart';
import 'AI_Plan.dart';
import 'chat_screen.dart';
import 'personality_quiz_screen.dart';
import 'feedback_screen.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import '../services/profileService.dart';
import '../services/favorites_service.dart';
import '../models/profile_model.dart';
import '../models.dart';

const List<String> _tabs = ['Posted Trips', 'Liked Trips'];

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _activeTab = 'Posted Trips';
  //int _followerCount = 503;
  //final int _followingCount = 600;

  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _error;
  final FavoritesService _favoritesService = FavoritesService();
  List<Map<String, dynamic>> _likedTrips = [];
  bool _isLoadingLikedTrips = true;
  String? _likedTripsError;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadLikedTrips();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ProfileService().fetchProfile();
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLikedTrips() async {
    try {
      final favorites = await _favoritesService.getMyFavorites();
      if (!mounted) return;
      setState(() {
        _likedTrips = favorites;
        _isLoadingLikedTrips = false;
        _likedTripsError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _likedTripsError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingLikedTrips = false;
      });
    }
  }

  final List<Map<String, String>> _followerData = [
    {'name': 'Leen', 'image': 'assets/images/people/pesron4.png'},
    {'name': 'Khalid', 'image': 'assets/images/people/person5.png'},
    {'name': 'Fatima Khan', 'image': ''},
    {'name': 'Ahmed Ali', 'image': 'assets/images/cities/jeddah.png'},
  ];

  final List<Map<String, String>> _followingData = [
    {'name': 'Huda', 'image': ''},
    {'name': 'Ziyad', 'image': 'assets/images/people/person7.png'},
    {'name': 'Friends', 'image': 'assets/images/people/friends.png'},
    {'name': 'Leen', 'image': 'assets/images/people/pesron4.png'},
  ];

  String _getTimeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 0) return '${duration.inDays}d ago';
    if (duration.inHours > 0) return '${duration.inHours}h ago';
    if (duration.inMinutes > 0) return '${duration.inMinutes}m ago';
    return 'Just now';
  }

  String _displayName() {
    final fullName = _userProfile?.fullName?.trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;

    final username = _userProfile?.username?.trim();
    if (username != null && username.isNotEmpty) return username;

    final email = _userProfile?.email.trim();
    if (email != null && email.isNotEmpty) return email.split('@').first;

    return 'User';
  }

  // ---  DELETE DIALOG ---
  Future<void> _confirmDelete(Post post) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Column(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.redAccent, size: 40),
            const SizedBox(height: 10),
            const Text("Delete Post",
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ],
        ),
        content: const Text(
          "Are you sure you want to delete this trip post? This action cannot be undone.",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: 'Poppins', fontSize: 13, color: Colors.grey),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                posts.remove(post);
              });
              Navigator.pop(context);
              // Success Notification
              showTopSnackBar(
                Overlay.of(context),
                const CustomSnackBar.success(
                  message: "Post deleted successfully",
                  backgroundColor: Color(0xFF4675B8),
                  icon: Icon(Icons.delete_outline,
                      color: Colors.white24, size: 80),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Delete",
                style: TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showFollowersList() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildFollowersModal());
  }

  void _showFollowingList() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildFollowingModal());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text('Error: $_error')),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
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
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const editprofile())),
              child: const Icon(Icons.edit_outlined,
                  size: 20, color: Color(0xFF1E1E1E))),
          PopupMenuButton<String>(
            child:
                const Icon(Icons.more_vert, size: 20, color: Color(0xFF1E1E1E)),
            onSelected: (value) {
              switch (value) {
                case 'chat':
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ChatScreen()));
                  break;
                case 'quiz':
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PersonalityQuizScreen()));
                  break;
                case 'feedback':
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FeedbackScreen()));
                  break;
                case 'settings':
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const Settings()));
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'chat',
                child: Row(
                  children: [
                    Icon(Icons.chat_outlined, size: 18),
                    SizedBox(width: 12),
                    Text('Messages'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'quiz',
                child: Row(
                  children: [
                    Icon(Icons.quiz_outlined, size: 18),
                    SizedBox(width: 12),
                    Text('Personality Quiz'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'feedback',
                child: Row(
                  children: [
                    Icon(Icons.rate_review_outlined, size: 18),
                    SizedBox(width: 12),
                    Text('Give Feedback'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 18),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    final displayName = _displayName();
    final int userTripCount =
        posts.where((p) => p.userName == displayName).length;
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color.fromARGB(255, 244, 242, 242), width: 3)),
          child: ClipOval(
            child: _userProfile?.avatarUrl != null &&
                    _userProfile!.avatarUrl!.isNotEmpty
                ? Image.network(_userProfile!.avatarUrl!, fit: BoxFit.cover)
                : Image.asset('assets/images/people/profile.png',
                    fit: BoxFit.cover),
          ),
        ).animate().scale(delay: 100.ms).fadeIn(),
        const SizedBox(height: 12),
        Text(displayName,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 20)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const editprofile())),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit Profile',
              style: TextStyle(
                  fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4675B8),
            side: const BorderSide(color: Color(0xFF4675B8)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStat('Trips', userTripCount.toString(), () {}),
            const SizedBox(width: 40),
            _buildStat('Followers', (_userProfile?.followers ?? 0).toString(),
                _showFollowersList),
            const SizedBox(width: 40),
            _buildStat('Following', (_userProfile?.following ?? 0).toString(),
                _showFollowingList),
          ],
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value, VoidCallback onTap) {
    return InkWell(
        onTap: onTap,
        child: Column(children: [
          Text(label,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.grey.shade400)),
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 18)),
        ]));
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
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
                  Text(tab,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color:
                              isActive ? Colors.black : Colors.grey.shade400)),
                  const SizedBox(height: 12),
                  Container(
                      height: 2,
                      width: 80,
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
    if (_activeTab == 'Liked Trips') return _buildLikedGrid();
    final userPosts = posts.where((p) => p.userName == _displayName()).toList();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: userPosts
            .map((post) => SizedBox(
                      width: (MediaQuery.of(context).size.width - 44) / 2,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(16)),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Image.asset(post.image,
                                    height: 110,
                                    width: double.infinity,
                                    fit: BoxFit.cover),
                                // Glass-morphic Delete Icon
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => _confirmDelete(post),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4)
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.redAccent,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post.title,
                                      style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  Row(children: [
                                    const Icon(Icons.location_on,
                                        size: 10, color: Color(0xFF4675B8)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                        child: Text(post.location,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF9E9E9E)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis))
                                  ]),
                                  Text(_getTimeAgo(post.timestamp),
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade400,
                                          fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(delay: 100.ms) // Entrance animation
                )
            .toList(),
      ),
    );
  }

  Widget _buildLikedGrid() {
    if (_isLoadingLikedTrips) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_likedTripsError != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text('Error: $_likedTripsError')),
      );
    }

    if (_likedTrips.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No liked trips yet',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _likedTrips.asMap().entries.map((entry) {
          final trip = entry.value;
          final favoriteId = (trip['id'] ?? '').toString();
          return SizedBox(
            width: (MediaQuery.of(context).size.width - 44) / 2,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(16)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(children: [
                    Container(
                      height: 100,
                      width: double.infinity,
                      color: const Color(0xFFE9EEF7),
                      child: Center(
                        child: Icon(
                          Icons.favorite,
                          color: const Color(0xFF4675B8).withValues(alpha: 0.7),
                          size: 28,
                        ),
                      ),
                    ),
                    Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                            onTap: favoriteId.isEmpty
                                ? null
                                : () async {
                                    try {
                                      await _favoritesService
                                          .removeFavorite(favoriteId);
                                      if (!mounted) return;
                                      setState(() {
                                        _likedTrips.removeAt(entry.key);
                                      });
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(e
                                              .toString()
                                              .replaceFirst('Exception: ', '')),
                                        ),
                                      );
                                    }
                                  },
                            child: const Icon(Icons.favorite,
                                size: 18, color: Color(0xFFEF4444))))
                  ]),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            (trip['destination_name'] ?? 'Liked trip')
                                .toString(),
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                        Row(children: [
                          const Icon(Icons.location_on,
                              size: 10, color: Color(0xFF4675B8)),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(
                                  (trip['destination_type'] ?? 'Trip')
                                      .toString(),
                                  style: const TextStyle(
                                      fontSize: 10, color: Color(0xFF9E9E9E)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis))
                        ]),
                        Text((trip['created_at'] ?? 'Recently').toString(),
                            style: TextStyle(
                                fontSize: 8, color: Colors.grey.shade400)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).scale(delay: 50.ms);
        }).toList(),
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
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navIcon(Icons.search,
                onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DestinationLandingPage()))),
            _navIcon(Icons.location_on_outlined,
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const CloseSpots()))),
            _navIcon(Icons.airplanemode_active,
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const AI_Plan()))),
            _navIcon(Icons.group_outlined,
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const Bonders()))),
            _navIcon(Icons.person_outline, active: true),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, {VoidCallback? onTap, bool active = false}) {
    return GestureDetector(
        onTap: onTap,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 24, color: Colors.white),
          if (active) ...[
            const SizedBox(height: 4),
            Container(
                width: 20,
                height: 2,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1)))
          ]
        ]));
  }

  Widget _buildFollowersModal() {
    return _buildUserListModal("Followers", _followerData);
  }

  Widget _buildFollowingModal() {
    return _buildUserListModal("Following", _followingData);
  }

  Widget _buildUserListModal(String title, List<Map<String, String>> users) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 20),
          Text(title,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                bool hasImage =
                    user['image'] != null && user['image']!.isNotEmpty;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        hasImage ? Colors.transparent : const Color(0xFF4675B8),
                    backgroundImage:
                        hasImage ? AssetImage(user['image']!) : null,
                    child: !hasImage
                        ? Text(user['name']![0].toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18))
                        : null,
                  ),
                  title: Text(user['name']!,
                      style: const TextStyle(
                          fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz, color: Colors.grey),
                    onSelected: (value) {
                      if (value == 'message') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ChatPage(
                                    bonderId: user['name']!,
                                    name: user['name']!)));
                      } else if (value == 'remove') {
                        setState(() {
                          users.removeAt(index);
                        });
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                          value: 'message',
                          child: Row(
                            children: const [
                              Icon(Icons.message_outlined,
                                  size: 18, color: Colors.black),
                              SizedBox(width: 10),
                              Text("Message"),
                            ],
                          )),
                      PopupMenuItem(
                          value: 'remove',
                          child: Row(
                            children: [
                              Icon(
                                  title == "Followers"
                                      ? Icons.person_remove_outlined
                                      : Icons.remove_circle_outline,
                                  size: 18,
                                  color: Colors.red),
                              const SizedBox(width: 10),
                              Text(
                                  title == "Followers"
                                      ? "Remove Follower"
                                      : "Unfollow",
                                  style: const TextStyle(color: Colors.red)),
                            ],
                          )),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
