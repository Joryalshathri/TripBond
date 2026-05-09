import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/trip_service.dart';
import 'trip_flow_screen.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  String _selectedTab = 'notifications'; // notifications, followers, requests
  final _notificationService = NotificationService();
  final _tripService = TripService();
  List<Map<String, dynamic>> _notifications = [];
  bool _loadingNotifications = true;
  String? _notificationsError;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loadingNotifications = true;
      _notificationsError = null;
    });
    try {
      final list = await _notificationService.list();
      if (!mounted) return;
      setState(() {
        _notifications = list;
        _loadingNotifications = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _notificationsError = e.toString();
        _loadingNotifications = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _notificationService.markAllRead();
      await _loadNotifications();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  Future<void> _onNotificationTap(Map<String, dynamic> n) async {
    if (n['read_at'] == null) {
      try {
        await _notificationService.markRead(n['id'].toString());
        if (!mounted) return;
        setState(() {
          n['read_at'] = DateTime.now().toIso8601String();
        });
      } catch (_) {}
    }
    final tripId = _tripIdFromPayload(n['payload']);
    if (tripId == null || !mounted) return;

    if (n['type']?.toString() == 'trip_invite') {
      try {
        await _tripService.acceptInvite(tripId);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not accept invite: $e')),
        );
        return;
      }
    }

    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TripFlowScreen(tripId: tripId),
    ));
  }

  String? _tripIdFromPayload(dynamic payload) {
    if (payload is Map) {
      return payload['trip_id']?.toString();
    }
    if (payload is String && payload.isNotEmpty) {
      try {
        final decoded = jsonDecode(payload);
        if (decoded is Map) return decoded['trip_id']?.toString();
      } catch (_) {}
    }
    return null;
  }

  String _formatTimestamp(String? raw) {
    if (raw == null) return '';
    DateTime? dt;
    try {
      dt = DateTime.parse(raw).toLocal();
    } catch (_) {
      return '';
    }
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  ({IconData icon, Color color}) _iconForType(String? type) {
    switch (type) {
      case 'trip_invite':
      case 'trip_invite_accepted':
        return (icon: Icons.mail_outline, color: Colors.blue);
      case 'voting_opened':
      case 'voting_closed':
        return (icon: Icons.how_to_vote, color: Colors.purple);
      case 'itinerary_generated':
        return (icon: Icons.auto_awesome, color: Colors.orange);
      case 'trip_liked':
        return (icon: Icons.favorite, color: Colors.red);
      case 'trip_join_request':
      case 'join_request_approved':
      case 'join_request_rejected':
        return (icon: Icons.group_add, color: Colors.teal);
      case 'suggestion_approved':
      case 'suggestion_rejected':
        return (icon: Icons.recommend_outlined, color: Colors.green);
      default:
        return (icon: Icons.notifications_outlined, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF4675B8),
        elevation: 0,
        actions: [
          if (_selectedTab == 'notifications')
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all read',
              onPressed: _notifications.isEmpty ? null : _markAllRead,
            ),
        ],
      ),
      body: Column(
        children: [
          // Tab Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TabButton(
                  label: 'Notifications',
                  isActive: _selectedTab == 'notifications',
                  onTap: () => setState(() => _selectedTab = 'notifications'),
                ),
                _TabButton(
                  label: 'Followers',
                  isActive: _selectedTab == 'followers',
                  onTap: () => setState(() => _selectedTab = 'followers'),
                ),
                _TabButton(
                  label: 'Requests',
                  isActive: _selectedTab == 'requests',
                  onTap: () => setState(() => _selectedTab = 'requests'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedTab == 'notifications') {
      return _buildNotifications();
    } else if (_selectedTab == 'followers') {
      return _buildFollowers();
    } else {
      return _buildRequests();
    }
  }

  Widget _buildNotifications() {
    if (_loadingNotifications) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_notificationsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load: $_notificationsError', textAlign: TextAlign.center),
              TextButton(onPressed: _loadNotifications, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (_notifications.isEmpty) {
      return const Center(child: Text('No notifications.'));
    }
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final n = _notifications[index];
          final iconInfo = _iconForType(n['type']?.toString());
          final isUnread = n['read_at'] == null;
          return GestureDetector(
            onTap: () => _onNotificationTap(n),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUnread ? const Color(0xFF4675B8).withOpacity(0.05) : null,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iconInfo.color.withOpacity(0.2),
                    ),
                    child: Icon(iconInfo.icon, color: iconInfo.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (n['title'] ?? 'Notification').toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if ((n['body'] ?? '').toString().isNotEmpty)
                          Text(
                            n['body'].toString(),
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        Text(
                          _formatTimestamp(n['created_at']?.toString()),
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  if (isUnread)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4675B8),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFollowers() {
    final followers = [
      {'name': 'Alex Johnson', 'mutualFollowers': 12},
      {'name': 'Emma Wilson', 'mutualFollowers': 8},
      {'name': 'David Brown', 'mutualFollowers': 5},
      {'name': 'Sarah Davis', 'mutualFollowers': 15},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: followers.length,
      itemBuilder: (context, index) {
        final follower = followers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF4675B8).withOpacity(0.2),
                child: Text(
                  follower['name'].toString()[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4675B8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      follower['name'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${follower['mutualFollowers']} mutual followers',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4675B8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Follow Back'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequests() {
    final requests = [
      {'name': 'Tom Anderson', 'mutualFriends': 3},
      {'name': 'Lisa Chen', 'mutualFriends': 1},
      {'name': 'Mark Taylor', 'mutualFriends': 5},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF4675B8).withOpacity(0.2),
                child: Text(
                  request['name'].toString()[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4675B8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['name'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${request['mutualFriends']} mutual friends',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4675B8),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4675B8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Decline'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
              color: isActive ? const Color(0xFF4675B8) : Colors.grey[600],
            ),
          ),
          if (isActive)
            Container(
              height: 3,
              width: 30,
              margin: const EdgeInsets.only(top: 8),
              color: const Color(0xFF4675B8),
            ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String timestamp;
  final Color color;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  timestamp,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
