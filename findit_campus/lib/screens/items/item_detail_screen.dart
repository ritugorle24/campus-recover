import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import '../../providers/item_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/item_model.dart';
import '../../providers/chat_provider.dart';
import '../chat/chat_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;
  const ItemDetailScreen({super.key, required this.itemId});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _currentImageIndex = 0;
  final _verificationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemProvider>(context, listen: false)
          .fetchItemDetail(widget.itemId);
      Provider.of<ItemProvider>(context, listen: false)
          .fetchMatches(widget.itemId);
    });
  }

  @override
  void dispose() {
    _verificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<ItemProvider>(
          builder: (context, itemProvider, _) {
            if (itemProvider.isLoading && itemProvider.currentItem == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final item = itemProvider.currentItem;
            if (item == null) {
              return Center(
                child: Text('Item not found',
                    style: GoogleFonts.inter(color: AppColors.textPrimary)),
              );
            }

            final currentUserId =
                Provider.of<AuthProvider>(context, listen: false).user?.id;
            final isOwner = item.posterId == currentUserId;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── HEADER ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back,
                              color: AppColors.textPrimary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Campus Recover',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.accentGreen, width: 2),
                          ),
                          child: ClipOval(
                            child: Container(
                              color: AppColors.surfaceLight,
                              child: const Center(
                                child: Icon(Icons.person,
                                    color: AppColors.textMuted, size: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── IMAGE ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 220,
                            width: double.infinity,
                            color: AppColors.surfaceLight,
                            child: item.images.isNotEmpty
                                ? PageView.builder(
                                    itemCount: item.images.length,
                                    onPageChanged: (i) =>
                                        setState(() => _currentImageIndex = i),
                                    itemBuilder: (context, index) {
                                      return Image.network(
                                        ApiConfig.imageUrl(item.images[index]),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Center(
                                          child: Icon(
                                              Icons.image_not_supported,
                                              size: 48,
                                              color: AppColors.textMuted),
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Icon(
                                      item.isLost
                                          ? Icons.search_off_rounded
                                          : Icons.handshake_rounded,
                                      size: 60,
                                      color: AppColors.primary.withOpacity(0.3),
                                    ),
                                  ),
                          ),
                        ),
                        // Found today badge
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (item.isFound ? 'FOUND TODAY' : 'LOST ITEM').toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        // Dots indicator
                        if (item.images.length > 1)
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  List.generate(item.images.length, (i) {
                                return Container(
                                  width: _currentImageIndex == i ? 20 : 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 3),
                                  decoration: BoxDecoration(
                                    color: _currentImageIndex == i
                                        ? AppColors.primary
                                        : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── TITLE + CATEGORY ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'CATEGORY:\n${item.category.toUpperCase()}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── LOCATION ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.location.displayString,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── DESCRIPTION ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      item.description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── FINDER INFO CARD ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceLight),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.1),
                            ),
                            child: const Center(
                              child: Icon(Icons.person,
                                  color: AppColors.primary, size: 24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FINDER',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.posterName,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Campus Community Member',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.verified,
                              color: AppColors.primary, size: 22),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── OWNERSHIP VERIFICATION ──
                  if (!isOwner && item.isActive)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.surfaceLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shield_outlined,
                                    color: AppColors.primary, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'Ownership Verification',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            ElevatedButton(
                              onPressed: () => _showVerificationDialog(context, item, itemProvider),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'This is Mine',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Chat with Finder button
                            OutlinedButton(
                              onPressed: () async {
                                final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                                
                                // Show loading indicator in snackbar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Initializing chat...')),
                                );
                                
                                final matchId = await chatProvider.initializeChat(item.id);
                                
                                if (!mounted) return;
                                
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                
                                if (matchId == null || matchId.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Could not initialize chat.')),
                                  );
                                  return;
                                }
                                
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      matchId: matchId,
                                      otherUserName: item.posterName,
                                      otherUserId: item.posterId,
                                    ),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                side: const BorderSide(color: AppColors.primary, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.chat_bubble_outline,
                                      color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Chat with Finder',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── OWNER DELETE BUTTON ──
                  if (isOwner)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: TextButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              title: const Text('Delete Item?'),
                              content: const Text(
                                  'This action cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, true),
                                  child: const Text('Delete',
                                      style: TextStyle(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await itemProvider.deleteItem(item.id);
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: AppColors.error.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                            side: const BorderSide(color: AppColors.error, width: 1.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.delete_outline,
                                color: AppColors.error, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Delete Item',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ── PRECISE DROP-OFF POINT ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRECISE DROP-OFF POINT',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.surfaceLight),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.surfaceLight,
                                        AppColors.surface,
                                      ],
                                    ),
                                  ),
                                ),
                                // Map pin
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  AppColors.primary.withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.location.displayString,
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ── RECEIVED CLAIMS (FOR FINDER) ──
                  if (isOwner && item.isActive)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RECEIVED CLAIMS',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (itemProvider.matches.where((m) => m['claimStatus'] == 'submitted').isEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.surfaceLight),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, color: AppColors.textMuted, size: 20),
                                  const SizedBox(width: 10),
                                  Text('No pending claims yet.', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
                                ],
                              ),
                            )
                          else
                            ...itemProvider.matches.where((m) => m['claimStatus'] == 'submitted').map((match) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.surfaceLight),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.account_circle, color: AppColors.primary, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Claim from ${match['lostItem']?['postedBy']?['name'] ?? 'Owner'}',
                                          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Owner\'s Description:',
                                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      match['claimDescription'] ?? 'No description provided.',
                                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => _handleClaim(context, match['_id'], 'approve', itemProvider),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.success,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              elevation: 0,
                                            ),
                                            child: const Text('Approve', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => _handleClaim(context, match['_id'], 'reject', itemProvider),
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(color: AppColors.error),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            child: const Text('Reject', style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        final otherUserId = match['lostItem']?['postedBy']?['_id'];
                                        final otherUserName = match['lostItem']?['postedBy']?['name'] ?? 'Owner';
                                        
                                        if (otherUserId == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Cannot initialize chat.')),
                                          );
                                          return;
                                        }

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              matchId: match['_id'],
                                              otherUserName: otherUserName,
                                              otherUserId: otherUserId,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.primary),
                                      label: Text('Chat with Owner', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.surfaceLight,
                                        elevation: 0,
                                        minimumSize: const Size(double.infinity, 44),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),
                  // ── VERIFY HANDOVER ──
                  Builder(
                    builder: (context) {
                      final matches = itemProvider.matches;
                      final approvedMatch = matches.cast<Map<String, dynamic>?>().firstWhere(
                            (m) => m?['claimStatus'] == 'approved',
                            orElse: () => null,
                          );

                      if (approvedMatch == null) return const SizedBox.shrink();
                      
                      final claimId = approvedMatch['_id'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VERIFY HANDOVER',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/generate-qr', arguments: claimId);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.qr_code_2, color: AppColors.primary, size: 32),
                                          const SizedBox(height: 8),
                                          Text('Your QR', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                                          Text('Show to finder', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/scan-qr');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppColors.surfaceLight),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.qr_code_scanner, color: AppColors.textSecondary, size: 32),
                                          const SizedBox(height: 8),
                                          Text('Scan Finder', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                                          Text('Scan their QR', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/generate-qr', arguments: claimId);
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text('Generate My Handover QR', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showVerificationDialog(BuildContext context, ItemModel item, ItemProvider provider) async {
    final question = await provider.fetchSecurityQuestion(item.id);
    final matches = provider.matches;
    final matchId = matches.isNotEmpty ? matches.first['_id'] : null;

    if (!mounted) return;

    if (question == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No security question found for this item.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.lock_person_rounded, color: AppColors.primary, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Verify Your Ownership',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'The finder set a security question to verify the real owner.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FINDER\'S QUESTION:',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'YOUR ANSWER:',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _verificationController,
              decoration: InputDecoration(
                hintText: 'Type your answer here...',
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final answer = _verificationController.text.trim();
                if (answer.isEmpty) return;

                final result = await provider.submitClaim(
                  itemId: item.id,
                  matchId: matchId,
                  answer: answer,
                  description: 'Verified via security question',
                );

                if (!mounted) return;

                if (result['success'] || result['statusCode'] == 200) {
                  Navigator.pop(ctx);
                  _verificationController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Claim submitted! Waiting for finder approval.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  // Refresh matches to enable chat
                  provider.fetchMatches(item.id);
                } else {
                  final msg = result['statusCode'] == 403 
                      ? 'Incorrect answer. Please try again.' 
                      : (result['message'] ?? 'Incorrect answer. Please try again.');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Submit Answer', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleClaim(BuildContext context, String matchId, String action, ItemProvider provider) async {
    final result = await provider.verifyClaim(matchId: matchId, action: action);
    
    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Claim ${action}d successfully!'),
          backgroundColor: action == 'approve' ? AppColors.success : AppColors.error,
        ),
      );
      // Refresh details to show handover section
      provider.fetchMatches(widget.itemId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Error processing claim.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
