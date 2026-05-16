import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'DestinationLandingPage.dart';
import 'profile.dart';
import 'user_profile_view.dart';
import 'group_suggested_itinerary.dart';
import 'plans_list.dart';
import 'notifications_view.dart';
import '../core/animations/animation_constants.dart';
import '../services/bonder_service.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/app_bottom_nav.dart';

class _BonderMeta {
  final int unreadCount;
  const _BonderMeta({this.unreadCount = 0});
}

class Bonders extends StatefulWidget {
  const Bonders({super.key});

  @override
  State<Bonders> createState() => _BondersState();
}

class _BondersState extends State<Bonders> {
  final BonderService _bonderService = BonderService();
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedList = 'friends';
  List<BonderItem> _friends = [];
  List<BonderItem> _allBonders = [];
  List<BonderItem> _filteredBonders = [];
  final Set<String> _pendingBondIds = {};
  Map<String, _BonderMeta> _bonderMeta = {};
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBonders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBonders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _bonderService.getFriends(),
        _bonderService.getAllBonders(limit: 200),
      ]);
      final previews = await _chatService.getConversationPreviews();
      final previewByPartnerId = {
        for (final p in previews) p.partnerId: p,
      };
      final metaByPartnerId = {
        for (final p in previews)
          p.partnerId: _BonderMeta(unreadCount: p.unreadCount),
      };

      final friends = results[0].map((b) {
        final p = previewByPartnerId[b.id];
        if (p == null) {
          return b;
        }
        return b.copyWith(
          avatarUrl: p.partnerAvatarUrl,
          lastMsg: (p.lastMessage != null && p.lastMessage!.isNotEmpty)
              ? p.lastMessage
              : b.lastMsg,
        );
      }).toList()
        ..sort((a, b) {
          final aHasPreview = previewByPartnerId.containsKey(a.id);
          final bHasPreview = previewByPartnerId.containsKey(b.id);
          if (aHasPreview == bHasPreview) {
            return 0;
          }
          return aHasPreview ? -1 : 1;
        });

      final allBonders = results[1]
          .map((b) =>
              b.copyWith(lastMsg: 'Tap to view profile or send a bond request'))
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      if (!mounted) return;

      setState(() {
        _friends = friends;
        _allBonders = allBonders;
        _bonderMeta = metaByPartnerId;
        _refreshFilteredBonders();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _filterList(String query) {
    setState(() {
      _refreshFilteredBonders(query: query);
    });
  }

  void _refreshFilteredBonders({String? query}) {
    final source = _selectedList == 'friends' ? _friends : _allBonders;
    final normalizedQuery =
        (query ?? _searchController.text).trim().toLowerCase();
    _filteredBonders = source
        .where((bonder) => bonder.name.toLowerCase().contains(normalizedQuery))
        .toList();
  }

  Set<String> get _friendIds => _friends.map((b) => b.id).toSet();

  String get _emptyMessage {
    if (_selectedList == 'friends') {
      return 'No friends yet. Open All Bonders to find people to bond with.';
    }
    return _searchController.text.trim().isEmpty
        ? 'No bonders found'
        : 'No matching bonders found';
  }

  void _updateLastMessage(String bonderId, String message) {
    final allIndex = _friends.indexWhere((b) => b.id == bonderId);
    final filteredIndex = _filteredBonders.indexWhere((b) => b.id == bonderId);

    if (allIndex == -1) return;

    final updated = _friends[allIndex].copyWith(lastMsg: message);

    setState(() {
      _friends.removeAt(allIndex);
      _friends.insert(0, updated);

      if (filteredIndex != -1) {
        _filteredBonders.removeAt(filteredIndex);
      }

      final query = _searchController.text.trim().toLowerCase();
      if (query.isEmpty || updated.name.toLowerCase().contains(query)) {
        _filteredBonders.insert(0, updated);
      }

      _bonderMeta[bonderId] = const _BonderMeta(unreadCount: 0);
    });
  }

  void _clearUnreadForBonder(String bonderId) {
    setState(() {
      _bonderMeta[bonderId] = const _BonderMeta(unreadCount: 0);
    });
  }

  Future<void> _sendBondRequest(BonderItem bonder) async {
    if (_pendingBondIds.contains(bonder.id) || _friendIds.contains(bonder.id)) {
      return;
    }

    setState(() => _pendingBondIds.add(bonder.id));
    try {
      final response = await _userService.sendBondRequest(bonder.id);
      if (!mounted) return;
      if (response['status']?.toString() == 'accepted') {
        await _loadBonders();
        if (!mounted) return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['status']?.toString() == 'accepted'
              ? 'You are now bonded with ${bonder.name}'
              : 'Bond request sent to ${bonder.name}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _pendingBondIds.remove(bonder.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Could not send request: ${e.toString().replaceAll('Exception: ', '')}'),
        ),
      );
    }
  }

  void _selectList(String list) {
    if (_selectedList == list) return;
    setState(() {
      _selectedList = list;
      _refreshFilteredBonders();
    });
  }

  // --- DELETE CONFIRMATION DIALOG ---
  Future<bool?> _confirmDelete(String name) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Conversation",
            style:
                TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: Text(
            "Are you sure you want to delete your conversation with $name? This action can't be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel",
                style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete",
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
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
              const Text("Sort Bonders",
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text("Sort A-Z"),
                onTap: () {
                  setState(() {
                    _filteredBonders.sort(
                      (a, b) =>
                          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
                    );
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text("Recent First"),
                onTap: () {
                  setState(() {
                    _filteredBonders = List.from(_allBonders);
                    _refreshFilteredBonders();
                  });
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
                                        hintStyle: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 18),
                                      ),
                                      style: const TextStyle(
                                          fontFamily: 'Poppins', fontSize: 18),
                                    )
                                  : const Text(
                                      'Bonders',
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 24),
                                    ),
                            ),
                            GestureDetector(
                              onTap: _showFilterSheet,
                              child: const Icon(Icons.tune,
                                  size: 24, color: Color(0xFF1E1E1E)),
                            ),
                            const SizedBox(width: 15),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const NotificationsView(),
                                  ),
                                );
                              },
                              child: const Icon(Icons.notifications_outlined,
                                  size: 24, color: Color(0xFF1E1E1E)),
                            ),
                            const SizedBox(width: 15),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isSearching = !_isSearching;
                                  if (!_isSearching) {
                                    _searchController.clear();
                                    _refreshFilteredBonders();
                                  }
                                });
                              },
                              child: Icon(
                                  _isSearching
                                      ? Icons.close
                                      : Icons.group_outlined,
                                  size: 24,
                                  color: const Color(0xFF1E1E1E)),
                            ),
                          ],
                        ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                        const SizedBox(height: 18),
                        _buildListTabs(),
                        const SizedBox(height: 24),
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.red.shade400,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: _loadBonders,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        if (!_isLoading &&
                            _error == null &&
                            _filteredBonders.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              _emptyMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontFamily: 'Poppins', color: Colors.grey),
                            ),
                          ),
                        ..._filteredBonders.asMap().entries.map((entry) {
                          final index = entry.key;
                          final b = entry.value;

                          // --- WRAPPED IN DISMISSIBLE FOR SWIPE-TO-DELETE ---
                          return Dismissible(
                            key: Key(b.id),
                            direction: _selectedList == 'friends'
                                ? DismissDirection.endToStart
                                : DismissDirection.none,
                            confirmDismiss: (direction) =>
                                _confirmDelete(b.name),
                            onDismissed: (direction) {
                              setState(() {
                                _friends.removeWhere(
                                    (element) => element.id == b.id);
                                _filteredBonders.removeAt(index);
                              });
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UserProfileView(
                                      userId: b.id,
                                      userName: b.name,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    _buildBonderAvatarButton(b),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            b.name,
                                            style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18),
                                          ),
                                          Text(
                                            b.lastMsg,
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                color: Colors.grey.shade600,
                                                fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_selectedList == 'all')
                                      _buildDiscoveryAction(b)
                                    else if ((_bonderMeta[b.id]?.unreadCount ??
                                            0) >
                                        0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4675B8),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          '${_bonderMeta[b.id]!.unreadCount}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              )
                                  .animate()
                                  .fadeIn(
                                    delay: Duration(
                                        milliseconds: 150 + (index * 80)),
                                    duration: Duration(
                                        milliseconds:
                                            AnimationConstants.normal),
                                    curve: AnimationConstants.cubicEaseOut,
                                  )
                                  .slideX(
                                    delay: Duration(
                                        milliseconds: 150 + (index * 80)),
                                    begin: 0.2,
                                    end: 0,
                                    duration: Duration(
                                        milliseconds:
                                            AnimationConstants.normal),
                                    curve: AnimationConstants.cubicEaseOut,
                                  ),
                            ),
                          );
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

  Widget _buildListTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _buildListTab(
            label: 'Friends',
            count: _friends.length,
            active: _selectedList == 'friends',
            onTap: () => _selectList('friends'),
          ),
          _buildListTab(
            label: 'All Bonders',
            count: _allBonders.length,
            active: _selectedList == 'all',
            onTap: () => _selectList('all'),
          ),
        ],
      ),
    );
  }

  Widget _buildListTab({
    required String label,
    required int count,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF4675B8) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            '$label ($count)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoveryAction(BonderItem bonder) {
    final isFriend = _friendIds.contains(bonder.id);
    final isPending = _pendingBondIds.contains(bonder.id);

    if (isFriend) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F3EE),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          'Friend',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
            fontSize: 12,
          ),
        ),
      );
    }

    return TextButton(
      onPressed: isPending ? null : () => _sendBondRequest(bonder),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF4675B8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      child: Text(
        isPending ? 'Pending' : 'Add',
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBonderAvatar(BonderItem bonder) {
    final avatarUrl = bonder.avatarUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(avatarUrl),
      );
    }

    return const CircleAvatar(
      radius: 28,
      backgroundColor: Color(0xFF4675B8),
      child: Icon(Icons.person, color: Colors.white),
    );
  }

  Widget _buildBonderAvatarButton(BonderItem bonder) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfileView(
              userId: bonder.id,
              userName: bonder.name,
            ),
          ),
        );
      },
      child: _buildBonderAvatar(bonder),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return AppBottomNav(
      currentTab: AppNavTab.bonders,
      planBuilder: (_) => const GroupSuggestedItinerary(),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String bonderId;
  final String name;
  final ValueChanged<String>? onMessageSent;
  const ChatPage({
    super.key,
    required this.bonderId,
    required this.name,
    this.onMessageSent,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  String? _currentUserId;
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = await _authService.getUserId();
      final messages = await _chatService.getMessagesWithUser(widget.bonderId);
      await _chatService.markMessagesAsRead(widget.bonderId);
      if (!mounted) return;

      setState(() {
        _currentUserId = userId;
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty && !_isSending) {
      setState(() {
        _isSending = true;
      });

      try {
        final sent = await _chatService.sendMessage(
          otherUserId: widget.bonderId,
          content: text,
        );
        if (!mounted) return;

        setState(() {
          _messages = [..._messages, sent];
          _messageController.clear();
          _isSending = false;
        });
        widget.onMessageSent?.call(text);
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _isSending = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
          ),
        );
      }
    }
  }

  Widget _buildMessageList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Poppins', color: Colors.red.shade400),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                  onPressed: _loadMessages, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet. Start the conversation.',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMine =
            _currentUserId != null && message.senderId == _currentUserId;

        return Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMine ? const Color(0xFF4675B8) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomRight: isMine ? Radius.zero : null,
                bottomLeft: isMine ? null : Radius.zero,
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    color: isMine ? Colors.white : Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.done,
                        size: 13,
                        color: message.readAt == null
                            ? Colors.white70
                            : Colors.lightBlueAccent,
                      ),
                      if (message.readAt != null)
                        const Icon(
                          Icons.done,
                          size: 13,
                          color: Colors.lightBlueAccent,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
        title: Text(widget.name,
            style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.black,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2))
            ]),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(25)),
                      child: TextField(
                        controller: _messageController,
                        enabled: !_isSending,
                        decoration: const InputDecoration(
                            hintText: "Type a message...",
                            border: InputBorder.none,
                            hintStyle: TextStyle(fontFamily: 'Poppins')),
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF4675B8),
                      child: _isSending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send,
                              color: Colors.white, size: 20),
                    ),
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
