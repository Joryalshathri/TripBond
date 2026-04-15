import 'package:flutter/material.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  String _selectedTab = 'notifications'; // notifications, followers, requests

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF4675B8),
        elevation: 0,
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _NotificationItem(
          icon: Icons.favorite,
          title: 'Someone liked your plan',
          subtitle: 'John Doe liked your "Paris Trip"',
          timestamp: '2 hours ago',
          color: Colors.red,
        ),
        _NotificationItem(
          icon: Icons.people_outline,
          title: 'New follower',
          subtitle: 'Sarah followed you',
          timestamp: '5 hours ago',
          color: Colors.blue,
        ),
        _NotificationItem(
          icon: Icons.comment_outlined,
          title: 'New message',
          subtitle: 'You have 3 unread messages',
          timestamp: '1 day ago',
          color: Colors.orange,
        ),
        _NotificationItem(
          icon: Icons.share_outlined,
          title: 'Someone shared with you',
          subtitle: 'Mike shared "Italy Adventure" plan',
          timestamp: '2 days ago',
          color: Colors.purple,
        ),
      ],
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
