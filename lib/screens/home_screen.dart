import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/animations/animation_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TripBond'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Where to next?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'Search destinations...',
                            border: InputBorder.none,
                            icon: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Popular Destinations Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Popular Destinations',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final destinations = [
                          {
                            'name': 'Paris',
                            'country': 'France',
                            'color': Colors.pink
                          },
                          {
                            'name': 'Tokyo',
                            'country': 'Japan',
                            'color': Colors.red
                          },
                          {
                            'name': 'New York',
                            'country': 'USA',
                            'color': Colors.blue
                          },
                          {
                            'name': 'Dubai',
                            'country': 'UAE',
                            'color': Colors.orange
                          },
                          {
                            'name': 'London',
                            'country': 'UK',
                            'color': Colors.indigo
                          },
                        ];
                        return _buildDestinationCard(
                          destinations[index]['name'] as String,
                          destinations[index]['country'] as String,
                          destinations[index]['color'] as Color,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Upcoming Trips Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Upcoming Trips',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTripCard(
                    'Beach Paradise',
                    'Maldives',
                    'Mar 15 - Mar 22',
                    Icons.beach_access,
                    Colors.cyan,
                  ),
                  const SizedBox(height: 12),
                  _buildTripCard(
                    'Mountain Adventure',
                    'Switzerland',
                    'Apr 5 - Apr 12',
                    Icons.landscape,
                    Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(String city, String country, Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_city, size: 48, color: color),
          const SizedBox(height: 8),
          Text(
            city,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            country,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          duration:
              const Duration(milliseconds: AnimationConstants.normal),
          curve: AnimationConstants.cubicEaseOut,
        )
        .slideX(
          begin: 0.1,
          duration:
              const Duration(milliseconds: AnimationConstants.normal),
          curve: AnimationConstants.cubicEaseOut,
        )
        .scale(
          begin: const Offset(0.9, 0.9),
          duration:
              const Duration(milliseconds: AnimationConstants.normal),
          curve: AnimationConstants.cubicEaseOut,
        );
  }

  Widget _buildTripCard(
      String title, String location, String dates, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$location • $dates'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    )
        .animate()
        .fadeIn(
          duration:
              const Duration(milliseconds: AnimationConstants.normal),
          curve: AnimationConstants.cubicEaseOut,
        )
        .slideX(
          begin: -0.1,
          duration:
              const Duration(milliseconds: AnimationConstants.normal),
          curve: AnimationConstants.cubicEaseOut,
        );
  }
}
