import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/persian_utils.dart';
import '../../data/models/salon_model.dart';
import 'star_rating.dart';

class SalonCard extends StatelessWidget {
  final SalonModel salon;
  final VoidCallback onTap;
  final bool compact;

  const SalonCard({
    super.key,
    required this.salon,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return compact ? _buildCompact(context) : _buildLarge(context);
  }

  Widget _buildLarge(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: _buildCoverImage(height: 180),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          salon.name,
                          style: const TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (salon.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: AppColors.success, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                'تأیید شده',
                                style: TextStyle(
                                  fontFamily: 'Vazirmatn',
                                  fontSize: 11,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          salon.address,
                          style: const TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      StarRating(rating: salon.rating, reviewCount: salon.reviewCount),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _categoryColor(salon.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          salon.categoryLabel,
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _categoryColor(salon.category),
                          ),
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
    );
  }

  Widget _buildCompact(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: _buildCoverImage(height: 120),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salon.name,
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  StarRating(rating: salon.rating, size: 13, showCount: false),
                  const SizedBox(height: 4),
                  Text(
                    salon.address,
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage({required double height}) {
    return Container(
      height: height,
      color: AppColors.primary.withOpacity(0.1),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _SalonPlaceholderImage(salonId: salon.id),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.primary.withOpacity(0.3)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(SalonCategory category) {
    switch (category) {
      case SalonCategory.male:
        return Colors.blue;
      case SalonCategory.female:
        return Colors.pink;
      case SalonCategory.unisex:
        return Colors.purple;
    }
  }
}

class _SalonPlaceholderImage extends StatelessWidget {
  final String salonId;

  const _SalonPlaceholderImage({required this.salonId});

  @override
  Widget build(BuildContext context) {
    final colors = [
      [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
      [const Color(0xFF0F3460), const Color(0xFF533483)],
      [const Color(0xFF2C3E50), const Color(0xFF4CA1AF)],
      [const Color(0xFF373B44), const Color(0xFF4286f4)],
      [const Color(0xFF141E30), const Color(0xFF243B55)],
    ];
    final idx = int.tryParse(salonId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final colorPair = colors[idx % colors.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colorPair,
        ),
      ),
      child: const Center(
        child: Icon(Icons.content_cut, color: Colors.white54, size: 48),
      ),
    );
  }
}
