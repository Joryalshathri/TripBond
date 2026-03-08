import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'DestinationLandingPage.dart';
import 'profile.dart';
import 'close_spots.dart';
import 'group_suggested_itinerary.dart';

// Global "Bonders" list
List<Map<String, String>> globalBonders = [
  {'name': 'Leen', 'image': 'assets/images/people/persone4.png', 'lastMsg': 'Hey! How are you?'},
  {'name': 'Khalid', 'image': 'assets/images/people/persone5.png', 'lastMsg': 'The trip was amazing!'},
  {'name': 'Huda', 'image': 'assets/images/people/persone6.png', 'lastMsg': 'Check this out.'},
  {'name': 'Ziyad', 'image': 'assets/images/people/persone7.png', 'lastMsg': 'Let\'s go!'},
  {'name': 'Friends', 'image': 'assets/images/people/friends.png', 'lastMsg': 'Group chat active'},
];

class Bonders extends StatefulWidget {
  const Bonders({super.key});

  @override
  State<Bonders> createState() => _BondersState();
}

class _BondersState extends State<Bonders> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredBonders = [];

  @override
  void initState() {
    super.initState();
    _filteredBonders = globalBonders;
  }

  void _filterList(String query) {
    setState(() {
      _filteredBonders = globalBonders
          .where((bonder) =>
              bonder['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Filter Conversations", 
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text("Sort A-Z"),
                onTap: () {
                  setState(() => _filteredBonders.sort((a, b) => a['name']!.compareTo(b['name']!)));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text("Recent First"),
                onTap: () {
                  // Re-sync with global list which is already ordered by most recent activity
                  setState(() => _filteredBonders = List.from(globalBonders));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 90),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 100),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _isSearching
                                  ? TextField(
                                      controller: _searchController,
                                      autofocus: true,
                                      onChanged: _filterList,
                                      decoration: const InputDecoration(
                                        hintText: 'Search bonders...',
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 18),
                                      ),
                                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 18),
                                    )
                                  : const Text(
                                      'Bonders',
                                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 24),
                                    ),
                            ),
                            GestureDetector(
                              onTap: _showFilterSheet,
                              child: const Icon(Icons.tune, size: 24, color: Color(0xFF1E1E1E)),
                            ),
                            const SizedBox(width: 15),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isSearching = !_isSearching;
                                  if (!_isSearching) {
                                    _searchController.clear();
                                    _filteredBonders = globalBonders;
                                  }
                                });
                              },
                              child: Icon(
                                _isSearching ? Icons.close : Icons.group_outlined, 
                                size: 24, 
                                color: const Color(0xFF1E1E1E)
                              ),
                            ),
                          ],
                        ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                        
                        const SizedBox(height: 24),

                        ..._filteredBonders.asMap().entries.map((entry) {
                          final index = entry.key;
                          final b = entry.value;
                          return GestureDetector(
                            onTap: () async {
                              // MODIFIED 
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatPage(
                                    name: b['name']!, 
                                    imagePath: b['image']!
                                  ),
                                ),
                              );
                              // the following code runs when the user returns back from the chat page
                              setState(() {
                                _filteredBonders = List.from(globalBonders);
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundImage: AssetImage(b['image']!),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          b['name']!,
                                          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 18),
                                        ),
                                        Text(
                                          b['lastMsg'] ?? 'No messages yet',
                                          style: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade600, fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.1, end: 0);
                        }),
                      ],
                    ),
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

  Widget _buildBottomNav(BuildContext context) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
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
            _navIcon(Icons.search, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DestinationLandingPage()))),
            _navIcon(Icons.location_on_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CloseSpots()))),
            _navIcon(Icons.airplanemode_active, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupSuggestedItinerary()))),
            _navIcon(Icons.group_outlined, active: true),
            _navIcon(Icons.person_outline, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Profile()))),
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
            Container(width: 20, height: 2, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(1))),
          ],
        ],
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String name;
  final String imagePath;
  const ChatPage({super.key, required this.name, required this.imagePath});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];

  void _sendMessage() {
    String text = _messageController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add(text);
        
        // Find the index of the person in the global list
        int existingIndex = globalBonders.indexWhere((b) => b['name'] == widget.name);
        
        if (existingIndex != -1) {
          // Remove them from current position
          Map<String, String> updatedBonder = globalBonders.removeAt(existingIndex);
          // Update the last message
          updatedBonder['lastMsg'] = text;
          // Re-insert at the top (index 0)
          globalBonders.insert(0, updatedBonder);
        }
        
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0, backgroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(widget.name, style: const TextStyle(fontFamily: 'Poppins', color: Colors.black, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4675B8), 
                      borderRadius: BorderRadius.circular(20).copyWith(bottomRight: Radius.zero)
                    ),
                    child: Text(_messages[index], style: const TextStyle(color: Colors.white, fontFamily: 'Poppins')),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -2))]),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(25)),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(hintText: "Type a message...", border: InputBorder.none, hintStyle: TextStyle(fontFamily: 'Poppins')),
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: const CircleAvatar(backgroundColor: Color(0xFF4675B8), child: Icon(Icons.send, color: Colors.white, size: 20)),
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