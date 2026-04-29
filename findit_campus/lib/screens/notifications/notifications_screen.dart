import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/notification_provider.dart';
import '../../config/api_config.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _activeFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  Future<void> _onRefresh() async {
    await Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgNavy = Color(0xFF0A0A1A);
    const Color cardNavy = Color(0xFF12122A);
    const Color mutedGray = Color(0xFF8888AA);
    const Color accentPurple = Color(0xFF6C4AB6);

    return Scaffold(
      backgroundColor: bgNavy,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Alerts',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Stay updated on your lost items and campus activities.',
                          style: TextStyle(
                            color: mutedGray,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
                    },
                    child: const Text(
                      'Mark all as read',
                      style: TextStyle(color: accentPurple, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Pills
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildFilterPill('ALL'),
                    _buildFilterPill('MATCHES', value: 'MATCH'),
                    _buildFilterPill('CLAIMS', value: 'CLAIM'),
                    _buildFilterPill('SYSTEM'),
                  ],
                ),
              ),
            ),

            // Notification List
            Expanded(
              child: Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.notifications.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: accentPurple));
                  }

                  final list = _activeFilter == 'ALL' 
                    ? provider.notifications 
                    : provider.notifications.where((n) => n.type == _activeFilter).toList();

                  if (list.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: accentPurple,
                    backgroundColor: cardNavy,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationCard(list[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, {String? value}) {
    final filterValue = value ?? label;
    final isSelected = _activeFilter == filterValue;
    const Color accentPurple = Color(0xFF6C4AB6);
    const Color mutedGray = Color(0xFF8888AA);

    return GestureDetector(
      onTap: () => setState(() => _activeFilter = filterValue),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: mutedGray.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : mutedGray,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    const Color cardNavy = Color(0xFF12122A);
    const Color mutedGray = Color(0xFF8888AA);
    const Color accentPurple = Color(0xFF6C4AB6);

    bool isSystem = notification.type == 'SYSTEM';
    bool unread = !notification.read;

    return GestureDetector(
      onTap: () {
        if (unread) {
          Provider.of<NotificationProvider>(context, listen: false).markAsRead(notification.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isSystem ? accentPurple.withOpacity(0.05) : cardNavy,
          borderRadius: BorderRadius.circular(16),
          border: unread ? const Border(left: BorderSide(color: accentPurple, width: 4)) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  if (notification.type == 'MATCH')
                    _buildIconCircle(Icons.stars_rounded, Colors.amber)
                  else if (notification.type == 'CLAIM')
                    _buildIconCircle(Icons.check_circle_rounded, Colors.green)
                  else if (notification.type == 'HANDOVER')
                    _buildIconCircle(Icons.emoji_events_rounded, Colors.purple) // Purple trophy
                  else
                    _buildIconCircle(Icons.campaign_rounded, accentPurple), // Megaphone
                  
                  const SizedBox(width: 14),
                  // Title and Body
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              notification.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              _formatTime(notification.createdAt),
                              style: const TextStyle(
                                color: mutedGray,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.body,
                          style: const TextStyle(
                            color: mutedGray,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        
                        if (notification.type == 'MATCH') ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (notification.relatedId != null) {
                                    Navigator.pushNamed(context, '/item-detail', arguments: notification.relatedId);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentPurple,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                  minimumSize: const Size(0, 32),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('View Details', style: TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: mutedGray),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                  minimumSize: const Size(0, 32),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Not Mine', style: TextStyle(color: mutedGray, fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconCircle(IconData icon, Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(date);
  }

  Widget _buildEmptyState() {
    const Color mutedGray = Color(0xFF8888AA);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.notifications_none_rounded, size: 80, color: Color(0xFF1E1E3A)),
          SizedBox(height: 20),
          Text(
            'No alerts yet',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            'We will notify you when something happens',
            style: TextStyle(color: mutedGray, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
