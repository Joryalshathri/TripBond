import 'package:flutter/material.dart';
import 'DestinationLandingPage.dart';
import 'profile.dart';
import 'close_spots.dart';
import 'group_suggested_itinerary.dart';
import 'plans_list.dart';

class Place {
  final String name;
  final String image;
  final double rating;
  final String location;

  const Place({
    required this.name,
    required this.image,
    required this.rating,
    required this.location,
  });
}

final List<Map<String, dynamic>> itinerary = [
  {
    'day': 1,
    'places': [
      const Place(name: 'Ithra', image: 'assets/images/places/Ithra.png', rating: 4.8, location: 'Dhahran'),
      const Place(name: 'City Walk', image: 'assets/images/places/CityWalk.png', rating: 4.8, location: 'Olaya'),
      const Place(name: 'Salt', image: 'assets/images/places/salt.jpg', rating: 4.6, location: 'Olaya'),
    ],
  },
  {
    'day': 2,
    'places': [
      const Place(name: 'Ajdan Walk', image: 'assets/images/cities/Khobar2.png', rating: 4.3, location: 'Alkurnaish'),
      const Place(name: 'AMC Cinema', image: 'assets/images/places/Cinema.png', rating: 4.3, location: 'Alkurnaish'),
      const Place(name: 'The Shed', image: 'assets/images/places/TheShed.png', rating: 4.5, location: 'Alkurnaish'),
    ],
  },
  {
    'day': 3,
    'places': [
      const Place(name: 'Parkers', image: 'assets/images/places/Parkers.png', rating: 4.4, location: 'Dhahran'),
      const Place(name: 'Escap The Room', image: 'assets/images/places/escapTheRoom.png', rating: 4.2, location: 'Khobar'),
      const Place(name: 'AlKhobar Beach', image: 'assets/images/places/Beach.png', rating: 4.2, location: 'Khobar'),
    ],
  },
];

class AI_Plan extends StatefulWidget {
  const AI_Plan({super.key});
  @override
  State<AI_Plan> createState() => _AI_PlanState();
}

class _AI_PlanState extends State<AI_Plan> {
  bool isEditMode = false;
  bool hasNotification = false;

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
                      ...itinerary.map((day) => _buildDaySection(day)),
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
              MaterialPageRoute(builder: (_) => const PlansList()),
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
                    onPressed: () {
                      _showBondersSuggestions(context);
                      setState(() => hasNotification = false);
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
                icon: Icon(isEditMode ? Icons.check : Icons.edit_outlined, size: 22),
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
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GroupSuggestedItinerary())),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Text(
                  'Calendar View',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF757575), fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBondersSuggestions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
                const Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Bonders Suggestions',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: const [
                    Text('Action', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14)),
                    SizedBox(width: 40),
                    Text('Course', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14)),
                    Spacer(),
                    Icon(Icons.filter_list, color: Color(0xFF9E9E9E), size: 20),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: suggestions.length,
                  itemBuilder: (context, i) {
                    final s = suggestions[i];
                    final isHighlight = s['highlight'] as bool;
                    final isAdd = s['action'] == 'add';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(isAdd ? 'Add' : 'Delete', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey.shade500)),
                                Icon(isAdd ? Icons.add_circle_outline : Icons.delete_outline, size: 24, color: Colors.grey.shade600),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isHighlight ? const Color(0xFFE8D5A0) : Colors.white,
                                border: Border.all(color: isHighlight ? const Color(0xFFD4BC7A) : Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(s['name'] as String, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16, color: isHighlight ? Colors.white : Colors.black)),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.favorite_border, size: 18, color: isHighlight ? Colors.white : const Color(0xFFC4A44A)),
                                          const SizedBox(width: 12),
                                          Icon(Icons.close, size: 18, color: isHighlight ? Colors.white : const Color(0xFF1E1E1E)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(s['type'] as String, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: isHighlight ? Colors.white70 : Colors.grey.shade500)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: 12, color: isHighlight ? Colors.white : const Color(0xFF4675B8)),
                                      const SizedBox(width: 4),
                                      Text(s['location'] as String, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: isHighlight ? Colors.white70 : Colors.grey.shade500)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      CircleAvatar(radius: 8, backgroundColor: s['personColor'] as Color, child: Text((s['person'] as String)[0], style: const TextStyle(fontSize: 8, color: Colors.white))),
                                      const SizedBox(width: 4),
                                      Text(s['person'] as String, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: isHighlight ? Colors.white70 : Colors.grey.shade500)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 27),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 8),
          Text('Wonderful Khobar,', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 22)),
          Text("Let's Bond Together", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 16, fontStyle: FontStyle.italic, color: Color(0xFF4675B8))),
        ],
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
                Text('Day $dayNum:', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 18)),
                const Icon(Icons.arrow_forward, size: 20, color: Color(0xFF1E1E1E)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 27),
              itemCount: places.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final place = places[index];
                final bool isDeleted = deletedPlaceNames.contains(place.name);
                return Opacity(
                  opacity: isDeleted ? 0.4 : 1.0,
                  child: AbsorbPointer(
                    absorbing: isDeleted,
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
      bottom: 0, left: 0, right: 0,
      child: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFF4675B8),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navIcon(Icons.search, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DestinationLandingPage()))),
            _navIcon(Icons.location_on_outlined, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CloseSpots()))),
            _navIcon(Icons.airplanemode_active, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AI_Plan()))),
            _navIcon(Icons.group_outlined, active: true),
            _navIcon(Icons.person_outline, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Profile()))),
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

  const _PlaceCard({
    required this.place, 
    required this.showDelete, 
    required this.onDelete
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 155,
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
                child: Image.asset(
                  place.image,
                  width: 155,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 155,
                      height: 110,
                      color: const Color(0xFF4675B8),
                      child: const Icon(Icons.place, size: 50, color: Colors.white),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 10, color: Color(0xFF4675B8)),
                        const SizedBox(width: 4),
                        Text(
                          place.location,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
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