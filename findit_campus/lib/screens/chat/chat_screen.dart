import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  final String matchId;
  final String otherUserName;
  final String otherUserId;

  const ChatScreen({
    super.key,
    required this.matchId,
    required this.otherUserName,
    required this.otherUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  static const Color primaryPurple = Color(0xFF6C4AB6);
  static const Color bgColor = Color(0xFFF4EFFB);
  static const Color textDark = Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.fetchMessages(widget.matchId);
      chatProvider.joinChatRoom(widget.matchId);
      chatProvider.markAsRead(widget.matchId);
    });
  }

  @override
  void dispose() {
    Provider.of<ChatProvider>(context, listen: false)
        .leaveChatRoom(widget.matchId);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    Provider.of<ChatProvider>(context, listen: false).sendMessage(
      matchId: widget.matchId,
      receiverId: widget.otherUserId,
      message: message,
    );

    _messageController.clear();
    _scrollToBottom();

    if (_isTyping) {
      _isTyping = false;
      Provider.of<ChatProvider>(context, listen: false)
          .sendStopTyping(widget.matchId);
    }
  }

  void _onTextChanged(String text) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      chatProvider.sendTyping(widget.matchId);
    } else if (text.isEmpty && _isTyping) {
      _isTyping = false;
      chatProvider.sendStopTyping(widget.matchId);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        Provider.of<AuthProvider>(context, listen: false).user?.id;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ═══════════════════════════════════
            //  HEADER
            // ═══════════════════════════════════
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 20, 14),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  bottom: BorderSide(
                    color: primaryPurple.withAlpha(15),
                  ),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: textDark, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Campus Recover',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: primaryPurple,
                          ),
                        ),
                        Consumer<ChatProvider>(
                          builder: (context, chatProvider, _) {
                            return Text(
                              chatProvider.isOtherUserTyping
                                  ? 'typing...'
                                  : 'ACTIVE DISCUSSION',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: chatProvider.isOtherUserTyping
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFAAAAAA),
                                letterSpacing: 1.0,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF4CAF50), width: 2),
                    ),
                    child: ClipOval(
                      child: Container(
                        color: const Color(0xFFE8D5B7),
                        child: const Center(
                          child: Icon(Icons.person,
                              color: Color(0xFF8B6914), size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════
            //  ITEM REFERENCE CARD
            // ═══════════════════════════════════
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Item thumbnail
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE7F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.inventory_2_outlined,
                          color: primaryPurple, size: 26),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: primaryPurple,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'LOST ITEM',
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Ref: #CR-${widget.matchId.substring(0, 4).toUpperCase()}',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: const Color(0xFFAAAAAA),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Discussion with ${widget.otherUserName}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 12, color: primaryPurple),
                            const SizedBox(width: 2),
                            Text(
                              'Campus Location',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: Color(0xFFCCCCCC), size: 22),
                ],
              ),
            ),

            // ═══════════════════════════════════
            //  MESSAGES
            // ═══════════════════════════════════
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  if (chatProvider.isLoading &&
                      chatProvider.messages.isEmpty) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: primaryPurple),
                    );
                  }

                  if (chatProvider.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.waving_hand_rounded,
                              size: 48,
                              color: primaryPurple.withAlpha(60)),
                          const SizedBox(height: 12),
                          Text(
                            'Say hello! 👋',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF999999),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _scrollToBottom());

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final msg = chatProvider.messages[index];
                      final isMe = msg.senderId == currentUserId;
                      final showDate = index == 0 ||
                          !_isSameDay(
                            chatProvider.messages[index - 1].createdAt,
                            msg.createdAt,
                          );

                      return Column(
                        children: [
                          // Date separator
                          if (showDate)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDE7F6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _formatDate(msg.createdAt),
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF999999),
                                  ),
                                ),
                              ),
                            ),

                          // Message bubble
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: isMe
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Other user avatar
                                if (!isMe) ...[
                                  Container(
                                    width: 28,
                                    height: 28,
                                    margin:
                                        const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          primaryPurple.withAlpha(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        widget.otherUserName.isNotEmpty
                                            ? widget.otherUserName[0]
                                                .toUpperCase()
                                            : '?',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: primaryPurple,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                // Bubble
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: isMe
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth:
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.72,
                                        ),
                                        padding: const EdgeInsets
                                            .symmetric(
                                            horizontal: 16,
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isMe
                                              ? primaryPurple
                                              : Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft:
                                                const Radius.circular(18),
                                            topRight:
                                                const Radius.circular(18),
                                            bottomLeft: Radius.circular(
                                                isMe ? 18 : 4),
                                            bottomRight: Radius.circular(
                                                isMe ? 4 : 18),
                                          ),
                                          boxShadow: isMe
                                              ? null
                                              : [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withAlpha(6),
                                                    blurRadius: 8,
                                                    offset:
                                                        const Offset(
                                                            0, 2),
                                                  ),
                                                ],
                                        ),
                                        child: Text(
                                          msg.message,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: isMe
                                                ? Colors.white
                                                : textDark,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            DateFormat('HH:mm')
                                                .format(msg.createdAt),
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: const Color(0xFFBBBBBB),
                                            ),
                                          ),
                                          if (isMe) ...[
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.done_all_rounded,
                                              size: 14,
                                              color: msg.read
                                                  ? Colors.white.withOpacity(0.8)
                                                  : Colors.white.withOpacity(0.4),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // ═══════════════════════════════════
            //  TYPING INDICATOR
            // ═══════════════════════════════════
            Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                if (!chatProvider.isOtherUserTyping) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding:
                      const EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryPurple.withAlpha(20),
                        ),
                        child: Center(
                          child: Text(
                            widget.otherUserName.isNotEmpty
                                ? widget.otherUserName[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: primaryPurple,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (i) {
                            return Container(
                              width: 8,
                              height: 8,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryPurple.withAlpha(
                                    100 + (i * 50)),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // ═══════════════════════════════════
            //  MESSAGE INPUT
            // ═══════════════════════════════════
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Add attachment button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF5F5F5),
                        border: Border.all(
                            color: const Color(0xFFE8E8E8), width: 1),
                      ),
                      child: const Icon(Icons.add,
                          color: Color(0xFF999999), size: 22),
                    ),
                    const SizedBox(width: 10),

                    // Text field
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        onChanged: _onTextChanged,
                        onSubmitted: (_) => _sendMessage(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFFBBBBBB),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F5FF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Send button
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: primaryPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return 'TODAY';
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'YESTERDAY';
    }
    return DateFormat('MMM d, yyyy').format(date).toUpperCase();
  }
}
