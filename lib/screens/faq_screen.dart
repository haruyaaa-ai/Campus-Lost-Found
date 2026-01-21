import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Bantuan & FAQ',
          style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        elevation: 1,
        iconTheme: IconThemeData(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildFAQItem(
            context,
            'Bagaimana cara melaporkan barang hilang?',
            'Anda dapat pergi ke halaman utama dan menekan tombol "Lapor Barang Hilang". Isi formulir dengan detail barang dan sertakan foto jika ada.',
            isDark,
          ),
          _buildFAQItem(
            context,
            'Apakah saya harus login untuk melapor?',
            'Ya, Anda perlu masuk ke akun Anda agar kami dapat memproses laporan dan memudahkan orang lain menghubungi Anda.',
            isDark,
          ),
          _buildFAQItem(
            context,
            'Bagaimana cara mengklaim barang yang ditemukan?',
            'Cari barang di daftar "Barang Ditemukan", klik detail barang, lalu hubungi pelapor melalui informasi kontak yang tersedia.',
            isDark,
          ),
          _buildFAQItem(
            context,
            'Berapa lama laporan saya akan tayang?',
            'Laporan akan tetap ada sampai barang ditandai sebagai "Sudah Diklaim" atau Anda menghapusnya sendiri.',
            isDark,
          ),
          _buildFAQItem(
            context,
            'Apa batas ukuran foto yang diunggah?',
            'Untuk saat ini, foto dibatasi maksimal 800KB untuk menjaga efisiensi database.',
            isDark,
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              'Masih butuh bantuan? Hubungi kami di:\nsupport@lostandfound.sch.id',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: isDark ? AppColors.darkBorderColor : AppColors.borderColor),
      ),
      elevation: 0,
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        iconColor: AppColors.primaryColor,
        collapsedIconColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
