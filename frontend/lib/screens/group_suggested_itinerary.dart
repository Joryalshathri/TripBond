import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Bonder.dart';
import 'profile.dart';
import 'DestinationLandingPage.dart';
import 'AI_Plan.dart';
import 'plans_list.dart';
import 'BondersSuggestions.dart';
import '../services/trip_service.dart';
import '../providers/user_provider.dart';

final List<DateTime> _fallbackTripDays = [
  DateTime(2026, 4, 9),
  DateTime(2026, 4, 10),
  DateTime(2026, 4, 11),
];

DateTime _norm(DateTime d) => DateTime(d.year, d.month, d.day);
final Map<DateTime, List<Place>> _fallbackCalendarItinerary = {
  DateTime(2026, 4, 9): const [
    Place(
        name: 'Ithra',
        image: 'assets/images/places/Ithra.png',
        rating: 4.8,
        location: 'Dhahran'),
    Place(
        name: 'City Walk',
        image: 'assets/images/places/CityWalk.png',
        rating: 4.8,
        location: 'Olaya'),
  ],
  DateTime(2026, 4, 10): const [
    Place(
        name: 'Ajdan Walk',
        image: 'assets/images/cities/Khobar2.png',
        rating: 4.3,
        location: 'Alkurnaish'),
    Place(
        name: 'AMC Cinema',
        image: 'assets/images/places/Cinema.png',
        rating: 4.3,
        location: 'Alkurnaish'),
  ],
  DateTime(2026, 4, 11): const [
    Place(
        name: 'Parkers',
        image: 'assets/images/places/Parkers.png',
        rating: 4.4,
        location: 'Dhahran'),
    Place(
        name: 'AlKhobar Beach',
        image: 'assets/images/places/Beach.png',
        rating: 4.2,
        location: 'Khobar'),
  ],
};

ItineraryItem _placeToItem(Place place, int index) {
  const starts = ['09:00', '11:30', '14:00'];
  const ends = ['10:30', '13:00', '15:30'];
  return ItineraryItem(
    startTime: starts[index % 3],
    endTime: ends[index % 3],
    title: place.name,
    subtitle: place.location,
    location: place.location,
    person: 'You',
    color: Colors.white,
  );
}

class GroupSuggestedItinerary extends StatefulWidget {
  final String? tripId;
  final String? tripTitle;
  final String? destination;

  const GroupSuggestedItinerary({
    super.key,
    this.tripId,
    this.tripTitle,
    this.destination,
  });

  @override
  State<GroupSuggestedItinerary> createState() =>
      _GroupSuggestedItineraryState();
}

class _GroupSuggestedItineraryState extends State<GroupSuggestedItinerary> {
  final _tripService = TripService();

  late DateTime _selectedDay;
  List<DateTime> _tripDays = List<DateTime>.from(_fallbackTripDays);
  Map<DateTime, List<Place>> _calendarItinerary =
      Map<DateTime, List<Place>>.from(_fallbackCalendarItinerary);

  bool isEditMode = false;
  bool hasNotification = false;
  Set<String> deletedPlaceNames = {};

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

  List<Place> _placesForDay(DateTime day) {
    return _calendarItinerary[_norm(day)] ?? const [];
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _tripDays.first;
    _loadTripItinerary();
  }

  Future<void> _loadTripItinerary() async {
    print('DEBUG: Loading itinerary for tripId=${widget.tripId}');
    if (widget.tripId == null || widget.tripId!.isEmpty) {
      print('DEBUG: No tripId provided, using fallback data');
      return;
    }

    try {
      print('DEBUG: Fetching itinerary from API...');
      final itineraryData =
          await _tripService.getLatestItinerary(widget.tripId!);
      print('DEBUG: API Response: $itineraryData');

      final days = itineraryData['days'];
      if (days is! List || days.isEmpty) {
        print('DEBUG: No days in response, using fallback data');
        return;
      }

      final mappedDays = <DateTime>[];
      final mappedCalendar = <DateTime, List<Place>>{};

      for (final dayData in days) {
        if (dayData is! Map<String, dynamic>) continue;
        final dayNumber = dayData['day'] is int
            ? dayData['day'] as int
            : int.tryParse(dayData['day']?.toString() ?? '') ?? 1;
        final dayDate = DateTime(2026, 1, 1).add(Duration(days: dayNumber - 1));

        final activities = dayData['activities'];
        final places = <Place>[];
        if (activities is List) {
          for (final item in activities) {
            if (item is! Map<String, dynamic>) continue;
            places.add(
              Place(
                name: (item['name'] ?? 'Activity').toString(),
                image: 'assets/images/places/Ithra.png',
                rating: (item['score'] is num)
                    ? (item['score'] as num).toDouble()
                    : 4.0,
                location: (item['location'] ??
                        item['notes'] ??
                        widget.destination ??
                        'Trip')
                    .toString(),
              ),
            );
          }
        }

        mappedDays.add(dayDate);
        mappedCalendar[_norm(dayDate)] = places;
      }

      // Load actual place suggestions from database
      final placeSuggestions =
          await _tripService.getPlaceSuggestions(widget.tripId!);
      final currentUserId =
          Provider.of<UserProvider>(context, listen: false).currentProfile?['id'];
      final mappedPlaceSuggestions =
          _mapPlaceSuggestions(placeSuggestions, currentUserId);

      if (!mounted || mappedDays.isEmpty) return;
      print('DEBUG: Successfully loaded ${mappedDays.length} days from API');
      setState(() {
        _tripDays = mappedDays;
        _calendarItinerary = mappedCalendar;
        _selectedDay = _tripDays.first;
        if (mappedPlaceSuggestions.isNotEmpty) {
          suggestions = mappedPlaceSuggestions;
          hasNotification = true;
        }
      });
    } catch (e) {
      print('DEBUG: Error loading itinerary: $e');
    }
  }

