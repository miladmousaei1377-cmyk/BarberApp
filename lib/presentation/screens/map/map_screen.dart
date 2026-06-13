import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  void _launchMaps(SalonModel salon) async {
    final url = Uri.parse(
        'https://maps.google.com/?q=${salon.lat},${salon.lng}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
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
          // Map placeholder (flutter_map would be here with real OpenStreetMap)
          Container(
            color: const Color(0xFFE8F4EA),
            child: CustomPaint(
              painter: _MockMapPainter(
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
                    // Grid lines to simulate map
                    ..._buildMapGrid(context),
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
                    // Map attribution
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
                    // Tehran label
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.35,
                      left: MediaQuery.of(context).size.width * 0.3,
                      child: const Text(
                        'تهران',
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
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
    const minLat = 35.65, maxLat = 35.85;
    const minLng = 51.30, maxLng = 51.50;
    final x = (lng - minLng) / (maxLng - minLng) * size.width;
    final y = (1 - (lat - minLat) / (maxLat - minLat)) * (size.height - 200);
    return Offset(x, y);
  }

  SalonModel? _findTappedSalon(
      Offset tap, Size size, List<SalonModel> salons) {
    for (final salon in salons) {
      final pos = _latLngToOffset(salon.lat, salon.lng, size);
      if ((tap - pos).distance < 30) return salon;
    }
    return null;
  }
}

class _MockMapPainter extends CustomPainter {
  final List<SalonModel> salons;
  final SalonModel? selected;

  _MockMapPainter({required this.salons, this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw road-like lines for Tehran
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Simulate major roads
    canvas.drawLine(
      Offset(0, size.height * 0.45),
      Offset(size.width, size.height * 0.45),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.2),
      Offset(size.width * 0.7, size.height * 0.7),
      roadPaint..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_MockMapPainter old) => old.selected?.id != selected?.id;
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
