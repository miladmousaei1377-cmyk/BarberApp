import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/salon_model.dart';
import '../../widgets/salon_card.dart';
import '../../widgets/loading_shimmer.dart';

class SalonListScreen extends StatefulWidget {
  const SalonListScreen({super.key});

  @override
  State<SalonListScreen> createState() => _SalonListScreenState();
}

class _SalonListScreenState extends State<SalonListScreen> {
  String _selectedCategory = 'all';
  String _sortBy = 'rating';
  bool _isLoading = false;
  LatLng? _userLatLng;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is LatLng) _userLatLng = args;
  }

  List<SalonModel> get _sortedSalons {
    var list = MockData.getSalonsByCategory(
      _selectedCategory == 'all' ? null : _selectedCategory,
    );
    // Filter by proximity when GPS available (50km radius)
    if (_userLatLng != null) {
      const dist = Distance();
      list = list.where((s) {
        if (s.lat == 0.0 && s.lng == 0.0) return false;
        final km = dist.as(LengthUnit.Kilometer, _userLatLng!, LatLng(s.lat, s.lng));
        return km <= 50.0;
      }).toList();
    }
    list = List.from(list);
    switch (_sortBy) {
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'reviews':
        list.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
    }
    return list;
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setInner) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'فیلتر و مرتب‌سازی',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'اعمال',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'مرتب‌سازی',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              _FilterOption(
                label: 'بیشترین امتیاز',
                value: 'rating',
                groupValue: _sortBy,
                onChanged: (v) {
                  setInner(() => _sortBy = v!);
                  setState(() {});
                },
              ),
              _FilterOption(
                label: 'بیشترین نظرات',
                value: 'reviews',
                groupValue: _sortBy,
                onChanged: (v) {
                  setInner(() => _sortBy = v!);
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'دسته‌بندی',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final (val, label) in [
                    ('all', 'همه'),
                    ('male', 'مردانه'),
                    ('female', 'زنانه'),
                  ])
                    ChoiceChip(
                      label: Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          color: _selectedCategory == val ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      selected: _selectedCategory == val,
                      selectedColor: AppColors.secondary,
                      onSelected: (_) {
                        setInner(() => _selectedCategory = val);
                        setState(() {});
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('آرایشگاه‌ها'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.secondary,
        child: _isLoading
            ? ListView.builder(
                itemCount: 4,
                itemBuilder: (_, __) => const SalonCardShimmer(),
              )
            : _sortedSalons.isEmpty
                ? const Center(
                    child: Text(
                      'آرایشگاهی یافت نشد',
                      style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _sortedSalons.length,
                    itemBuilder: (_, i) => SalonCard(
                      salon: _sortedSalons[i],
                      onTap: () => Get.toNamed(Routes.salonDetail, arguments: _sortedSalons[i]),
                    ),
                  ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _FilterOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      dense: true,
      title: Text(
        label,
        style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14),
      ),
      value: value,
      groupValue: groupValue,
      activeColor: AppColors.secondary,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}
