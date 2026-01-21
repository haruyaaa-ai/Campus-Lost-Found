import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/animations.dart';
import 'home_screen.dart';
import 'edit_report_screen.dart';

class MyReportsScreen extends StatefulWidget {
  final String reporterEmail;

  const MyReportsScreen({Key? key, this.reporterEmail = 'budi@email.com'})
    : super(key: key);

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : AppColors.surface,
        elevation: 1,
        title: Text(
          'Laporan Saya',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor: AppColors.primaryColor,
          tabs: const [
            Tab(text: 'Hilang'),
            Tab(text: 'Ditemukan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportsList(ItemType.lost),
          _buildReportsList(ItemType.found),
        ],
      ),
    );
  }

  Widget _buildReportsList(ItemType type) {
    return Consumer<ItemProvider>(
      builder: (context, itemProvider, _) {
        final myReports = itemProvider.getMyReports(widget.reporterEmail);
        final filteredReports = myReports
            .where((item) => item.type == type)
            .toList();

        if (filteredReports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == ItemType.lost
                      ? Icons.search_off
                      : Icons.check_circle_outline,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  type == ItemType.lost
                      ? 'Anda belum melaporkan barang hilang'
                      : 'Anda belum melaporkan barang ditemukan',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => itemProvider.refreshData(),
          color: AppColors.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredReports.length,
                itemBuilder: (context, index) {
                  final report = filteredReports[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Stack(
                      children: [
                        FadeInSlide(
                          delay: Duration(milliseconds: index * 50),
                          child: ItemCard(
                            item: report,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ItemDetailsScreen(itemId: report.id),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                onTap: () {
                                  Future.delayed(
                                    const Duration(seconds: 0),
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditReportScreen(item: report),
                                      ),
                                    ),
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Icon(Icons.edit, color: AppColors.infoColor),
                                    SizedBox(width: 8),
                                    Text('Edit Laporan'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Hapus Laporan'),
                                      content: const Text(
                                        'Apakah Anda yakin ingin menghapus laporan ini?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Provider.of<ItemProvider>(
                                              context,
                                              listen: false,
                                            ).deleteItem(report.id);
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Laporan berhasil dihapus',
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Hapus',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Hapus'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
