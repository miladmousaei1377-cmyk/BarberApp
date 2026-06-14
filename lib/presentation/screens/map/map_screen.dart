import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/salon_model.dart';
import '../../widgets/star_rating.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  SalonModel? _selectedSalon;
  Position? _userPosition;

  void _launchMaps(SalonModel salon) async {
    final url = Uri.parse('https://maps.google.com/?q=${salon.lat},${salon.lng}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _requestLocationAndShow() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'برای نمایش موقعیت شما، دسترسی به مکان لازم است',
              style: TextStyle(fontFamily: 'Vazirmatn'),
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() => _userPosition = position);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'دریافت موقعیت مکانی ناموفق بود',
              style: TextStyle(fontFamily: 'Vazirmatn'),
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نقشه آرایشگاه‌ها'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Map
          Container(
            color: const Color(0xFFD4E6C3),
            child: CustomPaint(
              painter: _IranMapPainter(
                salons: MockData.salons,
                selected: _selectedSalon,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {
                  final size = context.size!;
                  final tappedSalon = _findTappedSalon(
                    details.localPosition,
                    size,
                    MockData.salons,
                  );
                  setState(() => _selectedSalon = tappedSalon);
                },
                child: Stack(
                  children: [
                    // Grid lines
                    ..._buildMapGrid(context),
                    // Iran label
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.38,
                      left: MediaQuery.of(context).size.width * 0.35,
                      child: const Text(
                        'ایران',
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF7A9E6B),
                        ),
                      ),
                    ),
                    // Salon markers
                    ...MockData.salons.map((salon) {
                      final pos = _latLngToOffset(salon.lat, salon.lng,
                          MediaQuery.of(context).size);
                      return Positioned(
                        left: pos.dx - 20,
                        top: pos.dy - 40,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedSalon =
                              _selectedSalon?.id == salon.id ? null : salon),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: _selectedSalon?.id == salon.id ? 44 : 36,
                                height: _selectedSalon?.id == salon.id ? 44 : 36,
                                decoration: BoxDecoration(
                                  color: _selectedSalon?.id == salon.id
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.content_cut,
                                    color: Colors.white, size: 20),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  salon.name.split(' ').take(2).join(' '),
                                  style: const TextStyle(
                                    fontFamily: 'Vazirmatn',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    // User location marker
                    if (_userPosition != null)
                      Builder(builder: (ctx) {
                        final pos = _latLngToOffset(
                          _userPosition!.latitude,
                          _userPosition!.longitude,
                          MediaQuery.of(ctx).size,
                        );
                        return Positioned(
                          left: pos.dx - 12,
                          top: pos.dy - 12,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.4),
                                  blurRadius: 10,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    // Attribution
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '© OpenStreetMap',
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // My location button
          Positioned(
            top: 16,
            left: 16,
            child: FloatingActionButton.small(
              heroTag: 'my_location',
              backgroundColor: Colors.white,
              onPressed: _requestLocationAndShow,
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
          // My location label
          Positioned(
            top: 16,
            left: 60,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Text(
                'مکان من',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          // Bottom sheet for selected salon
          if (_selectedSalon != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _SalonPreviewSheet(
                salon: _selectedSalon!,
                onClose: () => setState(() => _selectedSalon = null),
                onNavigate: () => _launchMaps(_selectedSalon!),
                onDetail: () =>
                    Get.toNamed(Routes.salonDetail, arguments: _selectedSalon),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildMapGrid(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final widgets = <Widget>[];
    for (int i = 1; i < 8; i++) {
      widgets.add(Positioned(
        top: size.height * i / 8,
        left: 0,
        right: 0,
        child: Container(height: 0.5, color: Colors.grey.withOpacity(0.2)),
      ));
      widgets.add(Positioned(
        left: size.width * i / 8,
        top: 0,
        bottom: 0,
        child: Container(width: 0.5, color: Colors.grey.withOpacity(0.2)),
      ));
    }
    return widgets;
  }

  Offset _latLngToOffset(double lat, double lng, Size size) {
    // Map bounds for Iran
    const minLat = 25.0, maxLat = 40.0;
    const minLng = 44.0, maxLng = 64.0;
    final x = (lng - minLng) / (maxLng - minLng) * size.width;
    final y = (1 - (lat - minLat) / (maxLat - minLat)) * (size.height - 200);
    return Offset(x, y);
  }

  SalonModel? _findTappedSalon(Offset tap, Size size, List<SalonModel> salons) {
    for (final salon in salons) {
      final pos = _latLngToOffset(salon.lat, salon.lng, size);
      if ((tap - pos).distance < 30) return salon;
    }
    return null;
  }
}

class _IranMapPainter extends CustomPainter {
  final List<SalonModel> salons;
  final SalonModel? selected;

  _IranMapPainter({required this.salons, this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw stylized Iran shape using bezier paths
    final landPaint = Paint()
      ..color = const Color(0xFFC8DEB8)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF8EAF7E)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final minorRoadPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Approximate Iran outline as a polygon (simplified)
    final iranPath = Path();
    // Normalized coordinates for Iran shape (approximate)
    final points = [
      Offset(size.width * 0.12, size.height * 0.18), // NW corner
      Offset(size.width * 0.28, size.height * 0.08), // North
      Offset(size.width * 0.45, size.height * 0.05), // North-center
      Offset(size.width * 0.60, size.height * 0.10), // NE area
      Offset(size.width * 0.72, size.height * 0.20), // East
      Offset(size.width * 0.85, size.height * 0.25), // SE-East
      Offset(size.width * 0.88, size.height * 0.45), // SE
      Offset(size.width * 0.82, size.height * 0.62), // South-East
      Offset(size.width * 0.70, size.height * 0.72), // South
      Offset(size.width * 0.55, size.height * 0.78), // South-center
      Offset(size.width * 0.40, size.height * 0.80), // South-SW
      Offset(size.width * 0.25, size.height * 0.72), // SW
      Offset(size.width * 0.15, size.height * 0.55), // West
      Offset(size.width * 0.08, size.height * 0.38), // NW-W
      Offset(size.width * 0.12, size.height * 0.18), // back to start
    ];

    iranPath.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      iranPath.lineTo(points[i].dx, points[i].dy);
    }
    iranPath.close();

    canvas.drawPath(iranPath, landPaint);
    canvas.drawPath(iranPath, borderPaint);

    // Major roads
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.35),
      Offset(size.width * 0.70, size.height * 0.40),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.15),
      Offset(size.width * 0.48, size.height * 0.72),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.20, size.height * 0.55),
      Offset(size.width * 0.75, size.height * 0.62),
      minorRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.30, size.height * 0.22),
      Offset(size.width * 0.55, size.height * 0.58),
      minorRoadPaint,
    );
  }

  @override
  bool shouldRepaint(_IranMapPainter old) => old.selected?.id != selected?.id;
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.content_cut, color: AppColors.primary, size: 28),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    StarRating(rating: salon.rating, reviewCount: salon.reviewCount, size: 13),
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
              const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 14),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onNavigate,
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('مسیریابی', style: TextStyle(fontFamily: 'Vazirmatn')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onDetail,
                  child: const Text('مشاهده', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
