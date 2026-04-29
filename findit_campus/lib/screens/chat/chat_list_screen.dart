import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../config/api_config.dart';
import '../../providers/chat_provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          if (chatProvider.isLoading && chatProvider.conversations.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (chatProvider.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 60, color: AppColors.textMuted.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your messages with item matches\nwill appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => chatProvider.fetchConversations(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: chatProvider.conversations.length,
              separatorBuilder: (_, __) => const Divider(
                color: AppColors.surfaceLight,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final conversation = chatProvider.conversations[index];
                final hasUnread = (conversation.unreadCount ?? 0) > 0;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    backgroundImage: (conversation.otherUserAvatar?.isNotEmpty ?? false)
                        ? NetworkImage(ApiConfig.imageUrl(conversation.otherUserAvatar!))
                        : null,
                    child: (conversation.otherUserAvatar?.isEmpty ?? true)
                        ? Text(
                            (conversation.otherUserName?.isNotEmpty ?? false)
                                ? conversation.otherUserName![0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherUserName ?? 'Unknown User',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(conversation.updatedAt),
                        style: TextStyle(
                          color: hasUnread ? AppColors.primary : AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    conversation.lastMessage?.message ?? 'No messages yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasUnread ? AppColors.textSecondary : AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: {
                        'matchId': conversation.matchId,
                        'otherUserName': conversation.otherUserName,
                        'otherUserId': conversation.otherUserId,
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return DateFormat('h:mm a').format(dateTime);
    return DateFormat('MMM d').format(dateTime);
  }
}
