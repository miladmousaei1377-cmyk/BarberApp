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

// City center coordinates for proximity-based filtering
const _kCityCenters = {
  'تهران':     (35.6892, 51.3890),
  'مشهد':      (36.2972, 59.6067),
  'اصفهان':    (32.6546, 51.6680),
  'کرج':       (35.8327, 50.9986),
  'شیراز':     (29.5918, 52.5836),
  'تبریز':     (38.0799, 46.2910),
  'اهواز':     (31.3183, 48.6694),
  'قم':        (34.6416, 50.8746),
  'کرمانشاه':  (34.3277, 47.0783),
  'ارومیه':    (37.5527, 45.0760),
  'رشت':       (37.2809, 49.5831),
  'زاهدان':    (29.4963, 60.8629),
  'همدان':     (34.7990, 48.5146),
  'کرمان':     (30.2839, 57.0834),
  'یزد':       (31.8974, 54.3569),
  'اردبیل':    (38.2498, 48.2933),
  'بندر عباس': (27.1865, 56.2808),
  'اراک':      (34.0954, 49.7088),
  'قزوین':     (36.2688, 50.0041),
  'سنندج':     (35.3219, 46.9861),
  'گرگان':     (36.8422, 54.4415),
  'ساری':      (36.5633, 53.0601),
  'زنجان':     (36.6736, 48.4787),
  'بیرجند':    (32.8663, 59.2211),
  'خرم‌آباد':  (33.4878, 48.3558),
  'سمنان':     (35.5761, 53.3895),
};

const _kIranCities = [
  'تهران', 'مشهد', 'اصفهان', 'کرج', 'شیراز', 'تبریز', 'اهواز',
  'قم', 'کرمانشاه', 'ارومیه', 'رشت', 'زاهدان', 'همدان', 'کرمان',
  'یزد', 'اردبیل', 'بندر عباس', 'اراک', 'قزوین', 'سنندج',
  'سمنان', 'گرگان', 'ساری', 'زنجان', 'بیرجند', 'خرم‌آباد',
];

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
  String? _selectedCity;

  final _categories = [
    ('all', 'همه'),
    ('male', 'مردانه'),
    ('female', 'زنانه'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCity = StorageService.selectedCity;
    _loadUserLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!StorageService.hasCitySelected) {
        _showCitySelector(firstTime: true);
      }
    });
  }

  Future<void> _loadUserLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) return;
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      if (mounted) setState(() => _userPosition = pos);
    } catch (_) {}
  }

  void _showCitySelector({bool firstTime = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        final searchCtrl = TextEditingController();
        return StatefulBuilder(
          builder: (ctx, setS) {
            final query = searchCtrl.text.trim();
            final filtered = query.isEmpty
                ? _kIranCities
                : _kIranCities.where((c) => c.contains(query)).toList();
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_city, color: AppColors.primary, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              firstTime ? 'شهر خود را انتخاب کنید' : 'تغییر شهر',
                              style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        if (firstTime) ...[
                          const SizedBox(height: 4),
                          const Text('برای نمایش آرایشگاه‌های نزدیک شما', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: AppColors.textSecondary)),
                        ],
                        const SizedBox(height: 12),
                        TextField(
                          controller: searchCtrl,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'جستجوی شهر...',
                            hintStyle: const TextStyle(fontFamily: 'Vazirmatn', color: AppColors.textSecondary, fontSize: 13),
                            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          onChanged: (_) => setS(() {}),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final city = filtered[i];
                        final isSelected = city == _selectedCity;
                        return ListTile(
                          title: Text(city, style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal, color: isSelected ? AppColors.secondary : AppColors.textPrimary)),
                          trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.secondary, size: 20) : null,
                          onTap: () async {
                            await StorageService.setSelectedCity(city);
                            if (mounted) {
                              setState(() => _selectedCity = city);
                              Navigator.pop(ctx);
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
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

  List<SalonModel> get _nearbySalons {
    final withCoords = MockData.salons.where((s) => s.lat != 0.0 && s.lng != 0.0).toList();
    const dist = Distance();

    // City selected → filter by distance from city center (50 km)
    if (_selectedCity != null && _selectedCity!.isNotEmpty) {
      final coords = _kCityCenters[_selectedCity!];
      if (coords != null) {
        final cityCenter = LatLng(coords.$1, coords.$2);
        final inCity = withCoords.where((s) {
          final km = dist.as(LengthUnit.Kilometer, cityCenter, LatLng(s.lat, s.lng));
          return km <= 50.0;
        }).toList()
          ..sort((a, b) {
            final dA = dist.as(LengthUnit.Kilometer, cityCenter, LatLng(a.lat, a.lng));
            final dB = dist.as(LengthUnit.Kilometer, cityCenter, LatLng(b.lat, b.lng));
            return dA.compareTo(dB);
          });
        return inCity;
      }
    }

    // No city selected — filter by GPS (15 km)
    if (_userPosition != null) {
      final userLoc = LatLng(_userPosition!.latitude, _userPosition!.longitude);
      final nearby = withCoords.where((s) {
        final km = dist.as(LengthUnit.Kilometer, userLoc, LatLng(s.lat, s.lng));
        return km <= 15.0;
      }).toList()
        ..sort((a, b) {
          final dA = dist.as(LengthUnit.Kilometer, userLoc, LatLng(a.lat, a.lng));
          final dB = dist.as(LengthUnit.Kilometer, userLoc, LatLng(b.lat, b.lng));
          return dA.compareTo(dB);
        });
      if (nearby.isNotEmpty) return nearby;
    }

    return withCoords;
  }

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
            if (_searchQuery.isEmpty) SliverToBoxAdapter(child: _buildNearbySection()),
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
        // City selector button
        GestureDetector(
          onTap: () => _showCitySelector(),
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
                  _selectedCity ?? 'انتخاب شهر',
                  style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
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
                              ? [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
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
                _selectedCity != null ? 'در $_selectedCity' : 'نزدیک شما',
                style: const TextStyle(
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
                  arguments: _userPosition != null
                      ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
                      : null,
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
