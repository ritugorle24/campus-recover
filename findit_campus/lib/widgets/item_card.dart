import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../config/api_config.dart';
import '../models/item_model.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback? onTap;

  const ItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  IconData _getCategoryIcon() {
    switch (item.category) {
      case 'Electronics':
        return Icons.devices_rounded;
      case 'Books':
        return Icons.menu_book_rounded;
      case 'Clothing':
        return Icons.checkroom_rounded;
      case 'Accessories':
        return Icons.watch_rounded;
      case 'ID Cards':
        return Icons.badge_rounded;
      case 'Keys':
        return Icons.key_rounded;
      case 'Bags':
        return Icons.backpack_rounded;
      case 'Sports Equipment':
        return Icons.sports_soccer_rounded;
      case 'Stationery':
        return Icons.edit_rounded;
      case 'Water Bottles':
        return Icons.water_drop_rounded;
      case 'Wallets':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.surfaceLight.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Image or category icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: item.isLost
                      ? AppColors.lostGradient
                      : AppColors.foundGradient,
                ),
                child: (item.images.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          ApiConfig.imageUrl(item.images.first),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            _getCategoryIcon(),
                            color: Colors.white,
                            size: 32,
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      )
                    : Icon(
                        _getCategoryIcon(),
                        color: Colors.white,
                        size: 32,
                      ),
              ),
              const SizedBox(width: 14),
              // Details
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
                            color: item.isLost
                                ? AppColors.lost.withOpacity(0.2)
                                : AppColors.found.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.isLost ? 'LOST' : 'FOUND',
                            style: TextStyle(
                              color:
                                  item.isLost ? AppColors.lost : AppColors.found,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('MMM d').format(item.date),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title.isNotEmpty ? item.title : 'Untitled Item',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 15,
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.location.displayString,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 12,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.category_rounded,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.category.isNotEmpty ? item.category : 'Other',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (item.status != 'active') ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: item.isResolved
                                  ? AppColors.success.withOpacity(0.2)
                                  : AppColors.warning.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              (item.status ?? 'active').toUpperCase(),
                              style: TextStyle(
                                color: item.isResolved
                                    ? AppColors.success
                                    : AppColors.warning,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
