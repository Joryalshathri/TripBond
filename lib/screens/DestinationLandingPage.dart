import 'package:flutter/material.dart';
import 'DatesPage.dart';

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
    stars: ['assets/images/Buraidah.png', 'assets/images/Buraidah.png', 'assets/images/Buraidah.png'],
  ),
  Destination(
    id: 2,
    name: 'Khobar',
    image: 'assets/images/Khobar.png',
    stars: ['assets/images/Khobar.png', 'assets/images/Khobar.png', 'assets/images/Khobar.png'],
    featured: true,
  ),
  Destination(
    id: 3,
    name: 'Jeddah',
    image: 'assets/images/Jeddah.png',
    stars: ['assets/images/Jeddah.png', 'assets/images/Jeddah.png', 'assets/images/Jeddah.png'],
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

class DestinationLandingPage extends StatelessWidget {
  const DestinationLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 4),
                _buildDestinationCards(context),
                const SizedBox(height: 16),
                _buildPeopleBanner(),
                const SizedBox(height: 24),
                _buildDivider(),
                const SizedBox(height: 24),
                _buildPostCard(),
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(27, 60, 27, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Where We Bonding?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Image.asset(
              'assets/figmaAssets/search-icon.svg',
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCards(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 27),
        itemCount: destinations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          return _DestinationCard(
            destination: destinations[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DatesPage()),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPeopleBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 27),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF4675B8),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Stack(
                children: List.generate(peopleAvatars.length, (i) {
                  return Positioned(
                    left: i * 18.0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF4675B8), width: 2),
                        image: DecorationImage(
                          image: AssetImage(peopleAvatars[i]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '+8 people like this destination',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.white,
                letterSpacing: 0.36,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 27),
      child: Container(
        height: 1,
        color: const Color(0xFFCAC4D0),
      ),
    );
  }

  Widget _buildPostCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDBDBDB)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/profile.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sarah Mohamed',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF121212),
                          letterSpacing: 0.28,
                          height: 25 / 14,
                        ),
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assets/figmaAssets/location-group.svg',
                            width: 14,
                            height: 14,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Al Khobar',
                            style: TextStyle(
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
                  onTap: () {},
                  child: Image.asset(
                    'assets/figmaAssets/heart-outline.svg',
                    width: 20,
                    height: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFDBDBDB)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/images/khobar2.png',
                  width: double.infinity,
                  height: 131,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Family Trip',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: Color(0xFF121212),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 20,
                  child: Stack(
                    children: List.generate(postAvatars.length, (i) {
                      return Positioned(
                        left: i * 14.0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                            image: DecorationImage(
                              image: AssetImage(postAvatars[i]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '+8 people like this Post',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.black,
                    letterSpacing: 0.36,
                  ),
                ),
              ],
            ),
          ],
        ),
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
          children: [
            _navItem('assets/figmaAssets/search-nav-icon.svg', active: true),
            _navItem('assets/figmaAssets/location-icon.svg'),
            _navItem('assets/figmaAssets/plane-icon.svg'),
            _navItem('assets/figmaAssets/users-two.svg'),
            _navItem('assets/figmaAssets/profile-shape.svg'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String icon, {bool active = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(icon, width: 24, height: 24),
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
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;

  const _DestinationCard({
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFeatured = destination.featured;
    final width = isFeatured ? 184.0 : 160.0;
    final height = isFeatured ? 208.0 : 183.0;
    final starSize = isFeatured ? 20.0 : 17.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFCCE0CC),
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                destination.image,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0x4D000000),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {},
                  child: Image.asset(
                    'assets/figmaAssets/heart-small.svg',
                    width: 13,
                    height: 12,
                  ),
                ),
              ),
              Positioned(
                bottom: 52,
                left: 0,
                right: 0,
                child: Text(
                  destination.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: destination.stars.map((star) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Image.asset(star, width: starSize, height: starSize - 1),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