  String _dayLabel(DateTime day) {
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
    return '${months[day.month]} ${day.year}';
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
        'location': (suggestion['address'] ?? widget.destination ?? 'Trip').toString(),
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

  String _weekdayLabel(DateTime day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day.weekday - 1];
  }

  void _showPlaceDetail(BuildContext context, Place place, ItineraryItem item) {
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
            const SizedBox(height: 8),
            Text(
              '${item.startTime} - ${item.endTime}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
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

  @override
  Widget build(BuildContext context) {
    final places = _placesForDay(_selectedDay);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                _buildPlanToggle(context),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_selectedDay.day}',
                                  style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(_weekdayLabel(_selectedDay),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF9E9E9E))),
                                Text(_dayLabel(_selectedDay),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF9E9E9E))),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4E0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Trip Days',
                                style: TextStyle(
                                    color: Color(0xFFC8A858),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _tripDays.map((day) {
                              final bool isSelected =
                                  _norm(_selectedDay) == _norm(day);
                              const weekdays = [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun'
                              ];
                              final String wd = weekdays[day.weekday - 1];
                              return GestureDetector(
                                onTap: () => setState(() {
                                  _selectedDay = day;
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 72,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFC8A858)
                                        : const Color(0xFFFFF4E0),
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected
                                        ? Border.all(
                                            color: const Color(0xFFC8A858),
                                            width: 2)
                                        : Border.all(
                                            color: const Color(0xFFEDD98A),
                                            width: 1),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        wd,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFFC8A858),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${day.day}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFFC8A858),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: places.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No places planned for this day.',
                                    style: TextStyle(
                                        color: Color(0xFF9E9E9E), fontSize: 14),
                                  ),
                                )
                              : ListView.builder(
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: places.length,
                                  padding: const EdgeInsets.only(bottom: 20),
                                  itemBuilder: (context, index) {
                                    final place = places[index];
                                    final bool isDeleted =
                                        deletedPlaceNames.contains(place.name);
                                    final item = _placeToItem(place, index);

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: Opacity(
                                        opacity: isDeleted ? 0.4 : 1.0,
                                        child: AbsorbPointer(
                                          absorbing: isDeleted,
                                          child: GestureDetector(
                                            onTap: () => _showPlaceDetail(
                                                context,
                                                place,
                                                _placeToItem(place, index)),
                                            child: _CalendarItineraryCard(
                                              item: item,
                                              showDelete:
                                                  isEditMode && !isDeleted,
                                              onDelete: () {
                                                setState(() {
                                                  hasNotification = true;
                                                  deletedPlaceNames
                                                      .add(place.name);
                                                  suggestions.insert(0, {
                                                    'name': place.name,
                                                    'type': 'Removed from Plan',
                                                    'location': place.location,
                                                    'person': 'You',
                                                    'personColor':
                                                        const Color(0xFF4675B8),
                                                    'highlight': false,
                                                    'action': 'delete',
                                                  });
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          _buildBottomNav(context),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PlansList(source: 'generatedPlan')),
            ),
            child: const Icon(Icons.arrow_back,
                size: 24, color: Color(0xFF1E1E1E)),
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
                                source: 'home',
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
                                source: 'home',
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
                icon: Icon(
                  isEditMode ? Icons.check : Icons.edit_outlined,
                  size: 22,
                ),
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
            child: GestureDetector(
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
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Text(
                  'Your Plan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF4675B8),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Text(
                'Calendar View',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 20,
                offset: Offset(0, -4)),
          ],
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
            SizedBox(width: 50, child: _navIcon(Icons.airplanemode_active, active: true)),
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
          if (active) ...[const SizedBox(height: 4), Container(width: 20, height: 2, color: Colors.white)]
        ],
      ),
    );
  }
}

class _CalendarItineraryCard extends StatelessWidget {
  final ItineraryItem item;
  final bool showDelete;
  final VoidCallback onDelete;

  const _CalendarItineraryCard({
    required this.item,
    required this.showDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWhite = item.color == Colors.white;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(16),
            border: isWhite ? Border.all(color: const Color(0xFFE0E0E0)) : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.startTime,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isWhite ? Colors.black : Colors.white,
                      ),
                    ),
                    Text(
                      item.endTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: isWhite
                            ? const Color(0xFF9E9E9E)
                            : Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isWhite ? Colors.black : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isWhite
                                      ? const Color(0xFF757575)
                                      : Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                          if (!showDelete)
                            Icon(
                              Icons.more_vert,
                              color: isWhite
                                  ? const Color(0xFF9E9E9E)
                                  : Colors.white,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: isWhite
                                ? const Color(0xFF9E9E9E)
                                : Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: isWhite
                                    ? const Color(0xFF757575)
                                    : Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: const Color(0xFF4675B8),
                            child: Text(
                              item.person[0],
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.person,
                            style: TextStyle(
                              fontSize: 12,
                              color: isWhite
                                  ? const Color(0xFF757575)
                                  : Colors.white.withOpacity(0.9),
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
              child: const Icon(
                Icons.close,
                color: Color.fromARGB(255, 0, 0, 0),
                size: 20,
              ),
            ),
          ),
      ],
    );
  }
}

class ItineraryItem {
  final String startTime, endTime, title, subtitle, location, person;
  final Color color;

  ItineraryItem({
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.person,
    required this.color,
  });
}
