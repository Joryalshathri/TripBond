import 'package:flutter/material.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingTrips(),
          _buildPastTrips(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddTripDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Plan Trip'),
      ),
    );
  }

  Widget _buildUpcomingTrips() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTripCard(
          'Beach Getaway',
          'Maldives',
          'March 15 - March 22, 2026',
          '7 days',
          Colors.cyan,
          Icons.beach_access,
          isUpcoming: true,
        ),
        const SizedBox(height: 12),
        _buildTripCard(
          'Mountain Trek',
          'Swiss Alps, Switzerland',
          'April 5 - April 12, 2026',
          '8 days',
          Colors.green,
          Icons.landscape,
          isUpcoming: true,
        ),
        const SizedBox(height: 12),
        _buildTripCard(
          'City Explorer',
          'Tokyo, Japan',
          'May 1 - May 8, 2026',
          '7 days',
          Colors.red,
          Icons.location_city,
          isUpcoming: true,
        ),
      ],
    );
  }

  Widget _buildPastTrips() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTripCard(
          'Paris Adventure',
          'Paris, France',
          'January 10 - January 17, 2026',
          '7 days',
          Colors.pink,
          Icons.tour,
          isUpcoming: false,
        ),
        const SizedBox(height: 12),
        _buildTripCard(
          'Dubai Luxury',
          'Dubai, UAE',
          'December 1 - December 8, 2025',
          '7 days',
          Colors.orange,
          Icons.apartment,
          isUpcoming: false,
        ),
      ],
    );
  }

  Widget _buildTripCard(
    String title,
    String location,
    String dates,
    String duration,
    Color color,
    IconData icon, {
    required bool isUpcoming,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: color.withOpacity(0.2),
                    child: Icon(icon, color: color, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dates',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dates,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      duration,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTripDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Plan New Trip'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Trip Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Destination',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trip planned successfully!')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
