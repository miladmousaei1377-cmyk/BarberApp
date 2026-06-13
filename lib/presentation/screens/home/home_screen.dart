import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/utils/persian_utils.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/salon_model.dart';
import '../../widgets/salon_card.dart';
import '../../widgets/loading_shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'all';
  bool _isLoading = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final _categories = [
    ('all', 'همه'),
    ('male', 'مردانه'),
    ('female', 'زنانه'),
    ('unisex', 'یونیسکس'),
  ];

  List<SalonModel> get _filteredSalons {
    var salons = MockData.getSalonsByCategory(
      _selectedCategory == 'all' ? null : _selectedCategory,
    );
    if (_searchQuery.isNotEmpty) {
      salons = salons
          .where((s) =>
              s.name.contains(_searchQuery) || s.address.contains(_searchQuery))
          .toList();
    }
    return salons;
  }

  List<SalonModel> get _nearbySalons => MockData.salons.take(3).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = StorageService.getUser();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.secondary,
        child: CustomScrollView(
          slivers: [
            _buildHeader(user?.fullName ?? 'کاربر'),
            SliverToBoxAdapter(child: _buildSearch()),
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(child: _buildNearbySection()),
            SliverToBoxAdapter(child: _buildTopSalonsTitle()),
            _isLoading
                ? SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const SalonCardShimmer(),
                      childCount: 3,
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => SalonCard(
                        salon: _filteredSalons[i],
                        onTap: () => Get.toNamed(Routes.salonDetail,
                            arguments: _filteredSalons[i]),
                      ),
                      childCount: _filteredSalons.length,
                    ),
                  ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: true,
      pinned: false,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.accent],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 52, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FadeInRight(
                child: Text(
                  'سلام، $name 👋',
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FadeInRight(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  PersianUtils.gregorianToJalali(DateTime.now()),
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 13,
                    color: Colors.white60,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return FadeInDown(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: TextField(
          controller: _searchController,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14),
          decoration: InputDecoration(
            hintText: 'جستجوی آرایشگاه، خدمات...',
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
          ),
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'دسته‌بندی',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final (value, label) = _categories[i];
                final isSelected = _selectedCategory == value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.secondary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.secondary : AppColors.divider,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.secondary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.near_me, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'نزدیک شما',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Get.toNamed(Routes.salonList),
                child: const Text(
                  'مشاهده همه',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 13,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 0),
              itemCount: _nearbySalons.length,
              itemBuilder: (_, i) => FadeInRight(
                delay: Duration(milliseconds: i * 100),
                child: SalonCard(
                  salon: _nearbySalons[i],
                  compact: true,
                  onTap: () => Get.toNamed(Routes.salonDetail, arguments: _nearbySalons[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSalonsTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: AppColors.gold, size: 20),
          const SizedBox(width: 8),
          const Text(
            'برترین‌ها',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
