import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/config/map_config.dart';
import '../../../core/services/neshan_tile_provider.dart';
import '../../../core/services/neshan_service.dart';
import '../../../data/models/salon_model.dart';
import '../../widgets/star_rating.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  LatLng? _userLatLng;
  double _radiusKm = 5.0;
  List<SalonModel> _nearby = [];
  SalonModel? _selected;
  bool _loading = false;
  Timer? _debounce;

  static const _tehran = LatLng(35.7219, 51.3347);

  @override
  void initState() {
    super.initState();
    _tryGetLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _tryGetLocation() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
      _refreshNearby(null);
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final ll = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() => _userLatLng = ll);
      _mapController.move(ll, 13);
      _refreshNearby(ll);
    } catch (_) {
      _refreshNearby(null);
    }
  }

  void _scheduleRefresh() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _refreshNearby(_userLatLng);
    });
  }

  void _refreshNearby(LatLng? center) {
    if (!mounted) return;
    setState(() => _loading = true);
    // Simulate network delay for UX polish
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _nearby = NeshanService.getNearbySalons(center, _radiusKm);
        _loading = false;
      });
    });
  }

  Future<void> _goToMyLocation() async {
    if (_userLatLng != null) {
      _mapController.move(_userLatLng!, 14);
      return;
    }
    await _tryGetLocation();
  }

  Color _markerColor(SalonModel s) {
    switch (s.category) {
      case SalonCategory.male:   return const Color(0xFF1565C0);
      case SalonCategory.female: return const Color(0xFFAD1457);
      case SalonCategory.unisex: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نقشه آرایشگاه‌ها',
            style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 4),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_nearby.length} آرایشگاه',
                  style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _userLatLng ?? _tehran,
                    initialZoom: 12,
                    maxZoom: 18,
                    minZoom: 5,
                    onTap: (_, __) => setState(() => _selected = null),
                    onMapEvent: (event) {
                      if (event is MapEventMoveEnd) _scheduleRefresh();
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: MapConfig.neshanTileUrl,
                      tileProvider: NeshanTileProvider(),
                      userAgentPackageName: 'com.barberbook.app',
                    ),
                    // Radius circle
                    if (_userLatLng != null)
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: _userLatLng!,
                            radius: _radiusKm * 1000,
                            useRadiusInMeter: true,
                            color: AppColors.primary.withOpacity(0.08),
                            borderColor: AppColors.primary.withOpacity(0.4),
                            borderStrokeWidth: 1.5,
                          ),
                        ],
                      ),
                    // Salon markers
                    MarkerLayer(
                      markers: [
                        ..._nearby.map((s) => Marker(
                              point: LatLng(s.lat, s.lng),
                              width: 80,
                              height: 62,
                              child: GestureDetector(
                                onTap: () => setState(() =>
                                    _selected = _selected?.id == s.id ? null : s),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: _selected?.id == s.id ? 46 : 36,
                                      height: _selected?.id == s.id ? 46 : 36,
                                      decoration: BoxDecoration(
                                        color: _markerColor(s),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white,
                                            width: _selected?.id == s.id ? 3 : 2),
                                        boxShadow: [
                                          BoxShadow(
                                              color: _markerColor(s).withOpacity(0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2)),
                                        ],
                                      ),
                                      child: const Icon(Icons.content_cut,
                                          color: Colors.white, size: 18),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black.withOpacity(0.12),
                                              blurRadius: 4),
                                        ],
                                      ),
                                      child: Text(
                                        s.name.split(' ').take(2).join(' '),
                                        style: const TextStyle(
                                            fontFamily: 'Vazirmatn',
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        // User location dot
                        if (_userLatLng != null)
                          Marker(
                            point: _userLatLng!,
                            width: 22,
                            height: 22,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.blue.withOpacity(0.4),
                                      blurRadius: 10,
                                      spreadRadius: 3),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                // My location FAB
                Positioned(
                  top: 12,
                  left: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'my_loc',
                    backgroundColor: Colors.white,
                    elevation: 4,
                    onPressed: _goToMyLocation,
                    child: const Icon(Icons.my_location, color: AppColors.primary),
                  ),
                ),
                // Loading shimmer overlay
                if (_loading)
                  Positioned.fill(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.withOpacity(0.1),
                      highlightColor: Colors.white.withOpacity(0.2),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                // Selected salon bottom sheet
                if (_selected != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _SalonPreviewSheet(
                      salon: _selected!,
                      onClose: () => setState(() => _selected = null),
                      onNavigate: () async {
                        final url = Uri.parse(
                            'https://maps.google.com/?q=${_selected!.lat},${_selected!.lng}');
                        // ignore: deprecated_member_use
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      onDetail: () => Get.toNamed(Routes.salonDetail,
                          arguments: _selected),
                    ),
                  ),
                // Empty state
                if (!_loading && _nearby.isEmpty)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10)
                        ],
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_off_outlined,
                              size: 48, color: AppColors.textSecondary),
                          SizedBox(height: 12),
                          Text(
                            'آرایشگاهی در این محدوده یافت نشد',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Vazirmatn',
                                color: AppColors.textSecondary,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Radius slider panel
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.radar, color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'محدوده جستجو: ${_radiusKm.toStringAsFixed(0)} کیلومتر',
                      style: const TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_nearby.length} آرایشگاه',
                        style: const TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.primary.withOpacity(0.2),
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withOpacity(0.1),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _radiusKm,
                    min: 1,
                    max: 20,
                    divisions: 19,
                    onChanged: (v) {
                      setState(() => _radiusKm = v);
                      _scheduleRefresh();
                    },
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('۱ کم',
                        style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 10,
                            color: AppColors.textSecondary)),
                    Text('۲۰ کیلومتر',
                        style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 10,
                            color: AppColors.textSecondary)),
                  ],
                ),
                // Legend
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendDot(color: const Color(0xFF1565C0), label: 'مردانه'),
                    const SizedBox(width: 16),
                    _LegendDot(color: const Color(0xFFAD1457), label: 'زنانه'),
                    const SizedBox(width: 16),
                    _LegendDot(color: AppColors.primary, label: 'یونیسکس'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 10,
                color: AppColors.textSecondary)),
      ],
    );
  }
}

class _SalonPreviewSheet extends StatelessWidget {
  final SalonModel salon;
  final VoidCallback onClose;
  final VoidCallback onNavigate;
  final VoidCallback onDetail;

  const _SalonPreviewSheet({
    required this.salon,
    required this.onClose,
    required this.onNavigate,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Salon image or icon
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: salon.coverImage != null
                    ? Image.file(
                        File(salon.coverImage!),
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _defaultIcon(),
                      )
                    : _defaultIcon(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      salon.name,
                      style: const TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    StarRating(
                        rating: salon.rating,
                        reviewCount: salon.reviewCount,
                        size: 12),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  salon.address,
                  style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 11,
                      color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: salon.category == SalonCategory.female
                      ? const Color(0xFFAD1457).withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  salon.categoryLabel,
                  style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: salon.category == SalonCategory.female
                          ? const Color(0xFFAD1457)
                          : AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onNavigate,
                  icon: const Icon(Icons.directions, size: 16),
                  label: const Text('مسیریابی',
                      style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onDetail,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('مشاهده',
                      style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _defaultIcon() => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.content_cut, color: AppColors.primary, size: 28),
      );
}
