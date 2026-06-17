import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:latlong2/latlong.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/persian_utils.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/salon_model.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/stylist_model.dart';
import '../../../data/models/review_model.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/storage/data_service.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/service_tile.dart';

class SalonDetailScreen extends StatefulWidget {
  const SalonDetailScreen({super.key});

  @override
  State<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends State<SalonDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SalonModel _salon;
  late List<ServiceModel> _services;
  late List<StylistModel> _stylists;
  late List<ReviewModel> _reviews;
  int _currentImageIndex = 0;
  final _imagePageController = PageController();

  @override
  void initState() {
    super.initState();
    _salon = Get.arguments as SalonModel;
    _services = MockData.getServicesBySalon(_salon.id);
    _stylists = MockData.getStylistsBySalon(_salon.id);
    _reviews = MockData.getReviewsBySalon(_salon.id);
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                onPressed: () => Get.back(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Real images if available, otherwise gradient placeholder
                  if (_salon.images.isNotEmpty)
                    PageView.builder(
                      controller: _imagePageController,
                      itemCount: _salon.images.length,
                      onPageChanged: (i) => setState(() => _currentImageIndex = i),
                      itemBuilder: (_, i) => Image.file(
                        File(_salon.images[i]),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.primary, AppColors.accent],
                            ),
                          ),
                          child: const Icon(Icons.content_cut, color: Colors.white24, size: 100),
                        ),
                      ),
                    )
                  else
                    Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                    ),
                    child: const Icon(Icons.content_cut, color: Colors.white24, size: 100),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  // Dots indicator for image slideshow
                  if (_salon.images.length > 1)
                    Positioned(
                      top: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_salon.images.length, (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _currentImageIndex ? 20 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: i == _currentImageIndex ? AppColors.secondary : Colors.white60,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )),
                      ),
                    ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _salon.name,
                          style: const TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white60, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _salon.address,
                                style: const TextStyle(
                                  fontFamily: 'Vazirmatn',
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            StarRating(
                              rating: _salon.rating,
                              reviewCount: _salon.reviewCount,
                              size: 16,
                            ),
                            const Spacer(),
                            if (_salon.isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, color: Colors.white, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'تأیید شده',
                                      style: TextStyle(
                                        fontFamily: 'Vazirmatn',
                                        fontSize: 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
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
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'خدمات'),
                  Tab(text: 'آرایشگران'),
                  Tab(text: 'نظرات'),
                  Tab(text: 'اطلاعات'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _ServicesTab(services: _services),
            _StylistsTab(stylists: _stylists),
            _ReviewsTab(salonId: _salon.id, reviews: _reviews),
            _InfoTab(salon: _salon),
          ],
        ),
      ),
      floatingActionButton: FadeInUp(
        child: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(Routes.bookingFlow, arguments: _salon),
          backgroundColor: AppColors.secondary,
          icon: const Icon(Icons.calendar_today_rounded, color: Colors.white),
          label: const Text(
            'رزرو نوبت',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

class _ServicesTab extends StatelessWidget {
  final List<ServiceModel> services;

  const _ServicesTab({required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Center(child: Text('خدماتی ثبت نشده', style: TextStyle(fontFamily: 'Vazirmatn')));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: services.length,
      itemBuilder: (_, i) => ServiceTile(service: services[i]),
    );
  }
}

class _StylistsTab extends StatelessWidget {
  final List<StylistModel> stylists;

  const _StylistsTab({required this.stylists});

  @override
  Widget build(BuildContext context) {
    if (stylists.isEmpty) {
      return const Center(child: Text('آرایشگری ثبت نشده', style: TextStyle(fontFamily: 'Vazirmatn')));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stylists.length,
      itemBuilder: (_, i) {
        final s = stylists[i];
        return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      s.name.characters.first,
                      style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: const TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.specialty,
                        style: const TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StarRating(rating: s.rating, showCount: false, size: 14),
                const SizedBox(width: 4),
              ],
            ),
        );
      },
    );
  }
}

