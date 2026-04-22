import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'DestinationLandingPage.dart';
import 'Bonder.dart';
import 'profile.dart';
import 'group_suggested_itinerary.dart';
import 'plans_list.dart';
import 'BondersSuggestions.dart';
import '../services/trip_service.dart';
import '../providers/user_provider.dart';

class Place {
  final String name;
  final String image; // Can be asset path or network URL
  final double rating;
  final String location;
  final double? latitude;
  final double? longitude;
  final String? externalPlaceId;
  final String? fsqId; // Foursquare ID for detail lookups
  final String? photoUrl; // Direct photo URL from Foursquare

  const Place({
    required this.name,
    required this.image,
    required this.rating,
    required this.location,
    this.latitude,
    this.longitude,
    this.externalPlaceId,
    this.fsqId,
    this.photoUrl,
  });
}

final List<Map<String, dynamic>> _fallbackItinerary = [
  {
    'day': 1,
    'places': [
      const Place(
          name: 'Ithra',
          image: 'assets/images/places/Ithra.png',
          rating: 4.8,
          location: 'Dhahran'),
      const Place(
          name: 'City Walk',
          image: 'assets/images/places/CityWalk.png',
          rating: 4.8,
          location: 'Olaya'),
      const Place(
          name: 'Salt',
          image: 'assets/images/places/salt.jpg',
          rating: 4.6,
          location: 'Olaya'),
    ],
  },
  {
    'day': 2,
    'places': [
      const Place(
          name: 'Ajdan Walk',
          image: 'assets/images/cities/Khobar2.png',
          rating: 4.3,
          location: 'Alkurnaish'),
      const Place(
          name: 'AMC Cinema',
          image: 'assets/images/places/Cinema.png',
          rating: 4.3,
          location: 'Alkurnaish'),
      const Place(
          name: 'The Shed',
          image: 'assets/images/places/TheShed.png',
          rating: 4.5,
          location: 'Alkurnaish'),
    ],
  },
  {
    'day': 3,
    'places': [
      const Place(
          name: 'Parkers',
          image: 'assets/images/places/Parkers.png',
          rating: 4.4,
          location: 'Dhahran'),
      const Place(
          name: 'Escape The Room',
          image: 'assets/images/places/escapeTheRoom.png',
          rating: 4.2,
          location: 'Khobar'),
      const Place(
          name: 'AlKhobar Beach',
          image: 'assets/images/places/Beach.png',
          rating: 4.2,
          location: 'Khobar'),
    ],
  },
];

class AI_Plan extends StatefulWidget {
  final String? tripId;
  final String? tripTitle;
  final String? destination;

  const AI_Plan({
    super.key,
    this.tripId,
    this.tripTitle,
    this.destination,
  });
  @override
  State<AI_Plan> createState() => _AI_PlanState();
}

class _AI_PlanState extends State<AI_Plan> {
  final _tripService = TripService();
  bool isEditMode = false;
  bool hasNotification = false;
  bool _isLoadingData = false;

  late List<Map<String, dynamic>> _itinerary;
  late String _activeDestination;
  late String _activeTitle;

  // Tracking the "deleted" places (shaded)
  Set<String> deletedPlaceNames = {};

  // Suggestions list moved here to be dynamic
  List<Map<String, dynamic>> suggestions = [
    {
      'name': 'Ithra',
      'type': 'Center for World Culture',
      'location': 'Gharb Al Dhahran, Dhahran',
      'person': 'Sarah Mohammad',
      'personColor': const Color(0xFF4675B8),
      'highlight': true,
      'action': 'add',
    },
    {
      'name': 'Rakah Beach',
      'type': 'Beach',
      'location': 'Rakah',
      'person': 'Leen Mohammad',
      'personColor': const Color(0xFFC4A44A),
      'highlight': false,
      'action': 'add',
    },
  ];

  @override
  void initState() {
    super.initState();
    _itinerary = List<Map<String, dynamic>>.from(_fallbackItinerary);
    _activeDestination = widget.destination ?? 'Khobar';
    _activeTitle = widget.tripTitle ??
        'Wonderful ${_activeDestination.isEmpty ? 'Trip' : _activeDestination}';
    _loadTripData();
  }

