import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'DatesPage.dart';
import 'Bonder.dart';
import 'profile.dart';
import 'close_spots.dart';
import 'group_suggested_itinerary.dart';
import '../core/animations/animation_constants.dart';

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
    image: 'assets/images/Buraidah.png',
    stars: ['star', 'star', 'star'],
  ),
  Destination(
    id: 2,
    name: 'Khobar',
    image: 'assets/images/Khobar.png',
    stars: ['star', 'star', 'star'],
    featured: true,
  ),
  Destination(
    id: 3,
    name: 'Jeddah',
    image: 'assets/images/Jeddah.png',
    stars: ['star', 'star', 'star'],
  ),
];

final List<String> peopleAvatars = [
  'assets/images/person1.png',
  'assets/images/person2.png',
  'assets/images/person3.png',
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
    image: 'assets/images/khobar2.png',
    title: 'Family Trip',
    likes: 8,
  ),
  Post(
    userName: 'Ahmed Ali',
    location: 'Jeddah',
    image: 'assets/images/jeddah_post.png',
    title: 'Weekend Gateway',
    likes: 12,
  ),
  Post(
    userName: 'Fatima Khan',
    location: 'Riyadh',
    image: 'assets/images/riyadh_post.png',
    title: 'Adventure Time',
    likes: 5,
  ),
];

class DestinationLandingPage extends StatelessWidget {
  const DestinationLandingPage({super.key});

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
                              delay:
                                  Duration(milliseconds: 450 + (index * 100)),
                              duration: Duration(
                                  milliseconds: AnimationConstants.normal),
                              curve: AnimationConstants.cubicEaseOut,
                            )
                            .slideY(
                              delay:
                                  Duration(milliseconds: 450 + (index * 100)),
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
            onPressed: () {},
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
                        letterSpacing: 0.28,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Color(0xFF6F7789)),
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
              Icon(Icons.favorite_border, size: 20, color: Colors.grey[600])
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.08, 1.08),
                    duration: 1500.ms,
                    curve: Curves.easeInOut,
                  ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              height: 180,
              color: Colors.grey[200],
              child: Image.asset(
                post.image,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF4675B8).withOpacity(0.3),
                          const Color(0xFF4675B8).withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: const Icon(Icons.image,
                        size: 50, color: Color(0xFF4675B8)),
                  );
                },
              ),
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
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 50,
                height: 24,
                child: Stack(
                  children: List.generate(3, (i) {
                    return Positioned(
                      left: i * 16.0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4675B8),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.person,
                            size: 12, color: Colors.white),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+${post.likes} people like this Post',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF6F7789),
                  letterSpacing: 0.36,
                ),
              ),
            ],
          ),
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
            _navIcon(Icons.search, active: true, onTap: () {}, index: 0),
            _navIcon(Icons.location_on_outlined, onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CloseSpots()));
            }, index: 1),
            _navIcon(Icons.airplanemode_active, onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const GroupSuggestedItinerary()));
            }, index: 2),
            _navIcon(Icons.group_outlined, onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const Bonders()));
            }, index: 3),
            _navIcon(Icons.person_outline, onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const Profile()));
            }, index: 4),
          ],
        ),
      ).animate().slideY(
            begin: 1.0,
            end: 0,
            duration: Duration(milliseconds: AnimationConstants.medium),
            curve: AnimationConstants.cubicEaseOut,
          ),
    );
  }

  Widget _navIcon(IconData icon,
      {VoidCallback? onTap, bool active = false, int index = 0}) {
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
            )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(duration: 800.ms)
                .then()
                .fadeOut(duration: 800.ms),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 500 + (index * 50)),
          duration: Duration(milliseconds: AnimationConstants.fast),
          curve: AnimationConstants.cubicEaseOut,
        )
        .scale(
          delay: Duration(milliseconds: 500 + (index * 50)),
          begin: const Offset(0.7, 0.7),
          end: const Offset(1.0, 1.0),
          duration: Duration(milliseconds: AnimationConstants.normal),
          curve: AnimationConstants.cubicEaseOut,
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
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
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
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.destination.stars.map((star) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(Icons.star, color: Colors.amber, size: 16),
                      );
                    }).toList(),
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
