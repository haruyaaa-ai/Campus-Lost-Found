import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/item_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/animations.dart';
import 'home_screen.dart';

class FoundItemsScreen extends StatefulWidget {
  const FoundItemsScreen({Key? key}) : super(key: key);

  @override
  State<FoundItemsScreen> createState() => _FoundItemsScreenState();
}

class _FoundItemsScreenState extends State<FoundItemsScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        elevation: 1,
        title: Text(
          'Barang Ditemukan',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        iconTheme: IconThemeData(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Cari barang ditemukan...',
                  hintStyle: TextStyle(color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primaryColor,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: isDark ? AppColors.darkBorderColor : AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: isDark ? AppColors.darkBorderColor : AppColors.borderColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),

            // Items List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Consumer<ItemProvider>(
                builder: (context, itemProvider, _) {
                  if (itemProvider.isLoading) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      itemBuilder: (context, index) => const ItemCardShimmer(),
                    );
                  }
                  var items = itemProvider.getFoundItems();

                  if (_searchController.text.isNotEmpty) {
                    items = itemProvider.searchItems(_searchController.text);
                    items = items
                        .where((item) => item.type.toString().contains('found'))
                        .toList();
                  }

                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Tidak ada barang ditemukan',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: FadeInSlide(
                          delay: Duration(milliseconds: index * 50),
                          child: ItemCard(
                            item: items[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ItemDetailsScreen(itemId: items[index].id),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
