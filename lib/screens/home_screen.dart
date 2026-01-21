import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_theme.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/animations.dart';
import 'lost_items_screen.dart';
import 'found_items_screen.dart';
import 'report_lost_screen.dart';
import 'report_found_screen.dart';
import 'my_reports_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          const LostItemsScreen(),
          const FoundItemsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textTertiary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Hilang'),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_rounded),
            label: 'Ditemukan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: () => Provider.of<ItemProvider>(context, listen: false).refreshData(),
      color: AppColors.primaryColor,
      edgeOffset: 20,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.lg),
                bottomRight: Radius.circular(AppRadius.lg),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              40,
              AppSpacing.md,
              AppSpacing.xl + 30, // Extra padding for search bar overlap
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Campus Lost & Found',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.surface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Temukan barang hilang Anda dengan mudah',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.surface.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar (Overlapping)
          Transform.translate(
            offset: const Offset(0, -25),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [AppShadow.md],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari barang (contoh: Dompet, Kunci)...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Category Chips
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                final category = index == 0 ? 'Semua' : categories[index - 1];
                final isSelected = _selectedCategory == category;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : Colors.white,
                    selectedColor: AppColors.primaryColor.withOpacity(0.1),
                    checkmarkColor: AppColors.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primaryColor : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryColor : AppColors.borderColor.withOpacity(0.5),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Show Search Results or Regular Content
          if (_searchQuery.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Hasil Pencarian "${_searchQuery}"',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Consumer<ItemProvider>(
                    builder: (context, itemProvider, _) {
                      var searchResults =
                          itemProvider.searchItems(_searchQuery);
                      
                      if (_selectedCategory != 'Semua') {
                        searchResults = searchResults
                            .where((item) => item.category == _selectedCategory)
                            .toList();
                      }
                      
                      if (searchResults.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              children: [
                                Icon(Icons.search_off,
                                    size: 64, color: AppColors.textTertiary),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'Tidak ditemukan barang\ndengan kata kunci tersebut',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: ItemCard(
                              item: searchResults[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ItemDetailsScreen(
                                        itemId: searchResults[index].id),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ] else ...[
            // Statistics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Consumer<ItemProvider>(
                builder: (context, itemProvider, _) {
                  final lostCount = itemProvider.getLostItems().length;
                  final foundCount = itemProvider.getFoundItems().length;

                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Barang Hilang',
                          count: lostCount,
                          color: AppColors.errorColor,
                          icon: Icons.search,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _StatCard(
                          title: 'Barang Ditemukan',
                          count: foundCount,
                          color: AppColors.successColor,
                          icon: Icons.check_circle,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aksi Cepat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.add_circle,
                          label: 'Laporkan\nHilang',
                          color: AppColors.errorColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReportLostScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.add,
                          label: 'Laporkan\nDitemukan',
                          color: AppColors.successColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReportFoundScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

          // Recent Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dilaporkan Terbaru',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Consumer<ItemProvider>(
                builder: (context, itemProvider, _) {
                  if (itemProvider.isLoading) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) => const ItemCardShimmer(),
                    );
                  }

                  var items = itemProvider.items;
                  if (_selectedCategory != 'Semua') {
                    items = items
                        .where((item) => item.category == _selectedCategory)
                        .toList();
                  }
                  final itemsToShow = items.take(3).toList();

                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          'Belum ada laporan terbaru',
                          style: TextStyle(color: AppColors.textTertiary),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: itemsToShow.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: FadeInSlide(
                          delay: Duration(milliseconds: index * 100),
                          child: ItemCard(
                            item: itemsToShow[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ItemDetailsScreen(itemId: itemsToShow[index].id),
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
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    ),
  );
}
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withRed((color.red + 40).clamp(0, 255))],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemDetailsScreen extends StatelessWidget {
  final String itemId;

  const ItemDetailsScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemProvider>(
      builder: (context, itemProvider, _) {
        final item = itemProvider.getItemById(itemId);

        if (item == null) {
          return const Scaffold(body: Center(child: Text('Item not found')));
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
            elevation: 1,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Detail Barang',
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Hero(
                  tag: item.id,
                  child: GestureDetector(
                    onTap: () {
                      if (item.imageUrls.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.zero,
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                InteractiveViewer(
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    child: item.imageUrls.first.startsWith('http')
                                        ? Image.network(item.imageUrls.first, fit: BoxFit.contain)
                                        : (item.imageUrls.first.startsWith('data:image')
                                            ? Image.memory(base64Decode(item.imageUrls.first.split(',').last), fit: BoxFit.contain)
                                            : (!kIsWeb
                                                ? Image.file(File(item.imageUrls.first), fit: BoxFit.contain)
                                                : const Icon(Icons.broken_image, size: 100))),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: item.imageUrls.isNotEmpty
                          ? (item.imageUrls.first.startsWith('http')
                              ? Image.network(
                                  item.imageUrls.first,
                                  fit: BoxFit.cover,
                                )
                              : (item.imageUrls.first.startsWith('data:image')
                                  ? Image.memory(
                                      base64Decode(item.imageUrls.first.split(',').last),
                                      fit: BoxFit.cover,
                                    )
                                  : (!kIsWeb
                                      ? Image.file(
                                          File(item.imageUrls.first),
                                          fit: BoxFit.cover,
                                        )
                                      : const Center(child: Icon(Icons.broken_image)))))
                          : Center(
                              child: Icon(
                                item.type == ItemType.lost
                                    ? Icons.search
                                    : Icons.check_circle,
                                size: 80,
                                color: item.type == ItemType.lost
                                    ? AppColors.errorColor
                                    : AppColors.successColor,
                              ),
                            ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(item.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          _getStatusLabel(item.status),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(item.status),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Details Section
                      _DetailItem(
                        icon: Icons.category,
                        label: 'Kategori',
                        value: item.category,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _DetailItem(
                        icon: Icons.location_on,
                        label: 'Lokasi',
                        value: item.location,
                      ),
                      if (item.locationDetail.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 48),
                          child: Text(
                            item.locationDetail,
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      _DetailItem(
                        icon: Icons.calendar_today,
                        label: 'Tanggal Dilaporkan',
                        value: _formatDate(item.dateReported),
                      ),

                      if (item.dateLost != null)
                        Column(
                          children: [
                            const SizedBox(height: AppSpacing.md),
                            _DetailItem(
                              icon: Icons.access_time,
                              label: 'Tanggal Hilang',
                              value: _formatDate(item.dateLost!),
                            ),
                          ],
                        ),

                      const SizedBox(height: AppSpacing.lg),

                      // Description
                      Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Reporter Info
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: isDark ? Border.all(color: AppColors.darkBorderColor) : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Pelapor',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: isDark ? AppColors.darkTextTertiary : AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nama',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                                        ),
                                      ),
                                      Text(
                                        item.reporterName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Icon(
                                  Icons.email,
                                  color: isDark ? AppColors.darkTextTertiary : AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Email',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                                        ),
                                      ),
                                      Text(
                                        item.reporterEmail,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: isDark ? AppColors.darkTextTertiary : AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Telepon',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                                        ),
                                      ),
                                      Text(
                                        item.reporterPhone,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.message, color: Colors.green),
                                  onPressed: () => _launchWhatsApp(
                                    item.reporterPhone,
                                    "Halo ${item.reporterName}, saya menghubungi terkait laporan barang '${item.title}' di aplikasi Lost & Found.",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Safety Tips Card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.security, color: Colors.orange, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Tips Keamanan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Untuk menghindari penipuan, penemu berhak menanyakan ciri khusus barang (seperti wallpaper HP, isi tas, atau goresan tertentu) yang tidak terlihat di foto.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      if (item.status == ItemStatus.claimed) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.successColor.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.verified, color: AppColors.successColor),
                                  SizedBox(width: 8),
                                  Text(
                                    'Sudah Diklaim',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.successColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _DetailItem(
                                icon: Icons.person_outline,
                                label: 'Diklaim Oleh',
                                value: item.claimerName ?? '-',
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _DetailItem(
                                icon: Icons.email_outlined,
                                label: 'Email Pengklaim',
                                value: item.claimerEmail ?? '-',
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _DetailItem(
                                icon: Icons.event_available,
                                label: 'Tanggal Klaim',
                                value: item.dateClaimed != null ? _formatDate(item.dateClaimed!) : '-',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // Claim Button
                      // Claim Button
                      if (item.status == ItemStatus.open) ...[
                        if (FirebaseAuth.instance.currentUser?.email == item.reporterEmail)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.infoColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: AppColors.infoColor),
                            ),
                            child: const Text(
                              'Ini adalah laporan Anda. Menunggu respon dari pengguna lain.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.infoColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          _ClaimButton(itemId: item.id),
                      ],

                      // Resolve Button (Only for reporter when claimed)
                      if (item.status == ItemStatus.claimed && 
                          FirebaseAuth.instance.currentUser?.email == item.reporterEmail) ...[
                        const SizedBox(height: AppSpacing.md),
                        _ResolveButton(itemId: item.id),
                      ],

                      // Resolved Status Info
                      if (item.status == ItemStatus.resolved) ...[
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.successColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.check_circle, color: AppColors.successColor),
                              SizedBox(width: 8),
                              Text(
                                'Barang ini telah berhasil dikembalikan!',
                                style: TextStyle(
                                  color: AppColors.successColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusLabel(ItemStatus status) {
    switch (status) {
      case ItemStatus.open:
        return 'Terbuka';
      case ItemStatus.claimed:
        return 'Diklaim';
      case ItemStatus.resolved:
        return 'Selesai';
    }
  }

  Color _getStatusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.open:
        return AppColors.infoColor;
      case ItemStatus.claimed:
        return AppColors.warningColor;
      case ItemStatus.resolved:
        return AppColors.successColor;
    }
  }

  Future<void> _launchWhatsApp(String phone, String message) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    var finalPhone = cleanPhone;
    if (finalPhone.startsWith('0')) {
      finalPhone = '62${finalPhone.substring(1)}';
    } else if (!finalPhone.startsWith('62')) {
      finalPhone = '62$finalPhone';
    }

    final url = Uri.parse("https://wa.me/$finalPhone?text=${Uri.encodeComponent(message)}");
    if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // launched
    }
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 20),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClaimButton extends StatelessWidget {
  final String itemId;

  const _ClaimButton({required this.itemId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => _ClaimDialog(itemId: itemId),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: const Text(
          'Klaim Barang Ini',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.surface,
          ),
        ),
      ),
    );
  }
}

class _ResolveButton extends StatelessWidget {
  final String itemId;

  const _ResolveButton({required this.itemId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Konfirmasi Selesai'),
              content: const Text(
                  'Apakah Anda yakin barang ini sudah kembali ke pemiliknya? Status akan diubah menjadi Selesai.'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<ItemProvider>(context, listen: false).markAsResolved(itemId);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Laporan ditandai sebagai Selesai!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  child: const Text('Ya, Selesai', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.successColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.done_all, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Konfirmasi & Selesai',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaimDialog extends StatefulWidget {
  final String itemId;

  const _ClaimDialog({required this.itemId});

  @override
  State<_ClaimDialog> createState() => _ClaimDialogState();
}

class _ClaimDialogState extends State<_ClaimDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _verificationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? user.email?.split('@')[0] ?? '';
      _emailController.text = user.email ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Klaim Barang',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _verificationController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Bukti Kepemilikan',
                hintText: 'Sebutkan ciri khusus yang tidak ada di foto (misal: ada stiker di belakang, nomor seri, dll)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                prefixIcon: const Icon(Icons.verified_user_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.isNotEmpty &&
                          _emailController.text.isNotEmpty &&
                          _verificationController.text.isNotEmpty) {
                        Provider.of<ItemProvider>(
                          context,
                          listen: false,
                        ).markAsClaimed(
                          widget.itemId,
                          _nameController.text,
                          _emailController.text,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Barang berhasil diklaim!'),
                          ),
                        );
                      }
                    },
                    child: const Text('Klaim'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
