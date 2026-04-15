import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/animations/animation_constants.dart';
import '../providers/trip_provider.dart';
import '../providers/user_provider.dart';
import 'AI_Plan.dart';
import 'bonder.dart';
import 'close_spots.dart';
import 'DestinationLandingPage.dart';
import 'profile.dart';
import 'TripHomeScreen.dart';

class PlanItem {
  final String name;
  final String image;
  final String dateRange;
  final List<String> avatarInitials;

  const PlanItem({
    required this.name,
    required this.image,
    required this.dateRange,
    this.avatarInitials = const [],
  });
}

const List<PlanItem> currentPlans = [
  PlanItem(
    name: 'Khobar',
    image: 'assets/images/cities/khobar.png',
    dateRange: '9 - 11 Apr 2026',
    avatarInitials: ['K', 'L', 'H'],
  ),
];

const List<PlanItem> futurePlans = [
  PlanItem(
    name: 'Jeddah',
    image: 'assets/images/cities/jeddah.png',
    dateRange: '25 - 27 Jul 2026',
    avatarInitials: ['Z'],
  ),
  PlanItem(
    name: 'AlUla',
    image: 'assets/images/cities/AlUla.png',
    dateRange: '5 - 20 Oct 2026',
  ),
];

const List<PlanItem> pastPlans = [
  PlanItem(
    name: 'Abha',
    image: 'assets/images/cities/Abha.png',
    dateRange: '2 - 7 Jan 2026',
    avatarInitials: ['Z'],
  ),
  PlanItem(
    name: 'Riyadh',
    image: 'assets/images/cities/Riyadh.png',
    dateRange: '5 - 20 Oct 2026',
  ),
];

const List<Color> _avatarColors = [
  Color(0xFF4675B8),
  Color(0xFFC4A44A),
  Color(0xFFE87C5D),
];

class PlansList extends StatefulWidget {
  final String source; // 'home' or 'generatedPlan'
  const PlansList({super.key, this.source = 'home'});

  @override
  State<PlansList> createState() => _PlansListState();
}

class _PlansListState extends State<PlansList> {
  bool currentOpen = true;
  bool futureOpen = true;
  bool pastOpen = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<TripProvider>(context, listen: false).fetchMyTrips();
      Provider.of<UserProvider>(context, listen: false).fetchMyProfile();
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

  //the user must not be able to create a plan without setting the date (a safety net for edge cases like corrupted backend data.)
  String _formatDateRange(Map<String, dynamic> trip) {
    if (trip['start_date'] != null && trip['end_date'] != null) {
      try {
        final start = DateTime.parse(trip['start_date']);
        final end = DateTime.parse(trip['end_date']);
        return '${start.day} - ${end.day} ${_getMonthName(end.month)} ${end.year}';
      } catch (e) {
        return 'Invalid date'; // fallback for corrupted data only
      }
    }
    // This should never happen — backend must enforce date requirement
    return 'Invalid date';
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
                                  const SizedBox(height: 16),
                                  _buildSection('Current Plans', currentOpen,
                                      () {
                                    setState(() => currentOpen = !currentOpen);
                                  }, currentTrips),
                                  const SizedBox(height: 16),
                                  _buildSection('Future Plans', futureOpen, () {
                                    setState(() => futureOpen = !futureOpen);
                                  }, futureTrips),
                                  const SizedBox(height: 16),
                                  _buildSection('Past Plans', pastOpen, () {
                                    setState(() => pastOpen = !pastOpen);
                                  }, pastPlans),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
              _buildBottomNav(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 12),
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final userName = userProvider.currentProfile?['first_name'] ?? 
              userProvider.currentProfile?['full_name'] ?? 
              'User';
          return Row(
            children: [
              const SizedBox(width: 24),
              const Spacer(),
              Text(
                "$userName's Plans",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 24),
            ],
          );
        },
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

  Widget _buildSection(
      String title, bool isOpen, VoidCallback onToggle, List<dynamic> plans) {
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
              const Spacer(),
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

  Widget _buildPlanCard(dynamic plan) {
    // Handle both PlanItem and Map<String, dynamic>
    final String name =
        plan is PlanItem ? plan.name : (plan['title'] ?? 'Untitled');
    final String image =
        plan is PlanItem ? plan.image : (plan['image_url'] ?? '');
    final String dateRange =
        plan is PlanItem ? plan.dateRange : _formatDateRange(plan);
    final List<String> avatarInitials =
        plan is PlanItem ? plan.avatarInitials : [];
    final String? tripId = plan is PlanItem ? null : (plan['id']?.toString());
    final String destination =
        plan is PlanItem ? plan.name : (plan['destination'] ?? name).toString();

    return GestureDetector(
      onTap: () {
        if (widget.source == 'generatedPlan' && tripId != null) {
          // From generated plan - navigate to AI_Plan for that trip
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AI_Plan(
                tripId: tripId,
                destination: destination,
                tripTitle: name,
              ),
            ),
          );
        } else {
          // From home - navigate to TripHomeScreen for editing
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TripHomeScreen(
                tripId: tripId,
                tripTitle: name,
                destination: destination,
              ),
            ),
          );
        }
      },
      child: Container(
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
              child: image.startsWith('http')
                  ? Image.network(
                      image,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _defaultTripImage(),
                    )
                  : image.isNotEmpty
                      ? Image.asset(
                          image,
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
                    name,
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
                  if (avatarInitials.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 24,
                      child: Stack(
                        children: List.generate(avatarInitials.length, (i) {
                          return Positioned(
                            left: i * 18.0,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _avatarColors[i % _avatarColors.length],
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                avatarInitials[i],
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultTripImage() {
    return Container(
      width: 90,
      height: 90,
      color: const Color(0xFF4675B8).withValues(alpha: 0.1),
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
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navIcon(Icons.home, active: true),
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
            _navIcon(Icons.person_outline,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const Profile()))),
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
                    borderRadius: BorderRadius.circular(1))),
          ],
        ],
      ),
    );
  }
}
