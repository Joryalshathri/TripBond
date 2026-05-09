import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Bonder.dart';
import 'profile.dart';
import 'DestinationLandingPage.dart';
import 'AI_Plan.dart';
import 'plans_list.dart';
import 'BondersSuggestions.dart';
import '../services/trip_service.dart';
import '../services/vote_service.dart';
import '../providers/user_provider.dart';
import 'voting_screen.dart';
import 'trip_join_requests_screen.dart';

DateTime _norm(DateTime d) => DateTime(d.year, d.month, d.day);

ItineraryItem _activityToItem(
    Map<String, dynamic> activity, String fallbackLocation) {
  return ItineraryItem(
    id: activity['id']?.toString(),
    startTime: (activity['start_time'] ?? '09:00').toString(),
    endTime: (activity['end_time'] ?? '10:30').toString(),
    title: (activity['name'] ?? activity['title'] ?? 'Activity').toString(),
    subtitle: (activity['category'] ?? activity['notes'] ?? '').toString(),
    location: (activity['address'] ?? activity['location'] ?? fallbackLocation)
        .toString(),
    person: 'AI',
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
  final _voteService = VoteService();

  DateTime? _selectedDay;
  List<DateTime> _tripDays = [];
  Map<DateTime, List<Map<String, dynamic>>> _calendarItinerary = {};

  bool isEditMode = false;
  bool hasNotification = false;
  bool _loading = true;
  bool _generating = false;
  bool _openingVoting = false;
  String? _phase;
  bool _isCreator = false;
  String? _error;
  Map<String, dynamic>? _trip;

  List<Map<String, dynamic>> suggestions = [];

  List<Map<String, dynamic>> _activitiesForDay(DateTime day) {
    return _calendarItinerary[_norm(day)] ?? const [];
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (widget.tripId == null || widget.tripId!.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Open this from a trip first.';
      });
      return;
    }
    try {
      final trip = await _tripService.getTripDetails(widget.tripId!);
      _trip = trip;
      _phase = trip['phase']?.toString();
      final currentUserId = Provider.of<UserProvider>(context, listen: false)
          .currentProfile?['id'];
      _isCreator = trip['created_by'] == currentUserId;
      await _loadTripItinerary(trip);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  DateTime _tripStartDate() {
    final raw = _trip?['start_date'];
    if (raw is String && raw.isNotEmpty) {
      try {
        return DateTime.parse(raw).toLocal();
      } catch (_) {}
    }
    return DateTime.now();
  }

  Future<void> _loadTripItinerary(Map<String, dynamic> trip) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final itineraryData =
          await _tripService.getLatestItinerary(widget.tripId!);
      final days = itineraryData['days'];
      final mappedDays = <DateTime>[];
      final mappedCalendar = <DateTime, List<Map<String, dynamic>>>{};
      final start = _tripStartDate();

      if (days is List) {
        for (final dayData in days) {
          if (dayData is! Map<String, dynamic>) continue;
          final dayNumber = dayData['day'] is int
              ? dayData['day'] as int
              : int.tryParse(dayData['day']?.toString() ?? '') ?? 1;
          final dayDate = start.add(Duration(days: dayNumber - 1));

          final activities = dayData['activities'];
          final acts = <Map<String, dynamic>>[];
          if (activities is List) {
            for (final item in activities) {
              if (item is Map) {
                acts.add(Map<String, dynamic>.from(item));
              }
            }
          }
          mappedDays.add(dayDate);
          mappedCalendar[_norm(dayDate)] = acts;
        }
      }

      List<Map<String, dynamic>> placeSuggestions = const [];
      try {
        placeSuggestions =
            await _tripService.getPlaceSuggestions(widget.tripId!);
      } catch (_) {}
      final currentUserId = Provider.of<UserProvider>(context, listen: false)
          .currentProfile?['id'];
      final mappedPlaceSuggestions =
          _mapPlaceSuggestions(placeSuggestions, currentUserId);

      if (!mounted) return;
      setState(() {
        _tripDays = mappedDays;
        _calendarItinerary = mappedCalendar;
        _selectedDay = mappedDays.isNotEmpty ? mappedDays.first : null;
        suggestions = mappedPlaceSuggestions;
        hasNotification = mappedPlaceSuggestions.isNotEmpty;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _generatePlan() async {
    if (widget.tripId == null) return;
    setState(() => _generating = true);
    try {
      await _tripService.generateItinerary(widget.tripId!, {});
      _phase = 'planned';
      if (_trip != null) {
        await _loadTripItinerary(_trip!);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan generated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate: $e')),
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _openVoting() async {
    if (widget.tripId == null || widget.tripId!.isEmpty) return;
    setState(() => _openingVoting = true);
    try {
      final places = await _tripService.listTripPlaces(widget.tripId!);
      if (places.isEmpty) {
        if (!mounted) return;
        setState(() => _openingVoting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Add at least one place before starting voting.')),
        );
        return;
      }
      await _voteService.openVoting(widget.tripId!);
      if (!mounted) return;
      setState(() {
        _phase = 'voting';
        _openingVoting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Voting is open. Members can now rate places.')),
      );
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => VotingScreen(
          tripId: widget.tripId!,
          tripTitle: widget.tripTitle ?? 'Trip',
          isCreator: _isCreator,
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _openingVoting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open voting: $e')),
      );
    }
  }

  Future<void> _deleteActivity(Map<String, dynamic> activity) async {
    final id = activity['id']?.toString();
    if (id == null || id.isEmpty || widget.tripId == null) return;
    try {
      await _tripService.deleteItineraryItem(widget.tripId!, id);
      if (_trip != null) await _loadTripItinerary(_trip!);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
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
      final isCurrentUserSuggestion =
          suggestion['suggested_by'] == currentUserId;
      return {
        'name': (suggestion['name'] ?? 'Place').toString(),
        'type': (suggestion['place_types'] is List &&
                (suggestion['place_types'] as List).isNotEmpty)
            ? ((suggestion['place_types'] as List).first).toString()
            : 'Place',
        'location':
            (suggestion['address'] ?? widget.destination ?? 'Trip').toString(),
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

  void _showActivityDetail(
      BuildContext context, Map<String, dynamic> activity) {
    final name =
        (activity['name'] ?? activity['title'] ?? 'Activity').toString();
    final location = (activity['address'] ??
            activity['location'] ??
            widget.destination ??
            '')
        .toString();
    final start = (activity['start_time'] ?? '').toString();
    final end = (activity['end_time'] ?? '').toString();
    final score = activity['score'];
    final notes = activity['notes']?.toString();
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
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (location.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                      child:
                          Text(location, style: const TextStyle(fontSize: 14))),
                ],
              ),
            const SizedBox(height: 8),
            if (score is num)
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Color(0xFFC8A858)),
                  const SizedBox(width: 6),
                  Text('${score.toStringAsFixed(1)} score',
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            const SizedBox(height: 8),
            if (start.isNotEmpty)
              Text('$start - $end',
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(notes, style: const TextStyle(fontSize: 13)),
            ],
            const SizedBox(height: 24),
            if (isEditMode && activity['id'] != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteActivity(activity);
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove from plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activities = _selectedDay != null
        ? _activitiesForDay(_selectedDay!)
        : const <Map<String, dynamic>>[];
    final selectedDay = _selectedDay ?? DateTime.now();

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
                if (_loading)
                  const Expanded(
                      child: Center(child: CircularProgressIndicator()))
                else if (_error != null)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(_error!, textAlign: TextAlign.center),
                      ),
                    ),
                  )
                else if (_tripDays.isEmpty)
                  Expanded(child: _buildEmptyPlanView(context))
                else
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
                                    '${selectedDay.day}',
                                    style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(_weekdayLabel(selectedDay),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF9E9E9E))),
                                  Text(_dayLabel(selectedDay),
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
                                final bool isSelected = _selectedDay != null &&
                                    _norm(_selectedDay!) == _norm(day);
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                            child: activities.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No activities for this day.',
                                      style: TextStyle(
                                          color: Color(0xFF9E9E9E),
                                          fontSize: 14),
                                    ),
                                  )
                                : ListView.builder(
                                    physics: const ClampingScrollPhysics(),
                                    itemCount: activities.length,
                                    padding: const EdgeInsets.only(bottom: 20),
                                    itemBuilder: (context, index) {
                                      final activity = activities[index];
                                      final item = _activityToItem(activity,
                                          widget.destination ?? 'Trip');
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16),
                                        child: GestureDetector(
                                          onTap: () => _showActivityDetail(
                                              context, activity),
                                          child: _CalendarItineraryCard(
                                            item: item,
                                            showDelete: isEditMode &&
                                                activity['id'] != null,
                                            onDelete: () =>
                                                _deleteActivity(activity),
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
              MaterialPageRoute(
                  builder: (_) => const PlansList(source: 'generatedPlan')),
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
                        final placeSuggestions = await _tripService
                            .getPlaceSuggestions(widget.tripId!);
                        final currentUserId =
                            Provider.of<UserProvider>(context, listen: false)
                                .currentProfile?['id'];
                        final mappedPlaceSuggestions = _mapPlaceSuggestions(
                            placeSuggestions, currentUserId);

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
              if (_isCreator && widget.tripId != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.group_add_outlined, size: 22),
                  tooltip: 'Join requests',
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => TripJoinRequestsScreen(
                      tripId: widget.tripId!,
                      tripTitle: widget.tripTitle ?? 'Trip',
                    ),
                  )),
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

  Widget _buildEmptyPlanView(BuildContext context) {
    final canGenerate = _isCreator && _phase == 'finalized';
    final votingOpen = _phase == 'voting';
    final canOpenVoting = _isCreator && _phase == 'planning';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.airplanemode_active, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No plan generated yet',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _phase == 'planning'
                  ? 'Open voting once members have added their picks.'
                  : votingOpen
                      ? 'Voting is open. Wait for the creator to close it.'
                      : canGenerate
                          ? 'Voting is closed. Generate the AI plan from voted places.'
                          : 'Waiting for the creator to generate the plan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            if (widget.tripId != null) ...[
              if (canOpenVoting)
                ElevatedButton.icon(
                  onPressed: _openingVoting ? null : _openVoting,
                  icon: _openingVoting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.how_to_vote),
                  label: const Text('Start voting'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4675B8),
                    foregroundColor: Colors.white,
                  ),
                ),
              if (votingOpen)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => VotingScreen(
                        tripId: widget.tripId!,
                        tripTitle: widget.tripTitle ?? 'Trip',
                        isCreator: _isCreator,
                      ),
                    ));
                  },
                  icon: const Icon(Icons.how_to_vote),
                  label: const Text('Open voting'),
                ),
              if (canGenerate)
                ElevatedButton.icon(
                  onPressed: _generating ? null : _generatePlan,
                  icon: _generating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_awesome),
                  label: const Text('Generate plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4675B8),
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ],
        ),
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
            SizedBox(
                width: 50,
                child: _navIcon(Icons.home,
                    onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PlansList(source: 'home'))))),
            SizedBox(
                width: 50,
                child: _navIcon(Icons.search,
                    onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DestinationLandingPage())))),
            SizedBox(
                width: 50,
                child: _navIcon(Icons.airplanemode_active, active: true)),
            SizedBox(
                width: 50,
                child: _navIcon(Icons.group_outlined,
                    onTap: () => Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const Bonders())))),
            SizedBox(
                width: 50,
                child: _navIcon(Icons.person_outline,
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
            Container(width: 20, height: 2, color: Colors.white)
          ]
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
  final String? id;
  final String startTime, endTime, title, subtitle, location, person;
  final Color color;

  ItineraryItem({
    this.id,
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.person,
    required this.color,
  });
}
