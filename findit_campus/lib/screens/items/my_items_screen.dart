import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/item_provider.dart';
import '../../models/item_model.dart';
import '../../widgets/item_card.dart';

class MyItemsScreen extends StatefulWidget {
  const MyItemsScreen({super.key});

  @override
  State<MyItemsScreen> createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends State<MyItemsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemProvider>(context, listen: false).fetchMyItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Items'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {}),
              indicator: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Lost'),
                Tab(text: 'Found'),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<ItemProvider>(
        builder: (context, itemProvider, _) {
          if (itemProvider.isLoading && itemProvider.myItems.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final allItems = itemProvider.myItems;
          final lostItems = allItems.where((i) => i.isLost).toList();
          final foundItems = allItems.where((i) => i.isFound).toList();

          final displayItems = _tabController.index == 0
              ? allItems
              : _tabController.index == 1
                  ? lostItems
                  : foundItems;

          if (displayItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_rounded,
                      size: 60, color: AppColors.textMuted.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No items reported yet',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => itemProvider.fetchMyItems(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: displayItems.length,
              itemBuilder: (context, index) {
                return ItemCard(
                  item: displayItems[index],
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/item-detail',
                      arguments: displayItems[index].id,
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
}
