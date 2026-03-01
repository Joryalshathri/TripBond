import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/animations/animation_constants.dart';

class PlanItem {
  final String name;
  final String image;
  final String dateRange;
  final List<String> avatarInitials;

  const PlanItem({
    required this.name,
    required this.image,
    required this.dateRange,
    this.avatarInitials = const [],
  });
}

const List<PlanItem> _currentPlans = [
  PlanItem(
    name: 'Khobar',
    image: 'assets/images/khobar.png',
    dateRange: '9 - 13 Jan 2026',
    avatarInitials: ['K', 'L', 'H'],
  ),
];

const List<PlanItem> _futurePlans = [
  PlanItem(
    name: 'Jeddah',
    image: 'assets/images/jeddah.png',
    dateRange: '25 - 27 Feb 2026',
    avatarInitials: ['Z'],
  ),
  PlanItem(
    name: 'AlUla',
    image: 'assets/images/AlUla.png',
    dateRange: '5 - 20 Apr 2026',
  ),
];

const List<Color> _avatarColors = [
  Color(0xFF4675B8),
  Color(0xFFC4A44A),
  Color(0xFFE87C5D),
];

class PlansList extends StatefulWidget {
  const PlansList({super.key});

  @override
  State<PlansList> createState() => _PlansListState();
}

class _PlansListState extends State<PlansList> {
  bool _currentOpen = true;
  bool _futureOpen = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 90),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildSection('Current Plans', _currentOpen, () {
                          setState(() => _currentOpen = !_currentOpen);
                        }, _currentPlans),
                        const SizedBox(height: 16),
                        _buildSection('Future Plans', _futureOpen, () {
                          setState(() => _futureOpen = !_futureOpen);
                        }, _futurePlans),
                      ],
                    ),
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back,
                size: 24, color: Color(0xFF1E1E1E)),
          ),
          const Spacer(),
          const Text(
            "Sara's Plans",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 24),
        ],
      ),
    )
        .animate()
        .fadeIn(
          duration: Duration(milliseconds: AnimationConstants.normal),
          curve: AnimationConstants.cubicEaseOut,
        )
        .slideY(
          begin: -0.1,
          end: 0,
          duration: Duration(milliseconds: AnimationConstants.normal),
          curve: AnimationConstants.cubicEaseOut,
        );
  }

  Widget _buildSection(
      String title, bool isOpen, VoidCallback onToggle, List<PlanItem> plans) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 20,
                color: Colors.black,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (isOpen) ...plans.map((plan) => _buildPlanCard(plan)),
      ],
    );
  }

  Widget _buildPlanCard(PlanItem plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              plan.image,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 90,
                height: 90,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Color(0xFF666666)),
                    const SizedBox(width: 6),
                    Text(
                      plan.dateRange,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                if (plan.avatarInitials.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 24,
                    child: Stack(
                      children: List.generate(plan.avatarInitials.length, (i) {
                        return Positioned(
                          left: i * 18.0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _avatarColors[i % _avatarColors.length],
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              plan.avatarInitials[i],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ],
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
