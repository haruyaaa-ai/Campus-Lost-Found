import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/item_provider.dart';
import '../providers/theme_provider.dart';
import '../services/firebase_service.dart';
import '../widgets/buttons.dart';
import 'login_screen.dart';
import 'my_reports_screen.dart';
import 'faq_screen.dart';
import 'about_app_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return StreamBuilder<User?>(
      stream: firebaseService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;

        if (user == null) {
          return _buildGuestView(context);
        }

        return _buildUserView(context, user, firebaseService);
      },
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_off_rounded,
                size: 80,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Belum Masuk',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Masuk untuk melihat profil dan mengelola laporan Anda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Masuk / Daftar',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserView(BuildContext context, User authUser, FirebaseService firebaseService) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<DocumentSnapshot>(
      stream: firebaseService.getUserProfile(authUser.uid),
      builder: (context, snapshot) {
        String displayName = authUser.displayName ?? authUser.email?.split('@')[0] ?? 'User';
        String? photoUrl;
        
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          displayName = data['displayName'] ?? displayName;
          photoUrl = data['photoUrl'];
        }

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    60,
                    AppSpacing.md,
                    AppSpacing.xxl,
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: photoUrl != null && photoUrl.startsWith('data:image')
                            ? ClipOval(
                                child: Image.memory(
                                  base64Decode(photoUrl.split(',').last),
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Text(
                                  displayName[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        authUser.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Stats Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Consumer<ItemProvider>(
                    builder: (context, itemProvider, _) {
                      final myReportsCount = itemProvider.getMyReports(authUser.email ?? '').length;
                      
                      return Row(
                        children: [
                          _buildStatItem(
                            context,
                            icon: Icons.assignment_turned_in_rounded,
                            label: 'Laporan Anda',
                            count: myReportsCount,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Menu Section
                _buildMenuSection(context, firebaseService, authUser.email ?? ''),
                
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuSection(BuildContext context, FirebaseService firebaseService, String email) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Pengaturan Akun',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkBorderColor : AppColors.borderColor.withOpacity(0.5),
              ),
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Icons.history_rounded,
                  label: 'Riwayat Laporan Saya',
                  subtitle: 'Semua barang yang Anda laporkan',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyReportsScreen(reporterEmail: email),
                      ),
                    );
                  },
                  color: AppColors.infoColor,
                ),
                _buildMenuItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Ubah Profil',
                  subtitle: 'Nama dan foto profil',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                  color: AppColors.successColor,
                ),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return _buildMenuItem(
                      icon: themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      label: 'Mode Gelap',
                      subtitle: themeProvider.isDarkMode ? 'Aktif' : 'Nonaktif',
                      onTap: () => themeProvider.toggleTheme(),
                      color: Colors.indigo,
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (v) => themeProvider.toggleTheme(),
                        activeColor: AppColors.primaryColor,
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.info_outline_rounded,
                  label: 'Tentang Aplikasi',
                  subtitle: 'Versi dan Pengembang',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutAppScreen()),
                    );
                  },
                  color: Colors.blue,
                ),
                _buildMenuItem(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Kebijakan Privasi',
                  subtitle: 'Data Anda aman bersama kami',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Kebijakan Privasi'),
                        content: const Text(
                          'Aplikasi Lost & Found UTB menjaga kerahasiaan data pribadi Anda. Data seperti nomor WhatsApp hanya akan ditampilkan pada laporan barang temuan agar pemilik barang dapat menghubungi Anda secara langsung.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                    );
                  },
                  color: Colors.teal,
                ),
                _buildMenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Keluar Akun',
                  subtitle: 'Sesi rilis saat ini akan berakhir',
                  onTap: () async => await firebaseService.signOut(),
                  color: AppColors.errorColor,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    Widget? trailing,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 12),
          ),
          trailing: trailing ?? const Icon(Icons.chevron_right_rounded, size: 20),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 56, endIndent: 16),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorderColor : AppColors.borderColor.withOpacity(0.5),
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
