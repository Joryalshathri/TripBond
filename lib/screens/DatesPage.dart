import 'package:flutter/material.dart';
import 'TripInfo.dart';

const List<String> _days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
const List<String> _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

class DatesPage extends StatefulWidget {
  const DatesPage({super.key});

  @override
  State<DatesPage> createState() => _DatesPageState();
}

class _DatesPageState extends State<DatesPage> {
  int _currentMonth = 8;
  int _currentYear = 2025;
  int? _startDate = 9;
  int? _endDate = 13;

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int _firstDayOfMonth(int year, int month) {
    return DateTime(year, month + 1, 1).weekday % 7;
  }

  void _handleDayTap(int day) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = day;
        _endDate = null;
      } else if (day < _startDate!) {
        _endDate = _startDate;
        _startDate = day;
      } else {
        _endDate = day;
      }
    });
  }

  bool _isInRange(int day) {
    if (_startDate == null || _endDate == null) return false;
    return day >= _startDate! && day <= _endDate!;
  }

  bool _isEdge(int day) {
    return day == _startDate || day == _endDate;
  }

  void _prevMonth() {
    setState(() {
      if (_currentMonth == 0) {
        _currentMonth = 11;
        _currentYear--;
      } else {
        _currentMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_currentMonth == 11) {
        _currentMonth = 0;
        _currentYear++;
      } else {
        _currentMonth++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _daysInMonth(_currentYear, _currentMonth);
    final firstDay = _firstDayOfMonth(_currentYear, _currentMonth);
    final prevMonthDays = _currentMonth == 0
        ? _daysInMonth(_currentYear - 1, 11)
        : _daysInMonth(_currentYear, _currentMonth - 1);
    final totalCells = ((firstDay + daysInMonth + 6) ~/ 7) * 7;

    final cells = <_CalendarCell>[];
    for (int i = 0; i < totalCells; i++) {
      if (i < firstDay) {
        cells.add(_CalendarCell(day: prevMonthDays - firstDay + i + 1, isCurrentMonth: false));
      } else if (i - firstDay < daysInMonth) {
        cells.add(_CalendarCell(day: i - firstDay + 1, isCurrentMonth: true));
      } else {
        cells.add(_CalendarCell(day: i - firstDay - daysInMonth + 1, isCurrentMonth: false));
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(27, 50, 27, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: const Icon(Icons.arrow_back, size: 24, color: Color(0xFF1E1E1E)),
                ),
              ),
            ),
          ),

          const Text(
            'Choose Your Dates',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 27),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildMonthYearHeader(),
                  const SizedBox(height: 20),
                  _buildDayHeaders(),
                  const SizedBox(height: 8),
                  _buildCalendarGrid(cells),
                ],
              ),
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.fromLTRB(30, 24, 30, 40),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TripInfo()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4675B8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                child: const Text('Choose Dates'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthYearHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _prevMonth,
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: const Icon(Icons.chevron_left, size: 20, color: Color(0xFF1E1E1E)),
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Text(
                    _months[_currentMonth],
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF1E1E1E)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Text(
                    '$_currentYear',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF1E1E1E)),
                ],
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: _nextMonth,
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF1E1E1E)),
          ),
        ),
      ],
    );
  }

  Widget _buildDayHeaders() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _days.map((day) {
        return SizedBox(
          width: 36,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(List<_CalendarCell> cells) {
    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      final rowCells = cells.sublist(i, i + 7);
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: rowCells.map((cell) {
              if (!cell.isCurrentMonth) {
                return SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: Text(
                      '${cell.day}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                );
              }

              final inRange = _isInRange(cell.day);
              final isEdge = _isEdge(cell.day);

              Color bgColor;
              Color textColor;
              FontWeight fontWeight;

              if (isEdge) {
                bgColor = const Color(0xFF2D2D2D);
                textColor = Colors.white;
                fontWeight = FontWeight.w600;
              } else if (inRange) {
                bgColor = const Color(0xFF4675B8);
                textColor = Colors.white;
                fontWeight = FontWeight.w500;
              } else {
                bgColor = Colors.transparent;
                textColor = Colors.black;
                fontWeight = FontWeight.w400;
              }

              return GestureDetector(
                onTap: () => _handleDayTap(cell.day),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${cell.day}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: fontWeight,
                      color: textColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _CalendarCell {
  final int day;
  final bool isCurrentMonth;

  const _CalendarCell({required this.day, required this.isCurrentMonth});
}