class _StylistProfileSheet extends StatelessWidget {
  final StylistModel stylist;
  const _StylistProfileSheet({required this.stylist});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          // Avatar
          Center(
            child: Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  stylist.name.characters.first,
                  style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(child: Text(stylist.name, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
          const SizedBox(height: 4),
          Center(child: Text(stylist.specialty, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: AppColors.textSecondary))),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StarRating(rating: stylist.rating, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium_outlined, color: AppColors.secondary, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('تخصص', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(stylist.specialty, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ],
                )),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.calendar_today_outlined),
              label: const Text('رزرو با این آرایشگر', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsTab extends StatefulWidget {
  final String salonId;
  final List<ReviewModel> reviews;

  const _ReviewsTab({required this.salonId, required this.reviews});

  @override
  State<_ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<_ReviewsTab> {
  late List<ReviewModel> _reviews;
  final _commentCtrl = TextEditingController();
  int _selectedRating = 5;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _reviews = List.from(widget.reviews);
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_commentCtrl.text.trim().isEmpty) return;
    final user = StorageService.getUser();
    final review = ReviewModel(
      id: 'rv_${DateTime.now().millisecondsSinceEpoch}',
      userId: user?.id ?? 'guest',
      userName: user?.fullName ?? 'کاربر مهمان',
      salonId: widget.salonId,
      rating: _selectedRating,
      comment: _commentCtrl.text.trim(),
      createdAt: DateTime.now(),
    );
    MockData.reviews.add(review);
    DataService.saveAll();
    setState(() {
      _reviews = [review, ..._reviews];
      _commentCtrl.clear();
      _selectedRating = 5;
      _showForm = false;
    });
    Get.snackbar('ثبت شد', 'نظر شما با موفقیت ثبت شد', backgroundColor: AppColors.success, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  Widget _buildReviewCard(ReviewModel r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    r.userName.characters.first,
                    style: const TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700, color: AppColors.secondary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.userName, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text(PersianUtils.getTimeAgo(r.createdAt), style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              StarRating(rating: r.rating.toDouble(), showCount: false, size: 14),
            ],
          ),
          const SizedBox(height: 10),
          Text(r.comment, style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: AppColors.textPrimary, height: 1.5)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Review submission form
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _showForm ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _showForm = true),
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('ثبت نظر', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.secondary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          secondChild: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('امتیاز شما:', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) => GestureDetector(
                    onTap: () => setState(() => _selectedRating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        i < _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                  )),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentCtrl,
                  maxLines: 3,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'نظر خود را بنویسید...',
                    hintStyle: const TextStyle(fontFamily: 'Vazirmatn', color: AppColors.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.divider)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.secondary)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitReview,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text('ثبت نظر', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () => setState(() { _showForm = false; _commentCtrl.clear(); }),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('انصراف', style: TextStyle(fontFamily: 'Vazirmatn')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_reviews.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(32),
            child: Text('هنوز نظری ثبت نشده', style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.textSecondary)),
          ))
        else
          ..._reviews.map(_buildReviewCard),
      ],
    );
  }
}

class _InfoTab extends StatelessWidget {
  final SalonModel salon;

  const _InfoTab({required this.salon});

  @override
  Widget build(BuildContext context) {
    final hasLocation = salon.lat != 0.0 && salon.lng != 0.0;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: 'آدرس',
          icon: Icons.location_on_outlined,
          content: salon.address,
        ),
        if (salon.phone != null && salon.phone!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoCard(
            title: 'شماره تلفن',
            icon: Icons.phone_outlined,
            content: salon.phone!,
          ),
        ],
        const SizedBox(height: 12),
        _InfoCard(
          title: 'ساعات کاری',
          icon: Icons.access_time,
          content: '${salon.openTime} الی ${salon.closeTime}',
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'دسته‌بندی',
          icon: Icons.category_outlined,
          content: salon.categoryLabel,
        ),
        const SizedBox(height: 12),
        if (hasLocation)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 220,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(salon.lat, salon.lng),
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.barberbook',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(salon.lat, salon.lng),
                        width: 44,
                        height: 44,
                        child: const Icon(Icons.location_pin, color: Colors.red, size: 44),
                      ),
                    ],
                  ),
                  const RichAttributionWidget(
                    attributions: [TextSourceAttribution('OpenStreetMap')],
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_outlined, color: AppColors.textSecondary, size: 32),
                  SizedBox(height: 6),
                  Text('موقعیت مکانی ثبت نشده', style: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;

  const _InfoCard({required this.title, required this.icon, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.secondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
