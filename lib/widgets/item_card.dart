import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import '../constants/app_theme.dart';
import '../models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const ItemCard({Key? key, required this.item, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.3)
                  : (item.type == ItemType.lost 
                      ? AppColors.errorColor.withOpacity(0.08)
                      : AppColors.successColor.withOpacity(0.08)),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: isDark ? AppColors.darkBorderColor : AppColors.borderColor.withOpacity(0.5), 
            width: 1
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  Hero(
                    tag: item.id,
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceLight : AppColors.surfaceLight.withOpacity(0.5),
                        image: item.imageUrls.isNotEmpty
                            ? (item.imageUrls.first.startsWith('http')
                                ? DecorationImage(
                                    image: NetworkImage(item.imageUrls.first),
                                    fit: BoxFit.cover,
                                  )
                                : (item.imageUrls.first.startsWith('data:image')
                                    ? DecorationImage(
                                        image: MemoryImage(
                                          base64Decode(item.imageUrls.first.split(',').last),
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : (!kIsWeb
                                        ? DecorationImage(
                                            image: FileImage(File(item.imageUrls.first)),
                                            fit: BoxFit.cover,
                                          )
                                        : null)))
                            : null,
                      ),
                      child: item.imageUrls.isEmpty
                          ? Center(
                              child: Icon(
                                item.type == ItemType.lost
                                    ? Icons.search_rounded
                                    : Icons.check_circle_rounded,
                                size: 48,
                                color: item.type == ItemType.lost
                                    ? AppColors.errorColor.withOpacity(0.5)
                                    : AppColors.successColor.withOpacity(0.5),
                              ),
                            )
                          : null,
                    ),
                  ),
                  // Type Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: item.status == ItemStatus.claimed
                            ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                            : (item.type == ItemType.lost
                                ? AppColors.errorColor
                                : AppColors.successColor),
                        borderRadius: BorderRadius.circular(AppRadius.circle),
                        boxShadow: [
                          BoxShadow(
                            color: (item.status == ItemStatus.claimed
                                    ? Colors.black
                                    : (item.type == ItemType.lost
                                        ? AppColors.errorColor
                                        : AppColors.successColor))
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        item.status == ItemStatus.claimed
                            ? 'SUDAH DIKLAIM'
                            : (item.type == ItemType.lost ? 'HILANG' : 'DITEMUKAN'),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.primaryColor.withOpacity(0.2) : AppColors.primaryLight.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.location,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(height: 1, color: isDark ? AppColors.darkBorderColor : AppColors.borderColor),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          _formatDate(item.dateReported),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
