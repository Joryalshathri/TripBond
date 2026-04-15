import 'package:flutter/material.dart';
import '../services/trip_service.dart';
import '../services/auth_service.dart';
import '../services/poi_service.dart';
import '../core/api_config.dart';
import '../core/api_service.dart';
import 'DestinationLandingPage.dart';
import 'profile.dart';
import 'close_spots.dart';
import 'group_suggested_itinerary.dart';
import 'Bonder.dart';
import 'plans_list.dart';

class TripHomeScreen extends StatefulWidget {
  final String? tripId;
  final String? destination;
  final String? tripTitle;

  const TripHomeScreen({
    super.key,
    this.tripId,
    this.destination,
    this.tripTitle,
  });

  @override
  State<TripHomeScreen> createState() => _TripHomeScreenState();
}

class _TripHomeScreenState extends State<TripHomeScreen>
    with SingleTickerProviderStateMixin {
  final _tripService = TripService();
  final _authService = AuthService();
  final _poiService = POIService();

  late TabController _tabController;
  List<Map<String, dynamic>> _allPlaces = [];
  List<Map<String, dynamic>> _filteredPlaces = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'All';
  int _selectedIndex = 0;

  final Map<String, String> _categoryMap = {
    'All': '',
    'Popular': '',
    'Nearby': 'attraction',
    'Recommended': 'hotel',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadTripPlaces();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    _filterPlaces(_categoryMap.keys.toList()[_tabController.index] ?? 'All');
  }

  Future<void> _loadTripPlaces() async {
    try {
      setState(() => _isLoading = true);

      final destination = widget.destination ?? 'Unknown';
      
      try {
        // Fetch places from Google Maps API via POI Service
        final places = await _poiService.searchPOIs(
          location: destination,
          limit: 100,
        );

        if (places.isNotEmpty) {
          setState(() {
            _allPlaces = places;
            _filteredPlaces = List.from(places);
            _isLoading = false;
          });
        } else {
          // If no places from API, show a message but don't fail
          setState(() {
            _allPlaces = [];
            _filteredPlaces = [];
            _error = 'No recommendations found for $destination';
            _isLoading = false;
          });
        }
      } catch (apiError) {
        // If API fails, show error but allow screen to display
        print('POI Service Error: $apiError');
        setState(() {
          _allPlaces = [];
          _filteredPlaces = [];
          _error = 'Unable to fetch recommendations';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterPlaces(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All' || category.isEmpty) {
        _filteredPlaces = List.from(_allPlaces);
      } else {
        _filteredPlaces = _allPlaces
            .where((place) {
              final placeType = (place['type'] ?? place['category'] ?? '').toString().toLowerCase();
              return placeType.contains(category.toLowerCase());
            })
            .toList();
      }
    });
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
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navIcon(Icons.home, active: true),
            _navIcon(Icons.search,
                onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DestinationLandingPage()))),
            _navIcon(Icons.location_on_outlined,
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => CloseSpots(tripId: widget.tripId)))),
            _navIcon(Icons.airplanemode_active,
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => GroupSuggestedItinerary(
                      tripId: widget.tripId,
                      destination: widget.destination,
                      tripTitle: widget.tripTitle,
                    )))),
            _navIcon(Icons.group_outlined,
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const Bonders()))),
            _navIcon(Icons.person_outline,
                onTap: () => Navigator.pushReplacement(context,
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
            Container(width: 20, height: 2, color: Colors.white),
          ]
        ],
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavigationItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.search),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.location_on),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.airplanemode_active),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.group),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: '',
      ),
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlansList(source: 'home'),
                          ),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.grey),
                      ),
                      const Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage('assets/images/people/profile.png'),
                      ),
                    ],
                  ),
                ),
                // Destination Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discover ${widget.destination ?? "Destinations"}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Explore amazing places powered by Google Maps",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                // Category Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'Popular'),
                      Tab(text: 'Nearby'),
                      Tab(text: 'Recommended'),
                    ],
                    indicator: UnderlineTabIndicator(
                      borderSide: const BorderSide(
                        color: Color(0xFF4675B8),
                        width: 3,
                      ),
                      insets: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    unselectedLabelColor: Colors.grey,
                    labelColor: const Color(0xFF4675B8),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Places Grid
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline,
                                      size: 48, color: Colors.red[300]),
                                  const SizedBox(height: 16),
                                  Text('Error: $_error'),
                                ],
                              ),
                            )
                          : _selectedCategory == 'Popular' && _allPlaces.isNotEmpty
                              ? ListView(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  children: [
                                    // Top Place Section for Popular tab
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Top Place',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  // Navigate to all places
                                                },
                                                child: const Text(
                                                  'View All',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF4675B8),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          _buildTopPlaceCard(_allPlaces.first),
                                        ],
                                      ),
                                    ),
                                    // Filtered places
                                    if (_filteredPlaces.isNotEmpty)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(
                                                bottom: 12, top: 12),
                                            child: Text(
                                              'More Popular Places',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              childAspectRatio: 2.0,
                                              crossAxisSpacing: 6,
                                              mainAxisSpacing: 6,
                                            ),
                                            itemCount: _filteredPlaces.length,
                                            itemBuilder: (context, index) {
                                              final place =
                                                  _filteredPlaces[index];
                                              return _buildPlaceCard(place);
                                            },
                                          ),
                                        ],
                                      )
                                    else
                                      const SizedBox(height: 40),
                                  ],
                                )
                              : _filteredPlaces.isEmpty
                                  ? const Center(
                                      child: Text('No places found'),
                                    )
                                  : GridView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 2.0,
                                        crossAxisSpacing: 6,
                                        mainAxisSpacing: 6,
                                      ),
                                      itemCount: _filteredPlaces.length,
                                      itemBuilder: (context, index) {
                                        final place = _filteredPlaces[index];
                                        return _buildPlaceCard(place);
                                      },
                                    ),
                ),
                // Top Place Section removed - now in Popular tab only
              ],
            ),
          ),
          _buildBottomNav(context),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place) {
    // Handle multiple possible field names from different APIs
    final imageUrl = place['image_url'] as String? ?? 
                     place['photo'] as String? ??
                     place['photos']?[0] as String?;
    final name = place['name'] as String? ?? 'Unknown';
    final rating = place['rating'] as num? ?? 0;
    final description = place['description'] as String? ?? 
                       place['summary'] as String? ?? '';
    final address = place['address'] as String? ?? 
                    place['formatted_address'] as String? ?? 
                    place['vicinity'] as String? ?? '';
    final placeType = place['type'] as String? ?? 
                      place['category'] as String? ?? 'Place';

    return GestureDetector(
      onTap: () {
        // Navigate to place details
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                color: Colors.grey[200],
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.location_on,
                              color: Colors.grey, size: 40),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.location_on,
                          color: Colors.grey, size: 40),
                    ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4675B8).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            placeType,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF4675B8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () => _addPlaceToItinerary(place),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4675B8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: const Size(0, 32),
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
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
    );
  }

  bool _hasValidCoordinates(Map<String, dynamic> place) {
    final lat = place['latitude'];
    final lon = place['longitude'];
    
    // Coordinates are valid if they exist and are not 0
    bool latValid = lat != null && (lat is num) && lat != 0.0;
    bool lonValid = lon != null && (lon is num) && lon != 0.0;
    
    return latValid && lonValid;
  }
  
  Map<String, double> _getCoordinatesWithFallback(Map<String, dynamic> place, String destination) {
    final lat = place['latitude'];
    final lon = place['longitude'];
    
    // Use actual coordinates if available
    if (lat != null && (lat is num) && lat != 0.0 &&
        lon != null && (lon is num) && lon != 0.0) {
      return {
        'latitude': (lat as num).toDouble(),
        'longitude': (lon as num).toDouble(),
      };
    }
    
    // Fallback: Use destination center coordinates (Jeddah example: 21.5426, 39.1725)
    // For Jeddah
    if (destination.toLowerCase().contains('jeddah')) {
      return {
        'latitude': 21.5426,
        'longitude': 39.1725,
      };
    }
    
    // Generic fallback (could improve with geocoding API)
    return {
      'latitude': 0.0,
      'longitude': 0.0,
    };
  }

  Future<void> _addPlaceToItinerary(Map<String, dynamic> place) async {
    try {
      final name = place['name'] as String? ?? 'Unknown Place';
      final address = place['location'] as String? ?? '';
      final rating = place['rating'] as num? ?? 0.0;
      final userRatingsTotal = place['review_count'] as int? ?? 0;
      
      // Get coordinates with fallback to destination center if missing
      final coords = _getCoordinatesWithFallback(place, widget.destination ?? 'Jeddah');
      final latitude = coords['latitude']!;
      final longitude = coords['longitude']!;

      // Build itinerary item with backend expected fields
      // API returns 'type' (singular), backend endpoint expects 'types' (list)
      final placeType = place['type'] as String? ?? 'attraction';
      
      final placeData = {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'rating': rating,
        'user_ratings_total': userRatingsTotal,
        'types': [placeType],  // Convert single type to list
        'image_url': place['image_url'] ?? '',
      };

      // Suggest place to Bonders Suggestions (AI will evaluate)
      await _tripService.suggestPlaceForTrip(
        widget.tripId ?? '',
        placeData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ $name added'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error suggesting place: $e'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTopPlaceCard(Map<String, dynamic> place) {
    // Handle multiple possible field names from different APIs
    final imageUrl = place['image_url'] as String? ?? 
                     place['photo'] as String? ??
                     place['photos']?[0] as String?;
    final name = place['name'] as String? ?? 'Unknown';
    final rating = place['rating'] as num? ?? 0;
    final address = place['address'] as String? ?? 
                    place['formatted_address'] as String? ?? 
                    place['vicinity'] as String? ?? '';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              color: Colors.grey[200],
            ),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.location_on,
                          color: Colors.grey, size: 40);
                    },
                  )
                : const Icon(Icons.location_on, color: Colors.grey, size: 40),
          ),
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Color(0xFF4675B8), size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Color(0xFFC8A858), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
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
    );
  }
}
