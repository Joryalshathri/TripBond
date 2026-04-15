import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'DatesPage.dart';
import 'Bonder.dart';
import 'profile.dart';
import 'close_spots.dart';
import 'places_search_screen.dart';
import 'nearby_places_screen.dart';
import 'AI_Plan.dart';
import 'plans_list.dart';
import 'chat_screen.dart';
import 'poi_explorer_screen.dart';
import 'TripHomeScreen.dart';
import '../services/favorites_service.dart';

String selectedCityForTrip = "";

class Destination {
  final int id;
  final String name;
  final String image;
  final List<String> stars;
  final bool featured;
  const Destination(
      {required this.id,
      required this.name,
      required this.image,
      required this.stars,
      this.featured = false});
}

class Post {
  final String userName;
  final String location;
  final String image;
  final String title;
  int likes;
  String privacy;
  final DateTime timestamp; // to track actual posting time

  Post({
    required this.userName,
    required this.location,
    required this.image,
    required this.title,
    required this.likes,
    required this.privacy,
    required this.timestamp,
  });
}

// --- GLOBAL LISTS ---

final List<Destination> destinations = [
  Destination(
      id: 1,
      name: 'Buraidah',
      image: 'assets/images/cities/Buraidah.png',
      stars: ['star', 'star', 'star']),
  Destination(
      id: 2,
      name: 'Khobar',
      image: 'assets/images/cities/Khobar.png',
      stars: ['star', 'star', 'star'],
      featured: true),
  Destination(
      id: 3,
      name: 'Jeddah',
      image: 'assets/images/cities/jeddah.png',
      stars: ['star', 'star', 'star']),
];

List<Post> posts = [
  Post(
      userName: 'Sarah Mohamed',
      location: 'Al Khobar',
      image: 'assets/images/cities/khobar2.png',
      title: 'Family Trip',
      likes: 8,
      privacy: 'Public',
      timestamp: DateTime.now().subtract(const Duration(hours: 2))),
  Post(
      userName: 'Ahmed Ali',
      location: 'Jeddah',
      image: 'assets/images/cities/jeddah.png',
      title: 'Weekend Gateway',
      likes: 12,
      privacy: 'Public',
      timestamp: DateTime.now().subtract(const Duration(days: 1))),
  Post(
      userName: 'Fatima Khan',
      location: 'Riyadh',
      image: 'assets/images/cities/Riyadh.png',
      title: 'Adventure Time',
      likes: 5,
      privacy: 'Public',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45))),
];

class DestinationLandingPage extends StatefulWidget {
  const DestinationLandingPage({super.key});
  @override
  State<DestinationLandingPage> createState() => _DestinationLandingPageState();
}

class _DestinationLandingPageState extends State<DestinationLandingPage> {
  final FavoritesService _favoritesService = FavoritesService();
  final Map<String, Map<String, dynamic>> _favoriteByTitle = {};
  bool _isLoadingFavorites = true;

