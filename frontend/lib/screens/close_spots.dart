import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'DestinationLandingPage.dart';
import 'Bonder.dart';
import 'profile.dart';
import 'AI_Plan.dart';
import 'plans_list.dart';
import '../core/animations/animation_constants.dart';
import '../services/trip_service.dart';

class NearActivity {
  final String name;
  final String arrival;
  final int minutes;
  final String location;
  final double latitude;
  final double longitude;

  const NearActivity({
    required this.name,
    required this.arrival,
    required this.minutes,
    this.location = '',
    required this.latitude,
    required this.longitude,
  });
}

const List<NearActivity> _defaultActivities = [
  NearActivity(
    name: 'Ithra',
    arrival: '10:30',
    minutes: 6,
    location: 'Dhahran',
    latitude: 26.3277,
    longitude: 50.1304,
  ),
  NearActivity(
    name: 'Ajdan Walk',
    arrival: '10:35',
    minutes: 12,
    location: 'Khobar',
    latitude: 26.2797,
    longitude: 50.2083,
  ),
  NearActivity(
    name: 'Norman ATM',
    arrival: '10:35',
    minutes: 14,
    location: 'Khobar',
    latitude: 26.2172,
    longitude: 50.1971,
  ),
];

class CloseSpots extends StatelessWidget {
  final String? tripId;

  const CloseSpots({super.key, this.tripId});

  @override
  Widget build(BuildContext context) {
    return _CloseSpotsView(tripId: tripId);
  }
}

class _CloseSpotsView extends StatefulWidget {
  final String? tripId;
  const _CloseSpotsView({required this.tripId});

  @override
  State<_CloseSpotsView> createState() => _CloseSpotsViewState();
}

class _CloseSpotsViewState extends State<_CloseSpotsView> {
  final _tripService = TripService();
  final _mapController = MapController();
  List<NearActivity> _activities = List<NearActivity>.from(_defaultActivities);
  bool _isLoading = false;
  int? _selectedActivityIndex;

  @override
  void initState() {
    super.initState();
    _loadNearbyFromApi();
  }

  Future<void> _loadNearbyFromApi() async {
    if (widget.tripId == null || widget.tripId!.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final recommendations =
          await _tripService.getRecommendations(widget.tripId!);
      if (!mounted || recommendations.isEmpty) return;

      final mapped =
          recommendations.take(8).toList().asMap().entries.map((entry) {
        final index = entry.key;
        final recommendation = entry.value;
        final poi = recommendation['poi'] as Map<String, dynamic>? ??
            <String, dynamic>{};
        final coordinates = (poi['coordinates'] is Map<String, dynamic>)
            ? (poi['coordinates'] as Map<String, dynamic>)
            : <String, dynamic>{};
        final fallback = _inferCoordinatesFromLocation(
          (poi['location'] ?? '').toString(),
        );
        return NearActivity(
          name: (poi['name'] ?? 'Place').toString(),
          arrival: '${10 + index}:30',
          minutes: 5 + (index * 3),
          location: (poi['location'] ?? '').toString(),
          latitude: _extractCoordinate(
            coordinates,
            ['lat', 'latitude', 'y'],
            fallback.latitude,
          ),
          longitude: _extractCoordinate(
            coordinates,
            ['lng', 'lon', 'longitude', 'x'],
            fallback.longitude,
          ),
        );
      }).toList();

      setState(() {
        _activities = mapped;
      });
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double _extractCoordinate(
    Map<String, dynamic> coordinates,
    List<String> keys,
    double fallback,
  ) {
    for (final key in keys) {
      final value = coordinates[key];
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return fallback;
  }

  LatLng _inferCoordinatesFromLocation(String location) {
    final normalized = location.toLowerCase();
    if (normalized.contains('dhahran')) {
      return const LatLng(26.3277, 50.1304);
    }
    if (normalized.contains('khobar') || normalized.contains('alkhobar')) {
      return const LatLng(26.2172, 50.1971);
    }
    if (normalized.contains('dammam')) {
      return const LatLng(26.4207, 50.0888);
    }
    return const LatLng(26.2172, 50.1971);
  }

  LatLng _mapCenter() {
    if (_activities.isEmpty) {
      return const LatLng(26.2172, 50.1971);
    }
    final latSum = _activities.fold<double>(0, (sum, a) => sum + a.latitude);
    final lngSum = _activities.fold<double>(0, (sum, a) => sum + a.longitude);
    return LatLng(latSum / _activities.length, lngSum / _activities.length);
  }

  void _focusActivityOnMap(int index) {
    final target = _activities[index];
    setState(() => _selectedActivityIndex = index);
    _mapController.move(
      LatLng(target.latitude, target.longitude),
      13.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              _buildMap(),
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  child: _buildActivityList(),
                ),
              ),
            ],
          ),
          _buildBottomNav(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF4675B8),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: const Center(
        child: Text(
          'Close Activtes',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: Duration(milliseconds: AnimationConstants.normal),
          curve: AnimationConstants.cubicEaseOut,
        )
        .slideY(
          begin: -0.2,
          end: 0,
          duration: Duration(milliseconds: AnimationConstants.normal),
          curve: AnimationConstants.cubicEaseOut,
        );
  }

  Widget _buildMap() {
    final center = _mapCenter();
    return SizedBox(
      height: 300,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: 12,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.tripbond.app',
          ),
          MarkerLayer(
            markers: _activities.asMap().entries.map((entry) {
              final index = entry.key;
              final activity = entry.value;
              final isSelected = _selectedActivityIndex == index;
              return Marker(
                point: LatLng(activity.latitude, activity.longitude),
                width: isSelected ? 44 : 36,
                height: isSelected ? 44 : 36,
                child: Icon(
                  Icons.location_on,
                  color: const Color(0xFF4675B8),
                  size: isSelected ? 42 : 34,
                )
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.12, 1.12),
                      duration: 1200.ms,
                      curve: Curves.easeInOut,
                    ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Near Planned Activities',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            )),
          ..._activities.asMap().entries.map((entry) {
            final index = entry.key;
            final a = entry.value;
            final isSelected = _selectedActivityIndex == index;
            return GestureDetector(
              onTap: () => _focusActivityOnMap(index),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEFF4FC) : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4675B8)
                        : Colors.grey.shade200,
                    width: isSelected ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF4675B8), width: 2),
                      ),
                      child: const Icon(Icons.location_on,
                          size: 14, color: Color(0xFF4675B8)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.name,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            a.location.isEmpty
                                ? 'Arrival ${a.arrival}'
                                : a.location,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${a.minutes} min',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
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
            _navIcon(Icons.home, onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PlansList()));
            }),
            _navIcon(Icons.search, onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DestinationLandingPage()));
            }),
            _navIcon(Icons.location_on_outlined, active: true),
            _navIcon(Icons.airplanemode_active, onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AI_Plan(tripId: widget.tripId)));
            }),
            _navIcon(Icons.group_outlined, onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const Bonders()));
            }),
            _navIcon(Icons.person_outline, onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const Profile()));
            }),
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
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
