import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/persian_utils.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double size;
  final bool showCount;

  const StarRating({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.size = 16,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          if (i < rating.floor()) {
            return Icon(Icons.star_rounded, color: AppColors.gold, size: size);
          } else if (i < rating && rating - i >= 0.5) {
            return Icon(Icons.star_half_rounded, color: AppColors.gold, size: size);
          } else {
            return Icon(Icons.star_outline_rounded, color: AppColors.gold, size: size);
          }
        }),
        const SizedBox(width: 4),
        Text(
          PersianUtils.toPersianDigits(rating.toStringAsFixed(1)),
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: size - 2,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (showCount && reviewCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '(${PersianUtils.toPersianDigits(reviewCount.toString())})',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: size - 4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
