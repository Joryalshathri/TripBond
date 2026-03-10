import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/animations/animation_constants.dart';
import '../providers/trip_provider.dart';

class PlansList extends StatefulWidget {
  const PlansList({super.key});

  @override
  State<PlansList> createState() => _PlansListState();
}

class _PlansListState extends State<PlansList> {
  bool _currentOpen = true;
  bool _futureOpen = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<TripProvider>(context, listen: false).fetchMyTrips();
    });
  }

  List<Map<String, dynamic>> _filterTripsByDate(
      List<Map<String, dynamic>> trips, bool isCurrent) {
    final now = DateTime.now();
    return trips.where((trip) {
      final startDate = trip['start_date'] != null
          ? DateTime.tryParse(trip['start_date'])
          : null;
      final endDate =
          trip['end_date'] != null ? DateTime.tryParse(trip['end_date']) : null;

      if (startDate == null || endDate == null) {
        return !isCurrent; // Put trips without dates in future
      }

      if (isCurrent) {
        // Current: ongoing trips (started but not ended)
        return startDate.isBefore(now) && endDate.isAfter(now);
      } else {
        // Future: trips that haven't started yet
        return startDate.isAfter(now);
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, child) {
          final currentTrips = _filterTripsByDate(tripProvider.myTrips, true);
          final futureTrips = _filterTripsByDate(tripProvider.myTrips, false);

          return Stack(
            children: [
              Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: tripProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 90),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  _buildSection('Current Plans', _currentOpen,
                                      () {
                                    setState(
                                        () => _currentOpen = !_currentOpen);
                                  }, currentTrips),
                                  const SizedBox(height: 16),
                                  _buildSection('Future Plans', _futureOpen,
                                      () {
                                    setState(() => _futureOpen = !_futureOpen);
                                  }, futureTrips),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
              _buildBottomNav(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back,
                size: 24, color: Color(0xFF1E1E1E)),
          ),
          const Spacer(),
          const Text(
            "Sara's Plans",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 24),
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

  Widget _buildSection(String title, bool isOpen, VoidCallback onToggle,
      List<Map<String, dynamic>> plans) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 20,
                color: Colors.black,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (isOpen) ...plans.map((plan) => _buildPlanCard(plan)),
      ],
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> trip) {
    final title = trip['title'] ?? 'Untitled Trip';
    final imageUrl = trip['image_url'];

    // Format date range
    String dateRange = '';
    if (trip['start_date'] != null && trip['end_date'] != null) {
      try {
        final start = DateTime.parse(trip['start_date']);
        final end = DateTime.parse(trip['end_date']);
        dateRange =
            '${start.day} - ${end.day} ${_getMonthName(end.month)} ${end.year}';
      } catch (e) {
        dateRange = 'Date not set';
      }
    } else {
      dateRange = 'Date not set';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _defaultTripImage(),
                  )
                : _defaultTripImage(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Color(0xFF666666)),
                    const SizedBox(width: 6),
                    Text(
                      dateRange,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultTripImage() {
    return Container(
      width: 90,
      height: 90,
      color: const Color(0xFF4675B8).withOpacity(0.1),
      child: const Icon(
        Icons.travel_explore,
        size: 40,
        color: Color(0xFF4675B8),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
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
