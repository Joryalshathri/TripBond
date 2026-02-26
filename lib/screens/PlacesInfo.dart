import 'package:flutter/material.dart';

class PlaceInfo extends StatefulWidget {
  const PlaceInfo({super.key});

  @override
  State<PlaceInfo> createState() => PlaceInfoState();
}

class PlaceInfoState extends State<PlaceInfo> {
  String _activeTab = 'About';
  bool _expanded = false;

  static const _tabs = ['About', 'Review', 'Photo', 'Video'];
  static const _description =
      'a landmark cultural destination in Dhahran Saudi Arabia. It serves as a hub for knowledge creativity and innovation by bringing together art culture science and learning in one space. Ithra features museums exhibitions a world class library a cinema a theater and interactive learning areas designed for visitors of all ages.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHero(),
                _buildContent(),
              ],
            ),
          ),
          _buildBackButton(),
          _buildBookmarkButton(),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return SizedBox(
      height: 340,
      width: double.infinity,
      child: Image.asset(
        'assets/images/Ithra.jpg',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade300,
          child: const Center(child: Icon(Icons.image, size: 48, color: Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 44,
      left: 16,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4675B8).withOpacity(0.7),
          ),
          child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildBookmarkButton() {
    return Positioned(
      top: 44,
      right: 16,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF4675B8).withOpacity(0.7),
        ),
        child: const Icon(Icons.bookmark, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildContent() {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ithra',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Color(0xFF4675B8)),
                const SizedBox(width: 4),
                Text(
                  'Dhahran',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  '4.8',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFFC4A44A),
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(5, (i) => const Padding(
                  padding: EdgeInsets.only(right: 2),
                  child: Icon(Icons.star, size: 16, color: Color(0xFFC4A44A)),
                )),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: _tabs.map((tab) {
                final isActive = tab == _activeTab;
                return GestureDetector(
                  onTap: () => setState(() => _activeTab = tab),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Column(
                      children: [
                        Text(
                          tab,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: isActive ? Colors.black : Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 2,
                          width: 30,
                          color: isActive ? Colors.black : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            Divider(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 20),
            if (_activeTab == 'About') ...[
              const Text(
                'Description',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: _expanded ? _description : '${_description.substring(0, 220)}... ',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? 'Show Less' : 'Read More',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4675B8),
                  ),
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'No ${_activeTab.toLowerCase()}s yet',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4675B8),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            minimumSize: const Size(double.infinity, 52),
            elevation: 4,
          ),
          child: const Text(
            'Add to Plan',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