  Future<void> _loadTripData() async {
    if (widget.tripId == null || widget.tripId!.isEmpty) return;

    setState(() => _isLoadingData = true);
    try {
      final itineraryData =
          await _tripService.getLatestItinerary(widget.tripId!);
      final mapped = _mapItineraryFromApi(itineraryData);

      final recommendations =
          await _tripService.getRecommendations(widget.tripId!);
      final mappedSuggestions =
          _mapSuggestionsFromRecommendations(recommendations);

      // Load actual place suggestions from database
      final placeSuggestions =
          await _tripService.getPlaceSuggestions(widget.tripId!);
      print('DEBUG AI_Plan: Loaded ${placeSuggestions.length} place suggestions');
      for (var ps in placeSuggestions) {
        print('DEBUG: Suggestion - ${ps['name']}, suggested_by: ${ps['suggested_by']}');
      }
      
      final currentUserId =
          Provider.of<UserProvider>(context, listen: false).currentProfile?['id'];
      print('DEBUG AI_Plan: Current user ID = $currentUserId');
      
      final mappedPlaceSuggestions =
          _mapPlaceSuggestions(placeSuggestions, currentUserId);

      if (!mounted) return;
      setState(() {
        if (mapped.isNotEmpty) {
          _itinerary = mapped;
        }
        // Combine AI recommendations and user-added suggestions
        var allSuggestions = [...mappedSuggestions, ...mappedPlaceSuggestions];
        if (allSuggestions.isNotEmpty) {
          suggestions = allSuggestions;
          hasNotification = true;
        }
      });
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  List<Map<String, dynamic>> _mapItineraryFromApi(
      Map<String, dynamic> itineraryData) {
    final days = itineraryData['days'];
    if (days is! List) return [];

    final mapped = <Map<String, dynamic>>[];
    for (final dayData in days) {
      if (dayData is! Map<String, dynamic>) continue;
      final dayNumber = dayData['day'] is int
          ? dayData['day'] as int
          : int.tryParse(dayData['day']?.toString() ?? '') ?? 1;
      final activities = dayData['activities'];
      final places = <Place>[];
      if (activities is List) {
        for (final item in activities) {
          if (item is! Map<String, dynamic>) continue;

          final photoUrl = item['photo_url'];
          final imageToUse =
              (photoUrl != null && photoUrl.toString().isNotEmpty)
                  ? photoUrl.toString()
                  : 'assets/images/places/Ithra.png';

          places.add(
            Place(
              name: (item['name'] ?? 'Activity').toString(),
              image: imageToUse,
              rating: (item['rating'] is num)
                  ? (item['rating'] as num).toDouble()
                  : (item['score'] is num)
                      ? (item['score'] as num).toDouble()
                      : 4.0,
              location:
                  (item['location'] ?? item['notes'] ?? _activeDestination)
                      .toString(),
              photoUrl: photoUrl != null ? photoUrl.toString() : null,
              fsqId: item['fsq_id']?.toString(),
            ),
          );
        }
      }

      mapped.add({'day': dayNumber, 'places': places});
    }

    return mapped;
  }

  List<Map<String, dynamic>> _mapSuggestionsFromRecommendations(
      List<Map<String, dynamic>> recommendations) {
    return recommendations.take(8).map((entry) {
      final poi = (entry['poi'] is Map<String, dynamic>)
          ? entry['poi'] as Map<String, dynamic>
          : <String, dynamic>{};

      return {
        'name': (poi['name'] ?? 'Suggested Place').toString(),
        'type': (poi['type'] ?? 'Recommendation').toString(),
        'location': (poi['location'] ?? _activeDestination).toString(),
        'person': 'TripBond AI',
        'personColor': const Color(0xFF4675B8),
        'highlight': false,
        'action': 'add',
      };
    }).toList();
  }

  List<Map<String, dynamic>> _mapPlaceSuggestions(
      List<Map<String, dynamic>> placeSuggestions, dynamic currentUserId) {
    return placeSuggestions.map((suggestion) {
      final isCurrentUserSuggestion = suggestion['suggested_by'] == currentUserId;
      return {
        'name': (suggestion['name'] ?? 'Place').toString(),
        'type': (suggestion['place_types'] is List &&
                (suggestion['place_types'] as List).isNotEmpty)
            ? ((suggestion['place_types'] as List).first).toString()
            : 'Place',
        'location': (suggestion['address'] ?? _activeDestination).toString(),
        'person': isCurrentUserSuggestion ? 'You' : 'Bonder',
        'personColor': isCurrentUserSuggestion
            ? const Color(0xFFC4A44A)
            : const Color(0xFF4675B8),
        'highlight': isCurrentUserSuggestion,
        'action': 'add',
        'suggested_by': suggestion['suggested_by'],
      };
    }).toList();
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
              _buildTopBar(context),
              _buildPlanToggle(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      if (_isLoadingData)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        ..._itinerary.map((day) => _buildDaySection(day)),
                    ],
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

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PlansList(source: 'generatedPlan')),
            ),
            child: const Icon(Icons.arrow_back, size: 24),
          ),
          const Text(
            'Generated Plan',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.notifications_outlined, size: 22),
                    onPressed: () async {
                      // Reload suggestions before opening the page
                      try {
                        final placeSuggestions =
                            await _tripService.getPlaceSuggestions(widget.tripId!);
                        final currentUserId =
                            Provider.of<UserProvider>(context, listen: false)
                                .currentProfile?['id'];
                        final mappedPlaceSuggestions =
                            _mapPlaceSuggestions(placeSuggestions, currentUserId);

                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BondersSuggestions(
                                suggestions: mappedPlaceSuggestions,
                                source: 'generatedPlan',
                              ),
                            ),
                          );
                          setState(() => hasNotification = false);
                        }
                      } catch (e) {
                        print('Error reloading suggestions: $e');
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BondersSuggestions(
                                suggestions: suggestions,
                                source: 'generatedPlan',
                              ),
                            ),
                          );
                          setState(() => hasNotification = false);
                        }
                      }
                    },
                  ),
                  if (hasNotification)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: Icon(isEditMode ? Icons.check : Icons.edit_outlined,
                    size: 22),
                onPressed: () => setState(() => isEditMode = !isEditMode),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanToggle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF4675B8),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Text(
                'Your Plan',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupSuggestedItinerary(
                    tripId: widget.tripId,
                    tripTitle: widget.tripTitle,
                    destination: widget.destination,
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Text(
                  'Calendar View',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 27),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            _activeTitle.isNotEmpty
                ? _activeTitle
                : 'Wonderful $_activeDestination,',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          Text(
            "Let's Bond Together",
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Color(0xFF4675B8),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaceModal(BuildContext context, Place place) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(place.location, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: const Color(0xFFC8A858)),
                const SizedBox(width: 6),
                Text(
                  '${place.rating.toStringAsFixed(1)} rating',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added ${place.name} to favorites'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4675B8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Save Place'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySection(Map<String, dynamic> day) {
    final int dayNum = day['day'];
    final List<Place> places = day['places'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 27),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Day $dayNum:',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18)),
                const Icon(Icons.arrow_forward,
                    size: 20, color: Color(0xFF1E1E1E)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200, // Adjusted height to accommodate responsive cards
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: places.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final place = places[index];
                final bool isDeleted = deletedPlaceNames.contains(place.name);
                return Opacity(
                  opacity: isDeleted ? 0.4 : 1.0,
                  child: AbsorbPointer(
                    absorbing: isDeleted,
                    child: GestureDetector(
                      onTap: () => _showPlaceModal(context, place),
                      child: _PlaceCard(
                        place: place,
                        showDelete: isEditMode && !isDeleted,
                        onDelete: () {
                          setState(() {
                            hasNotification = true;
                            deletedPlaceNames.add(place.name);
                            suggestions.insert(0, {
                              'name': place.name,
                              'type': 'Removed from Plan',
                              'location': place.location,
                              'person': 'You',
                              'personColor': const Color(0xFF4675B8),
                              'highlight': false,
                              'action': 'delete',
                            });
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
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
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFF4675B8),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(width: 50, child: _navIcon(Icons.home,
                onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PlansList(source: 'home'))))),
            SizedBox(width: 50, child: _navIcon(Icons.search,
                onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DestinationLandingPage())))),
            SizedBox(width: 50, child: _navIcon(
              Icons.airplanemode_active,
              active: true,
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => AI_Plan(
                    tripId: widget.tripId,
                    tripTitle: widget.tripTitle,
                    destination: widget.destination,
                  ),
                ),
              ),
            )),
            SizedBox(width: 50, child: _navIcon(Icons.group_outlined,
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const Bonders())))),
            SizedBox(width: 50, child: _navIcon(Icons.person_outline,
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const Profile())))),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, {VoidCallback? onTap, bool active = false}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.white),
          if (active) ...[
            const SizedBox(height: 4),
            Container(width: 20, height: 2, color: Colors.white),
          ],
        ],
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final Place place;
  final bool showDelete;
  final VoidCallback onDelete;

  const _PlaceCard(
      {required this.place, required this.showDelete, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    // Responsive Dimensions
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth * 0.42; // Uses percentage instead of fixed 165
    final double imageHeight = 115;

    return Stack(
      children: [
        Container(
          width: cardWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: _buildPlaceImage(place, cardWidth, imageHeight),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              place.name,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.star, size: 12, color: Color(0xFFFACC15)),
                          const SizedBox(width: 2),
                          Text(
                            '${place.rating}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 10, color: Color(0xFF4675B8)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              place.location,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDelete)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceImage(Place place, double width, double height) {
    final isNetworkUrl =
        place.photoUrl != null && place.photoUrl!.startsWith('http');

    if (isNetworkUrl) {
      return Image.network(
        place.photoUrl!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(width, height),
      );
    } else {
      return Image.asset(
        place.image,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(width, height),
      );
    }
  }

  Widget _buildPlaceholderImage(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF4675B8),
      child: const Icon(Icons.place, size: 40, color: Colors.white),
    );
  }
}