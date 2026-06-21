import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/utils/persian_utils.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/salon_model.dart';
import '../../widgets/salon_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/location_selector_sheet.dart';

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
  Position? _userPosition;
  List<String> _selectedCities = [];

  final _categories = [
    ('all', 'همه'),
    ('male', 'مردانه'),
    ('female', 'زنانه'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCities = StorageService.selectedCities;
    _loadUserLocation().then((_) {
      // Only ask for city if GPS failed AND no city was previously saved.
      if (mounted && _userPosition == null && _selectedCities.isEmpty) {
        _openCitySelector(firstTime: true);
      }
    });
  }

  Future<void> _loadUserLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever ||
          perm == LocationPermission.denied) return;
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      if (mounted) setState(() => _userPosition = pos);
    } catch (_) {}
  }

  Future<void> _openCitySelector({bool firstTime = false}) async {
    final result = await showLocationSelector(
      context,
      initialSelected: _selectedCities,
    );
    if (result == null) return;
    await StorageService.setSelectedCities(result);
    if (mounted) setState(() => _selectedCities = result);
  }

  String get _cityButtonLabel {
    if (_selectedCities.isEmpty) return 'انتخاب شهر';
    if (_selectedCities.length == 1) return _selectedCities.first;
    return '${_selectedCities.length} شهر';
  }

  String get _nearbySectionTitle {
    if (_userPosition != null) return 'نزدیک شما';
    if (_selectedCities.isNotEmpty) {
      if (_selectedCities.length == 1) return 'در ${_selectedCities.first}';
      return 'در ${_selectedCities.length} شهر';
    }
    return 'نزدیک شما';
  }

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

  // Priority 1: GPS (always first, 20 km radius, sorted by distance)
  // Priority 2: Selected cities if GPS unavailable (sorted by rating)
  // Priority 3: Empty list — show empty-state UI
  List<SalonModel> get _nearbySalons {
    var withCoords = MockData.salons.where((s) => s.lat != 0.0 && s.lng != 0.0).toList();
    if (_selectedCategory != 'all') {
      withCoords = withCoords.where((s) => s.categoryValue == _selectedCategory).toList();
    }

    if (_userPosition != null) {
      const dist = Distance();
      final userLoc = LatLng(_userPosition!.latitude, _userPosition!.longitude);
      return withCoords.where((s) {
        final km = dist.as(LengthUnit.Kilometer, userLoc, LatLng(s.lat, s.lng));
        return km <= 20.0;
      }).toList()
        ..sort((a, b) {
          final dA = dist.as(LengthUnit.Kilometer, userLoc, LatLng(a.lat, a.lng));
          final dB = dist.as(LengthUnit.Kilometer, userLoc, LatLng(b.lat, b.lng));
          return dA.compareTo(dB);
        });
    }

    if (_selectedCities.isNotEmpty) {
      return withCoords
          .where((s) => _selectedCities.contains(s.city))
          .toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));
    }

    return [];
  }

  // Salons in selected cities — shown as a separate "other cities" section
  // when GPS is active and user also has cities selected.
  List<SalonModel> get _citySalons {
    if (_userPosition == null || _selectedCities.isEmpty) return [];
    var withCoords = MockData.salons.where((s) => s.lat != 0.0 && s.lng != 0.0).toList();
    if (_selectedCategory != 'all') {
      withCoords = withCoords.where((s) => s.categoryValue == _selectedCategory).toList();
    }
    return withCoords
        .where((s) => _selectedCities.contains(s.city))
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  String get _citySectionTitle {
    if (_selectedCities.length == 1) return 'آرایشگاه‌های ${_selectedCities.first}';
    return 'آرایشگاه‌های ${_selectedCities.length} شهر';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await _loadUserLocation();
    if (mounted) setState(() => _isLoading = false);
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
            if (_searchQuery.isEmpty) ...[
              SliverToBoxAdapter(child: _buildNearbySection()),
              if (_citySalons.isNotEmpty)
                SliverToBoxAdapter(child: _buildCitiesSection()),
            ],
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
        GestureDetector(
          onTap: () => _openCitySelector(),
          child: Container(
            margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_city, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  _cityButtonLabel,
                  style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
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
            prefixIcon:
                const Icon(Icons.search, color: AppColors.textSecondary),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.textSecondary),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _categories.map((cat) {
                  final value = cat.$1;
                  final label = cat.$2;
                  final isSelected = _selectedCategory == value;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategory = value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.divider,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: AppColors.secondary
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2))
                                ]
                              : [],
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbySection() {
    final nearby = _nearbySalons;
    final sectionTitle = _nearbySectionTitle;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.near_me, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                sectionTitle,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (nearby.isNotEmpty)
                TextButton(
                  onPressed: () => Get.toNamed(
                    Routes.salonList,
                    arguments: {'salons': nearby, 'title': sectionTitle},
                  ),
                  child: const Text(
                    'مشاهده همه',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 13,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (nearby.isEmpty)
            _buildNearbyEmptyState()
          else
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                reverse: true,
                padding: EdgeInsets.zero,
                itemCount: nearby.length,
                itemBuilder: (_, i) => FadeInRight(
                  delay: Duration(milliseconds: i * 100),
                  child: SalonCard(
                    salon: nearby[i],
                    compact: true,
                    onTap: () => Get.toNamed(Routes.salonDetail,
                        arguments: nearby[i]),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNearbyEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_searching,
              size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          const Text(
            'آرایشگاهی نزدیک شما یافت نشد',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'دسترسی موقعیت را فعال کنید یا شهر مدنظر را انتخاب کنید',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (_userPosition == null && _selectedCities.isEmpty) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _loadUserLocation().then((_) {
                    if (mounted) setState(() {});
                  }),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.my_location, size: 16),
                  label: const Text('فعال‌سازی موقعیت',
                      style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _openCitySelector(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.location_city, size: 16),
                  label: const Text('انتخاب شهر',
                      style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCitiesSection() {
    final salons = _citySalons;
    final title = _citySectionTitle;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_city,
                  color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(
                  Routes.salonList,
                  arguments: {'salons': salons, 'title': title},
                ),
                child: const Text(
                  'مشاهده همه',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 13,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              reverse: true,
              padding: EdgeInsets.zero,
              itemCount: salons.length,
              itemBuilder: (_, i) => FadeInRight(
                delay: Duration(milliseconds: i * 100),
                child: SalonCard(
                  salon: salons[i],
                  compact: true,
                  onTap: () =>
                      Get.toNamed(Routes.salonDetail, arguments: salons[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSalonsTitle() {
    final topSalons = List<SalonModel>.from(MockData.salons)
      ..sort((a, b) => b.rating.compareTo(a.rating));
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
          const Spacer(),
          TextButton(
            onPressed: () => Get.toNamed(
              Routes.salonList,
              arguments: {'salons': topSalons, 'title': 'برترین‌ها'},
            ),
            child: const Text(
              'مشاهده همه',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 13,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
