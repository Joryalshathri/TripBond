import 'package:flutter/material.dart';
//import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'close_spots.dart';
import 'Bonder.dart';
import 'profile.dart';
import 'DestinationLandingPage.dart';
import 'AI_Plan.dart';
import 'plans_list.dart';
//import '../core/animations/animation_constants.dart';

class GroupSuggestedItinerary extends StatefulWidget {
  const GroupSuggestedItinerary({super.key});

  @override
  State<GroupSuggestedItinerary> createState() =>
      _GroupSuggestedItineraryState();
}

class _GroupSuggestedItineraryState extends State<GroupSuggestedItinerary> {
  DateTime _selectedDay = DateTime(2026, 1, 24);
  DateTime _focusedDay = DateTime(2026, 1, 24);
  bool hasNotification = false;

  final List<ItineraryItem> _itineraryItems = [
    ItineraryItem(
      startTime: '11:35',
      endTime: '10-05',
      title: 'Ithra',
      subtitle: 'Culture Festival',
      location: 'Ghada Al Dhahmn, Dhahrnn',
      person: 'Khalid Mohammad',
      color: const Color(0xFFC8A858),
    ),
    ItineraryItem(
      startTime: '13:15',
      endTime: '14-45',
      title: 'LWF',
      subtitle: 'Burger Joint',
      location: 'Ghada Al Dhahmn, Dhahrnn',
      person: 'Leen Mohammad',
      color: Colors.white,
    ),
    ItineraryItem(
      startTime: '15:10',
      endTime: '16-40',
      title: 'Rakah Beach',
      subtitle: 'Beach',
      location: 'Rakah',
      person: 'Huda Mohammad',
      color: Colors.white,
    ),
  ];

  // Suggestions list for the modal
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
                              children: const [
                                Text('24', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w600)),
                                Text('Wed', style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E))),
                                Text('Jan 2026', style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E))),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4E0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Today',
                                style: TextStyle(color: Color(0xFFC8A858), fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 70,
                          child: TableCalendar(
                            firstDay: DateTime(2026, 1, 1),
                            lastDay: DateTime(2026, 12, 31),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                            calendarFormat: CalendarFormat.week,
                            headerVisible: false,
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            calendarStyle: CalendarStyle(
                              selectedDecoration: BoxDecoration(color: const Color(0xFF4675B8), borderRadius: BorderRadius.circular(8)),
                              todayDecoration: BoxDecoration(color: const Color(0xFF4675B8).withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            physics: const ClampingScrollPhysics(),
                            itemCount: _itineraryItems.length,
                            padding: const EdgeInsets.only(bottom: 20),
                            itemBuilder: (context, index) {
                              final item = _itineraryItems[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ItineraryCard(item: item),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildBottomNav(context),
        ],
      ),
    );
  }

  // MODIFIED: Fixed overflow and position for consistency
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12), // Reduced top padding for SafeArea
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlansList())),
            child: const Icon(Icons.arrow_back, size: 24, color: Color(0xFF1E1E1E)),
          ),
          const Text(
            'Generated Plan',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 22),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact, // Primary fix for overflow
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.notifications_outlined, size: 24, color: Color(0xFF1E1E1E)),
                    onPressed: () {
                      _showBondersSuggestions(context);
                      setState(() => hasNotification = false);
                    },
                    constraints: const BoxConstraints(),
                  ),
                  if (hasNotification)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red)),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              const Icon(Icons.edit, size: 22, color: Color(0xFF1E1E1E)),
            ],
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
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
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
                    child: Text('Bonders Suggestions', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 22)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children: const [
                        Text('Action', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14)),
                        SizedBox(width: 40),
                        Text('Course', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14)),
                        Spacer(),
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
                            crossAxisAlignment: CrossAxisAlignment.center, // Centered alignment
                            children: [
                              SizedBox(
                                width: 50,
                                child: Column(
                                  children: [
                                    Text(isAdd ? 'Add' : 'Delete', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey.shade500)),
                                    Icon(isAdd ? Icons.add_circle_outline : Icons.delete_outline, size: 20, color: Colors.grey.shade600),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
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
                                          Row( // MODIFIED: Correct icon spacing and alignment
                                            children: [
                                              Icon(Icons.favorite_border, size: 18, color: isHighlight ? Colors.white : const Color(0xFFC4A44A)),
                                              const SizedBox(width: 12),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() => hasNotification = true);
                                                  setModalState(() {
                                                    suggestions[i]['highlight'] = false;
                                                    suggestions[i]['action'] = 'delete';
                                                  });
                                                },
                                                child: Icon(Icons.close, size: 18, color: isHighlight ? Colors.white : const Color(0xFF1E1E1E)),
                                              ),
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
      },
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
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AI_Plan())),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Text(
                  'Your Plan',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF757575), fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFF4675B8), borderRadius: BorderRadius.circular(25)),
              child: const Text(
                'Calendar View',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
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
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, -4))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navIcon(Icons.search, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DestinationLandingPage()))),
            _navIcon(Icons.location_on_outlined, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CloseSpots()))),
            _navIcon(Icons.airplanemode_active),
            _navIcon(Icons.group_outlined, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Bonders()))),
            _navIcon(Icons.person_outline, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Profile()))),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 24, color: Colors.white),
    );
  }
}

class ItineraryCard extends StatelessWidget {
  final ItineraryItem item;
  const ItineraryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: item.color,
        borderRadius: BorderRadius.circular(16),
        border: item.color == Colors.white ? Border.all(color: const Color(0xFFE0E0E0)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.startTime, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: item.color == Colors.white ? Colors.black : Colors.white)),
                Text(item.endTime, style: TextStyle(fontSize: 12, color: item.color == Colors.white ? const Color(0xFF9E9E9E) : Colors.white.withOpacity(0.7))),
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
                          Text(item.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: item.color == Colors.white ? Colors.black : Colors.white)),
                          const SizedBox(height: 2),
                          Text(item.subtitle, style: TextStyle(fontSize: 13, color: item.color == Colors.white ? const Color(0xFF757575) : Colors.white.withOpacity(0.9))),
                        ],
                      ),
                      Icon(Icons.more_vert, color: item.color == Colors.white ? const Color(0xFF9E9E9E) : Colors.white, size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: item.color == Colors.white ? const Color(0xFF9E9E9E) : Colors.white.withOpacity(0.8)),
                      const SizedBox(width: 4),
                      Expanded(child: Text(item.location, style: TextStyle(fontSize: 12, color: item.color == Colors.white ? const Color(0xFF757575) : Colors.white.withOpacity(0.9)))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(radius: 10, backgroundColor: const Color(0xFF4675B8), child: Text(item.person[0], style: const TextStyle(fontSize: 10, color: Colors.white))),
                      const SizedBox(width: 6),
                      Text(item.person, style: TextStyle(fontSize: 12, color: item.color == Colors.white ? const Color(0xFF757575) : Colors.white.withOpacity(0.9))),
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

class ItineraryItem {
  final String startTime, endTime, title, subtitle, location, person;
  final Color color;
  ItineraryItem({required this.startTime, required this.endTime, required this.title, required this.subtitle, required this.location, required this.person, required this.color});
}