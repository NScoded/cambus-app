import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/bus_service.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  String? _selectedBusId;
  bool _followBus = false;

  static const _collegeCenter = LatLng(26.8467, 80.9462);

  @override
  Widget build(BuildContext context) {
    final service = context.watch<BusService>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(children: [
        // Map
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _collegeCenter,
            initialZoom: 14.5,
            backgroundColor: AppTheme.bg,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.cambus.app',
            ),
            // Route polylines
            PolylineLayer(
              polylines: service.routes.map((route) => Polyline(
                points: route.stops.map((s) => LatLng(s.lat, s.lng)).toList(),
                strokeWidth: 2.5,
                color: _hexToColor(route.color).withOpacity(0.5),
              )).toList(),
            ),
            // Stop markers
            MarkerLayer(
              markers: service.routes.expand((route) => route.stops.map((stop) => Marker(
                point: LatLng(stop.lat, stop.lng),
                width: 12, height: 12,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.bg,
                    border: Border.all(color: _hexToColor(route.color), width: 2),
                  ),
                ),
              ))).toList(),
            ),
            // Bus markers
            MarkerLayer(
              markers: service.buses.map((bus) {
                final isSelected = bus.id == _selectedBusId;
                final color = bus.status == BusStatus.delayed ? AppTheme.accentOrange
                    : bus.status == BusStatus.atStop ? AppTheme.accent
                    : AppTheme.accentBlue;
                return Marker(
                  point: LatLng(bus.location.lat, bus.location.lng),
                  width: isSelected ? 56 : 44,
                  height: isSelected ? 56 : 44,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedBusId = _selectedBusId == bus.id ? null : bus.id;
                      });
                      if (_selectedBusId != null) {
                        _mapController.move(LatLng(bus.location.lat, bus.location.lng), 15.5);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.15),
                        border: Border.all(color: color, width: isSelected ? 2.5 : 1.5),
                        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: isSelected ? 20 : 10)],
                      ),
                      child: const Center(child: Text('🚌', style: TextStyle(fontSize: 20))),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // Top header
        Positioned(top: 0, left: 0, right: 0, child: Container(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [AppTheme.bg, AppTheme.bg.withOpacity(0)],
            ),
          ),
          child: Row(children: [
            Text('Live Map', style: AppText.display(size: 22)),
            const Spacer(),
            // Bus filter chips
            ...service.buses.take(3).map((bus) {
              final isSelected = _selectedBusId == bus.id;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedBusId = isSelected ? null : bus.id);
                  if (!isSelected) _mapController.move(LatLng(bus.location.lat, bus.location.lng), 15.5);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accent.withOpacity(0.15) : AppTheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? AppTheme.accent : AppTheme.border),
                  ),
                  child: Text(bus.number, style: AppText.mono(size: 10, color: isSelected ? AppTheme.accent : AppTheme.textMuted, weight: FontWeight.w700)),
                ),
              );
            }),
          ]),
        )),

        // Center button
        Positioned(right: 16, bottom: 200, child: GestureDetector(
          onTap: () => _mapController.move(_collegeCenter, 14.5),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surface, shape: BoxShape.circle,
              border: Border.all(color: AppTheme.border),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
            ),
            child: const Icon(Icons.my_location_rounded, color: AppTheme.accent, size: 20),
          ),
        )),

        // Selected bus info card
        if (_selectedBusId != null)
          Positioned(bottom: 90, left: 16, right: 16, child: _SelectedBusCard(
            bus: service.buses.firstWhere((b) => b.id == _selectedBusId!),
            route: service.getRoute(service.buses.firstWhere((b) => b.id == _selectedBusId!).routeId),
            onClose: () => setState(() => _selectedBusId = null),
          )),

        // Bus count bottom strip
        if (_selectedBusId == null)
          Positioned(bottom: 90, left: 16, right: 16, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(children: [
              const Text('🚌', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Expanded(child: Text(
                '${service.buses.where((b) => b.status == BusStatus.onRoute).length} buses on route · ${service.buses.where((b) => b.status == BusStatus.atStop).length} at stops',
                style: AppText.mono(size: 11),
              )),
              StatusDot(color: AppTheme.accent, size: 5),
            ]),
          )),
      ]),
    );
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
  }
}

class _SelectedBusCard extends StatelessWidget {
  final Bus bus;
  final BusRoute? route;
  final VoidCallback onClose;
  const _SelectedBusCard({required this.bus, this.route, required this.onClose});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.1), blurRadius: 20)],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        const Text('🚌', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(bus.number, style: AppText.display(size: 16)),
          Text(route?.name ?? '—', style: AppText.mono(size: 10)),
        ])),
        StatusChip(status: bus.status),
        const SizedBox(width: 8),
        GestureDetector(onTap: onClose, child: const Icon(Icons.close_rounded, color: AppTheme.textMuted, size: 18)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        _InfoChip(label: 'ETA', value: bus.etaLabel),
        const SizedBox(width: 10),
        _InfoChip(label: 'Speed', value: '${bus.location.speed.toStringAsFixed(0)} km/h'),
        const SizedBox(width: 10),
        _InfoChip(label: 'Seats', value: '${bus.capacity - bus.passengers} free'),
      ]),
    ]),
  );
}

class _InfoChip extends StatelessWidget {
  final String label, value;
  const _InfoChip({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.border)),
    child: Column(children: [
      Text(label, style: AppText.mono(size: 9)),
      const SizedBox(height: 3),
      Text(value, style: AppText.display(size: 13, color: AppTheme.accent)),
    ]),
  ));
}
