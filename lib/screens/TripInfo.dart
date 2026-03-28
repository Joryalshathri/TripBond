import 'package:flutter/material.dart';
import 'AI_Plan.dart';
import 'DestinationLandingPage.dart';
import '../services/places_service.dart';
import '../services/trip_service.dart';

const List<String> _tripTypes = [
  'Solo Trip',
  'Friends Trip',
  'Family Trip (with kids)',
  'Family Trip (without kids)',
];

const List<String> _bonders = [
  'Leen',
  'Khalid',
  'Huda',
  'Ziyad',
  'Friends',
];

class TripInfo extends StatefulWidget {
  final String selectedDates;
  final DateTime startDate;
  final DateTime endDate;

  const TripInfo({
    super.key,
    required this.selectedDates,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<TripInfo> createState() => _TripinfoState();
}

class _TripinfoState extends State<TripInfo> {
  String? _selectedTripType;
  String? _selectedBonder;
  String? _selectedPlace;
  bool _isSubmitting = false;
  bool _isLoadingPlaces = false;
  final List<String> _preferredPlaces = [];

  final _tripService = TripService();
  final _placesService = PlacesService();

  @override
  void initState() {
    super.initState();
    _loadPreferredPlaces();
  }

  Future<void> _loadPreferredPlaces() async {
    if (selectedCityForTrip.isEmpty) return;
    setState(() => _isLoadingPlaces = true);
    try {
      final places = await _placesService.searchPlaces(
        query: 'top places in $selectedCityForTrip',
      );
      final names = places
          .map((p) => (p['name'] ?? '').toString().trim())
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList();
      if (!mounted) return;
      setState(() {
        _preferredPlaces
          ..clear()
          ..addAll(names.take(12));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _preferredPlaces
          ..clear()
          ..addAll(<String>[]);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingPlaces = false);
      }
    }
  }

  Future<void> _createTripAndGeneratePlan() async {
    if (_selectedTripType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a trip type')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final tripData = {
        'title': _selectedPlace != null && _selectedPlace!.isNotEmpty
            ? '${_selectedPlace!} Trip'
            : '$selectedCityForTrip Trip',
        'destination': selectedCityForTrip,
        'location': selectedCityForTrip,
        'start_date': widget.startDate.toIso8601String().split('T').first,
        'end_date': widget.endDate.toIso8601String().split('T').first,
        'trip_type': _selectedTripType,
        'description': 'Planned with TripBond',
        'is_public': true,
      };

      final createdTrip = await _tripService.createTrip(tripData);
      final tripId = (createdTrip['id'] ?? '').toString();

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AI_Plan(
            tripId: tripId.isEmpty ? null : tripId,
            tripTitle: (createdTrip['title'] ?? '').toString(),
            destination:
                (createdTrip['destination'] ?? selectedCityForTrip).toString(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create trip: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 27),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Plan your Trip',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$selectedCityForTrip, Saudi Arabia", // Dynamic Global City
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildDepartureField(),
                    const SizedBox(height: 24),
                    _buildDropdownField(
                      label: 'Preferred Places',
                      value: _selectedPlace,
                      options: _preferredPlaces,
                      onChanged: (v) => setState(() => _selectedPlace = v),
                    ),
                    const SizedBox(height: 24),
                    _buildDropdownField(
                      label: 'Trip Type',
                      value: _selectedTripType,
                      options: _tripTypes,
                      onChanged: (v) => setState(() => _selectedTripType = v),
                    ),
                    const SizedBox(height: 24),
                    _buildDropdownField(
                      label: 'Bonders',
                      value: _selectedBonder,
                      options: _bonders,
                      onChanged: (v) => setState(() => _selectedBonder = v),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 24, 30, 40),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _createTripAndGeneratePlan,
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
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Generate Plan'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 12),
      child: Stack(
        // Using Stack to keep the back button on the left while centering the middle content
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: const Icon(Icons.arrow_back,
                    size: 24, color: Color(0xFF1E1E1E)),
              ),
            ),
          ),
          // Centered Row for Location and Dates
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 14, color: Colors.grey.shade800),
                    const SizedBox(width: 4),
                    Text(
                      selectedCityForTrip, // Global dynamic city
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.selectedDates, // Displaying dates
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down,
                        size: 16, color: Colors.grey.shade800),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDepartureField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Departure point',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(
                selectedCityForTrip,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(25),
          ),
          child: _isLoadingPlaces && label == 'Preferred Places'
              ? Row(
                  children: [
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                )
              : options.isEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(),
                        Icon(Icons.keyboard_arrow_down,
                            size: 20, color: Colors.grey.shade500),
                      ],
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: value,
                        isExpanded: true,
                        hint: const SizedBox(),
                        icon: Icon(Icons.keyboard_arrow_down,
                            size: 20, color: Colors.grey.shade500),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        items: options.map((opt) {
                          return DropdownMenuItem(
                            value: opt,
                            child: Text(opt),
                          );
                        }).toList(),
                        onChanged: onChanged,
                      ),
                    ),
        ),
      ],
    );
  }
}