  // to calculate real-time differences
  String _getTimeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 0) return '${duration.inDays}d ago';
    if (duration.inHours > 0) return '${duration.inHours}h ago';
    if (duration.inMinutes > 0) return '${duration.inMinutes}m ago';
    return 'Just now';
  }

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      print('[DestinationLandingPage] Starting _loadFavorites');
      final favorites = await _favoritesService.getMyFavorites();
      print('[DestinationLandingPage] Loaded ${favorites.length} favorites');
      if (!mounted) return;
      setState(() {
        _favoriteByTitle
          ..clear()
          ..addEntries(favorites.map((favorite) {
            final title =
                (favorite['destination_name'] ?? '').toString().trim();
            return MapEntry(title, favorite);
          }).where((entry) => entry.key.isNotEmpty));
        _isLoadingFavorites = false;
      });
      print('[DestinationLandingPage] _loadFavorites completed successfully');
    } catch (e) {
      print('[DestinationLandingPage] Error loading favorites: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingFavorites = false;
      });
    }
  }

  Future<void> _toggleFavorite(Post post) async {
    final favorite = _favoriteByTitle[post.title];
    try {
      if (favorite != null) {
        await _favoritesService
            .removeFavorite((favorite['id'] ?? '').toString());
        if (!mounted) return;
        setState(() {
          _favoriteByTitle.remove(post.title);
          if (post.likes > 0) {
            post.likes--;
          }
        });
      } else {
        final savedFavorite = await _favoritesService.addFavorite(
          destinationName: post.title,
          destinationType: 'trip',
        );
        if (!mounted) return;
        setState(() {
          _favoriteByTitle[post.title] = savedFavorite;
          post.likes++;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _showPickTripSheet() {
    String selectedPrivacy = 'Public';
    String selectedCategory = 'Past Plans';
    PlanItem? selectedPlan;
    final TextEditingController titleController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            List<PlanItem> currentDisplayList;
            if (selectedCategory == 'Current Plans') {
              currentDisplayList = currentPlans;
            } else if (selectedCategory == 'Future Plans') {
              currentDisplayList = futurePlans;
            } else {
              currentDisplayList = pastPlans;
            }
            return Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  left: 24,
                  right: 24,
                  top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text("Create Post",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 22)),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Colors.black),
                          items: ['Past Plans', 'Current Plans', 'Future Plans']
                              .map((val) => DropdownMenuItem(
                                  value: val, child: Text(val)))
                              .toList(),
                          onChanged: (val) => setModalState(() {
                            selectedCategory = val!;
                            selectedPlan = null;
                          }),
                        ),
                      ),

                      // the following dropdown may be used in the future (for future improvements)
                      /* Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF4675B8), width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedPrivacy,
                              style: const TextStyle(color: Color(0xFF4675B8), fontWeight: FontWeight.bold, fontSize: 13),
                              onChanged: (val) => setModalState(() => selectedPrivacy = val!),
                              items: ['Public', 'Private'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                            ),
                          ),
                        ),*/
                    ],
                  ),
                  const Text("Select a Trip Location to post:",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  if (selectedPlan == null) ...[
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: ListView(
                        shrinkWrap: true,
                        children: currentDisplayList
                            .map((plan) => Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.shade300, width: 2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(Icons.location_on,
                                        color: Color(0xFF4675B8)),
                                    title: Text(plan.name,
                                        style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600)),
                                    subtitle: Text(plan.dateRange,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600)),
                                    trailing: const Icon(Icons.chevron_right,
                                        size: 20),
                                    onTap: () => setModalState(
                                        () => selectedPlan = plan),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ] else ...[
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(selectedPlan!.image,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover),
                        ),
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle),
                          child: const Icon(Icons.add_a_photo,
                              color: Color(0xFF4675B8), size: 28),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: "Title your ${selectedPlan!.name} trip...",
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                                color: Colors.grey.shade400, width: 2)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                                color: Color(0xFF4675B8), width: 2.5)),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4675B8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {
                          if (titleController.text.isNotEmpty) {
                            setState(() {
                              posts.insert(
                                  0,
                                  Post(
                                    userName: 'Sarah Mohamed',
                                    location: selectedPlan!.name,
                                    image: selectedPlan!.image,
                                    title: titleController.text,
                                    likes: 0,
                                    privacy: selectedPrivacy,
                                    timestamp: DateTime.now(),
                                  ));
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Post",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      resizeToAvoidBottomInset: false,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
        child: FloatingActionButton(
          onPressed: _showPickTripSheet,
          backgroundColor: const Color(0xFF4675B8),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 4),
                      _buildDestinationCards(context),
                      const SizedBox(height: 16),
                      _buildPeopleBanner(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 100, top: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPostCard(posts[index])
                            .animate()
                            .fadeIn(delay: (450 + (index * 100)).ms)
                            .slideY(begin: 0.15, end: 0),
                      );
                    },
                    childCount: posts.length,
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Where We Bonding?',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  fontSize: 22)),
          IconButton(
              onPressed: () => showSearch(
                  context: context, delegate: DestinationSearchDelegate()),
              icon: const Icon(Icons.search, size: 28)),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildDestinationCards(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: destinations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) => _DestinationCard(
                destination: destinations[index],
                onTap: () {
                  selectedCityForTrip = destinations[index].name;
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const DatesPage()));
                })
            .animate()
            .fadeIn(delay: (100 + (index * 80)).ms)
            .scale()
            .slideX(begin: 0.2),
      ),
    );
  }

  Widget _buildPeopleBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            color: const Color(0xFF4675B8),
            borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SizedBox(
                width: 70,
                child: Stack(
                    children: List.generate(
                        3,
                        (i) => Positioned(
                            left: i * 20.0,
                            child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFF4675B8),
                                        width: 2)),
                                child: const Icon(Icons.person,
                                    size: 16, color: Color(0xFF4675B8))))))),
            const SizedBox(width: 12),
            const Expanded(
                child: Text('+8 people like this destination',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.white))),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.15);
  }

  Widget _buildPostCard(Post post) {
    final isLiked = _favoriteByTitle.containsKey(post.title);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ]),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFF4675B8)),
                  child:
                      const Icon(Icons.person, color: Colors.white, size: 20)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Text(post.userName,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Text(
                        "• ${_getTimeAgo(post.timestamp)}",
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      if (post.privacy == 'Private') ...[
                        const SizedBox(width: 5),
                        const Icon(Icons.lock, size: 12, color: Colors.grey)
                      ]
                    ]),
                    Row(children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Color(0xFF6F7789)),
                      const SizedBox(width: 4),
                      Text(post.location,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF6F7789)))
                    ]),
                  ])),
              GestureDetector(
                onTap: _isLoadingFavorites
                    ? null
                    : () async => await _toggleFavorite(post),
                child: Row(
                  children: [
                    Text('${post.likes}',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isLiked ? Colors.red : Colors.grey[600])),
                    const SizedBox(width: 4),
                    Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isLiked ? Colors.red : Colors.grey[600]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(post.image,
                  width: double.infinity, height: 180, fit: BoxFit.cover)),
          const SizedBox(height: 12),
          Text(post.title,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic)),
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
                    topRight: Radius.circular(25))),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navIcon(Icons.home,
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PlansList()))),
                  _navIcon(Icons.search, active: true),
                  _navIcon(Icons.location_on_outlined,
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CloseSpots()))),
                  _navIcon(Icons.airplanemode_active,
                      onTap: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const AI_Plan()))),
                  _navIcon(Icons.group_outlined,
                      onTap: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const Bonders()))),
                  _navIcon(Icons.person_outline,
                      onTap: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const Profile()))),
                ])));
  }

  Widget _navIcon(IconData icon, {VoidCallback? onTap, bool active = false}) {
    return GestureDetector(
        onTap: onTap,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 24, color: Colors.white),
          if (active) ...[
            const SizedBox(height: 4),
            Container(width: 20, height: 2, color: Colors.white)
          ]
        ]));
  }
}

class _DestinationCard extends StatefulWidget {
  final Destination destination;
  final VoidCallback onTap;
  const _DestinationCard({required this.destination, required this.onTap});
  @override
  State<_DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<_DestinationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(vsync: this, duration: 150.ms);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) {
          _scaleController.reverse();
          widget.onTap();
        },
        child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
                width: widget.destination.featured ? 170 : 150,
                height: widget.destination.featured ? 200 : 180,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(fit: StackFit.expand, children: [
                      Image.asset(widget.destination.image, fit: BoxFit.cover),
                      Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.center,
                                  colors: [
                            Colors.black.withValues(alpha: 0.6),
                            Colors.transparent
                          ]))),
                      Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Text(widget.destination.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Colors.white)))
                    ])))));
  }
}

class DestinationSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) =>
      [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null));
  @override
  Widget buildResults(BuildContext context) =>
      Center(child: Text('Searching for "$query"...'));
  @override
  Widget buildSuggestions(BuildContext context) {
    final list = destinations
        .where((city) => city.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, i) => ListTile(
            title: Text(list[i].name),
            onTap: () {
              query = list[i].name;
              showResults(context);
            }));
  }
}
