import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'DatesPage.dart';
import 'Bonder.dart';
import 'profile.dart';
import 'close_spots.dart';
import 'AI_Plan.dart';
import '../core/animations/animation_constants.dart';

List<Map<String, String>> likedPosts = [];

// GLOBAL VARIABLE: stores city name and sends it to "trip info"
String selectedCityForTrip = "";

class Destination {
  final int id;
  final String name;
  final String image;
  final List<String> stars;
  final bool featured;

  const Destination({
    required this.id,
    required this.name,
    required this.image,
    required this.stars,
    this.featured = false,
  });
}

final List<Destination> destinations = [
  Destination(
    id: 1,
    name: 'Buraidah',
    image: 'assets/images/cities/Buraidah.png',
    stars: ['star', 'star', 'star'],
  ),
  Destination(
    id: 2,
    name: 'Khobar',
    image: 'assets/images/cities/Khobar.png',
    stars: ['star', 'star', 'star'],
    featured: true,
  ),
  Destination(
    id: 3,
    name: 'Jeddah',
    image: 'assets/images/cities/jeddah.png',
    stars: ['star', 'star', 'star'],
  ),
];

final List<String> peopleAvatars = [
  'assets/images/people/person1.png',
  'assets/images/people/person2.png',
  'assets/images/people/person3.png',
];

final List<String> postAvatars = [
  'assets/images/ellipse1.png',
  'assets/images/ellipse2.png',
  'assets/images/ellipse3.png',
];

class Post {
  final String userName;
  final String location;
  final String image;
  final String title;
  final int likes;

  const Post({
    required this.userName,
    required this.location,
    required this.image,
    required this.title,
    required this.likes,
  });
}

final List<Post> posts = [
  Post(
    userName: 'Sarah Mohamed',
    location: 'Al Khobar',
    image: 'assets/images/cities/khobar2.png',
    title: 'Family Trip',
    likes: 8,
  ),
  Post(
    userName: 'Ahmed Ali',
    location: 'Jeddah',
    image: 'assets/images/cities/jeddah.png',
    title: 'Weekend Gateway',
    likes: 12,
  ),
  Post(
    userName: 'Fatima Khan',
    location: 'Riyadh',
    image: 'assets/images/cities/Riyadh.png',
    title: 'Adventure Time',
    likes: 5,
  ),
];

class DestinationLandingPage extends StatefulWidget {
  const DestinationLandingPage({super.key});

  @override
  State<DestinationLandingPage> createState() => _DestinationLandingPageState();
}

class _DestinationLandingPageState extends State<DestinationLandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      resizeToAvoidBottomInset: false,
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
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPostCard(posts[index])
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 450 + (index * 100)),
                              duration: Duration(
                                  milliseconds: AnimationConstants.normal),
                              curve: AnimationConstants.cubicEaseOut,
                            )
                            .slideY(
                              delay: Duration(milliseconds: 450 + (index * 100)),
                              begin: 0.15,
                              end: 0,
                              duration: Duration(
                                  milliseconds: AnimationConstants.normal),
                              curve: AnimationConstants.cubicEaseOut,
                            ),
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
          const Text(
            'Where We Bonding?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () {
showSearch(
      context: context,
      delegate: DestinationSearchDelegate(),
    );
            },
            icon: const Icon(Icons.search, size: 28, color: Colors.black),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
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

  Widget _buildDestinationCards(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: destinations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return _DestinationCard(
            destination: destinations[index],
            onTap: () {
              // Setting the global location directly
              selectedCityForTrip = destinations[index].name;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DatesPage()),
              );
            },
          )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 100 + (index * 80)),
                duration: Duration(milliseconds: AnimationConstants.normal),
                curve: AnimationConstants.cubicEaseOut,
              )
              .scale(
                delay: Duration(milliseconds: 100 + (index * 80)),
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: Duration(milliseconds: AnimationConstants.medium),
                curve: AnimationConstants.cubicEaseOut,
              )
              .slideX(
                delay: Duration(milliseconds: 100 + (index * 80)),
                begin: 0.2,
                end: 0,
                duration: Duration(milliseconds: AnimationConstants.medium),
                curve: AnimationConstants.cubicEaseOut,
              );
        },
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
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: Stack(
                children: List.generate(3, (i) {
                  return Positioned(
                    left: i * 20.0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF4675B8), width: 2),
                      ),
                      child: const Icon(Icons.person,
                          size: 16, color: Color(0xFF4675B8)),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '+8 people like this destination',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 350),
          duration: Duration(milliseconds: AnimationConstants.normal),
          curve: AnimationConstants.cubicEaseOut,
        )
        .slideY(
          delay: Duration(milliseconds: 350),
          begin: 0.15,
          end: 0,
          duration: Duration(milliseconds: AnimationConstants.normal),
          curve: AnimationConstants.cubicEaseOut,
        );
  }

 Widget _buildPostCard(Post post) {
    // Checking if the post is currently in the shared liked list
    bool isLiked = likedPosts.any((element) => element['name'] == post.title);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4675B8),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF121212),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Color(0xFF6F7789)),
                        const SizedBox(width: 4),
                        Text(
                          post.location,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Color(0xFF6F7789),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (!isLiked) {
                      likedPosts.add({
                        'name': post.title,
                        'location': post.location,
                        'image': post.image,
                      });
                    } else {
                      likedPosts.removeWhere(
                          (element) => element['name'] == post.title);
                    }
                  });
                },
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isLiked ? Colors.red : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              post.image,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            post.title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: Color(0xFF121212),
            ),
          ),
        ],
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
          boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, -4))],
          ),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navIcon(Icons.search, active: true),
            _navIcon(Icons.location_on_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CloseSpots()))),
            _navIcon(Icons.airplanemode_active, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AI_Plan()))),
            _navIcon(Icons.group_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Bonders()))),
            _navIcon(Icons.person_outline, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Profile()))),
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
}

class _DestinationCard extends StatefulWidget {
  final Destination destination;
  final VoidCallback onTap;

  const _DestinationCard({
    required this.destination,
    required this.onTap,
  });

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
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFeatured = widget.destination.featured;
    final width = isFeatured ? 170.0 : 150.0;
    final height = isFeatured ? 200.0 : 180.0;

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF4675B8),
                        const Color(0xFF5B89CC),
                      ],
                    ),
                  ),
                  child: Image.asset(
                    widget.destination.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.location_city,
                            size: 60, color: Colors.white),
                      );
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Text(
                    widget.destination.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DestinationSearchDelegate extends SearchDelegate {
  // "X" button to clear the text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '', // 'query' is the text the user types
      ),
    ];
  }

  //  Back button to close search
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  // What shows up when they press "Enter" (results)
  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text('Searching for "$query"...'));
  }

  // What shows up while they are typing (Suggestions)
  @override
  Widget buildSuggestions(BuildContext context) {
    // Filtering the existing destinations list based on the search query
    final suggestionList = destinations.where((city) {
      return city.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.location_city),
          title: Text(suggestionList[index].name),
          onTap: () {
            query = suggestionList[index].name;
            showResults(context);
            // Navigating directly to the city page 
          },
        );
      },
    );
  }
}