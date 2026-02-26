import 'package:flutter/material.dart';

class CalendarEvent {
  final String startTime;
  final String endTime;
  final String name;
  final String type;
  final String location;
  final String person;
  final bool highlight;

  const CalendarEvent({
    required this.startTime,
    required this.endTime,
    required this.name,
    required this.type,
    required this.location,
    required this.person,
    this.highlight = false,
  });
}

const List<CalendarEvent> _events = [
  CalendarEvent(
    startTime: '11:35',
    endTime: '13:05',
    name: 'Ithra',
    type: 'Culture Festival',
    location: 'Gharb Al Dhahran, Dhahran',
    person: 'Khalid Mohammad',
    highlight: true,
  ),
  CalendarEvent(
    startTime: '13:15',
    endTime: '14:45',
    name: 'LWF',
    type: 'Burger Joint',
    location: 'Gharb Al Dhahran, Dhahran',
    person: 'Leen Mohammad',
  ),
  CalendarEvent(
    startTime: '15:10',
    endTime: '16:40',
    name: 'Rakah Beach',
    type: 'Beach',
    location: 'Rakah',
    person: 'Huda Mohammad',
  ),
];

const List<String> _weekDayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
const List<int> _weekDates = [21, 22, 23, 24, 25, 26, 27];

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  int _selectedDay = 24;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              _buildDateHeader(),
              _buildWeekStrip(),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 16, bottom: 90),
                  child: Column(
                    children: _events.map((e) => _buildEventCard(e)).toList(),
                  ),
                ),
              ),
            ],
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(27, 50, 27, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            '24',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 48,
              color: Color(0xFF4675B8),
              height: 1,
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wed',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFFC4A44A),
                  ),
                ),
                Text(
                  'Jan 2026',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF4675B8)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Today',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Color(0xFF4675B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStrip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final day = _weekDates[i];
          final isSelected = day == _selectedDay;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = day),
            child: Column(
              children: [
                Text(
                  _weekDayLabels[i],
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFF4675B8) : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 45,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 8),
                Text(
                  event.startTime,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                Text(
                  event.endTime,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: event.highlight ? const Color(0xFFF5E6B8) : Colors.white,
                border: Border.all(
                  color: event.highlight ? const Color(0xFFE8D49A) : Colors.grey.shade200,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const Icon(Icons.more_vert, size: 16, color: Color(0xFF666666)),
                    ],
                  ),
                  Text(
                    event.type,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: Color(0xFF4675B8)),
                      const SizedBox(width: 6),
                      Text(
                        event.location,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: event.highlight ? const Color(0xFF4675B8) : const Color(0xFFC4A44A),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          event.person[0],
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        event.person,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey.shade500,
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
