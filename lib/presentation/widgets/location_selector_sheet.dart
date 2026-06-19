import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../data/mock/iran_locations.dart';

Future<List<String>?> showLocationSelector(
  BuildContext context, {
  required List<String> initialSelected,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => LocationSelectorSheet(initialSelected: initialSelected),
  );
}

class LocationSelectorSheet extends StatefulWidget {
  final List<String> initialSelected;

  const LocationSelectorSheet({super.key, required this.initialSelected});

  @override
  State<LocationSelectorSheet> createState() => _LocationSelectorSheetState();
}

class _LocationSelectorSheetState extends State<LocationSelectorSheet> {
  late List<String> _selected;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initialSelected);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<IranProvince> get _filteredProvinces {
    if (_searchQuery.isEmpty) return iranProvinces;
    final q = _searchQuery;
    return iranProvinces
        .map((p) {
          if (p.name.contains(q)) return p;
          final matchedCities = p.cities.where((c) => c.contains(q)).toList();
          if (matchedCities.isEmpty) return null;
          return IranProvince(name: p.name, cities: matchedCities);
        })
        .whereType<IranProvince>()
        .toList();
  }

  bool _isProvinceFullySelected(IranProvince p) =>
      p.cities.every((c) => _selected.contains(c));

  bool _isProvincePartiallySelected(IranProvince p) =>
      !_isProvinceFullySelected(p) && p.cities.any((c) => _selected.contains(c));

  void _toggleProvince(IranProvince p) {
    setState(() {
      if (_isProvinceFullySelected(p)) {
        _selected.removeWhere((c) => p.cities.contains(c));
      } else {
        for (final c in p.cities) {
          if (!_selected.contains(c)) _selected.add(c);
        }
      }
    });
  }

  void _toggleCity(String city) {
    setState(() {
      if (_selected.contains(city)) {
        _selected.remove(city);
      } else {
        _selected.add(city);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.location_city_rounded,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'انتخاب شهر',
                    style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: _searchController,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'جستجو در استان و شهر...',
                  hintStyle: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      color: AppColors.textSecondary,
                      fontSize: 13),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.textSecondary, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
              ),
            ),
            const Divider(height: 1),
            // Province list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filteredProvinces.length,
                itemBuilder: (_, i) {
                  final prov = _filteredProvinces[i];
                  final allSelected = _isProvinceFullySelected(prov);
                  final partial = _isProvincePartiallySelected(prov);
                  return ExpansionTile(
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    childrenPadding: EdgeInsets.zero,
                    title: Text(
                      prov.name,
                      style: const TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                    leading: Checkbox(
                      tristate: true,
                      value: allSelected
                          ? true
                          : partial
                              ? null
                              : false,
                      activeColor: AppColors.primary,
                      onChanged: (_) => _toggleProvince(prov),
                    ),
                    initiallyExpanded: _searchQuery.isNotEmpty,
                    children: prov.cities
                        .map(
                          (city) => CheckboxListTile(
                            dense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 32),
                            title: Text(
                              city,
                              style: TextStyle(
                                  fontFamily: 'Vazirmatn',
                                  fontSize: 13,
                                  color: _selected.contains(city)
                                      ? AppColors.primary
                                      : AppColors.textPrimary),
                            ),
                            value: _selected.contains(city),
                            activeColor: AppColors.primary,
                            onChanged: (_) => _toggleCity(city),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            // Bottom bar
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _selected.clear()),
                      child: const Text(
                        'پاک کردن همه',
                        style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 13,
                            color: AppColors.textSecondary),
                      ),
                    ),
                    const Spacer(),
                    if (_selected.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_selected.length} شهر',
                          style: const TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, _selected),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'تأیید',
                        style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontWeight: FontWeight.w700,
                            fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
