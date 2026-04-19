import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class BusDetailScreen extends StatelessWidget {
  final Bus bus;
  final BusRoute? route;
  const BusDetailScreen({super.key, required this.bus, this.route});

  Color get _statusColor {
    switch (bus.status) {
      case BusStatus.onRoute: return AppTheme.accentBlue;
      case BusStatus.atStop: return AppTheme.accent;
      case BusStatus.delayed: return AppTheme.accentOrange;
      case BusStatus.offDuty: return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero header
          SliverToBoxAdapter(child: Container(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [_statusColor.withOpacity(0.1), AppTheme.surface],
              ),
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.border)),
                    child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 18),
                  ),
                ),
                const SizedBox(width: 14),
                Text('Bus Details', style: AppText.display(size: 18)),
              ]),
              const SizedBox(height: 24),
              Row(children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor.withOpacity(0.4), width: 1.5),
                    boxShadow: [BoxShadow(color: _statusColor.withOpacity(0.2), blurRadius: 20)],
                  ),
                  child: const Center(child: Text('🚌', style: TextStyle(fontSize: 34))),
                ),
                const SizedBox(width: 18),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(bus.number, style: AppText.display(size: 28, color: _statusColor)),
                  const SizedBox(height: 4),
                  Text(route?.name ?? 'Unknown Route', style: AppText.mono(size: 12)),
                  const SizedBox(height: 8),
                  StatusChip(status: bus.status),
                ])),
              ]),
            ]),
          )),

          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              // ETA + Speed row
              Row(children: [
                _InfoBox(label: 'ETA', value: bus.etaLabel, color: _statusColor, icon: Icons.access_time_rounded),
                const SizedBox(width: 12),
                _InfoBox(label: 'Speed', value: '${bus.location.speed.toStringAsFixed(0)} km/h', color: AppTheme.accentBlue, icon: Icons.speed_rounded),
                const SizedBox(width: 12),
                _InfoBox(label: 'Free Seats', value: '${bus.capacity - bus.passengers}', color: AppTheme.accent, icon: Icons.event_seat_rounded),
              ]),

              const SizedBox(height: 16),

              // Occupancy card
              GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Passenger Occupancy', style: AppText.display(size: 14)),
                const SizedBox(height: 16),
                OccupancyBar(passengers: bus.passengers, capacity: bus.capacity, height: 10),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${bus.passengers} passengers', style: AppText.mono(size: 11)),
                  Text('Capacity: ${bus.capacity}', style: AppText.mono(size: 11)),
                ]),
              ])),

              const SizedBox(height: 12),

              // Route stops
              if (route != null) GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SectionHeader(label: 'Route Stops'),
                const SizedBox(height: 16),
                ...route!.stops.asMap().entries.map((entry) {
                  final i = entry.key;
                  final stop = entry.value;
                  final isLast = i == route!.stops.length - 1;
                  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Column(children: [
                      Container(width: 14, height: 14, decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 0 ? _statusColor : isLast ? _statusColor : Colors.transparent,
                        border: Border.all(color: _statusColor.withOpacity(0.6), width: 2),
                      )),
                      if (!isLast) Container(width: 2, height: 40, color: _statusColor.withOpacity(0.2)),
                    ]),
                    const SizedBox(width: 14),
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(stop.name, style: AppText.display(size: 13)),
                        const SizedBox(height: 2),
                        Text('+${stop.scheduledTime} min from start', style: AppText.mono(size: 10)),
                      ]),
                    )),
                  ]);
                }),
              ])),

              const SizedBox(height: 12),

              // Driver info
              GlassCard(child: Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentBlue.withOpacity(0.1),
                    border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.person_rounded, color: AppTheme.accentBlue, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Driver', style: AppText.mono(size: 10)),
                  const SizedBox(height: 2),
                  Text(bus.driverName, style: AppText.display(size: 15)),
                  Text(bus.driverPhone, style: AppText.mono(size: 11, color: AppTheme.accentBlue)),
                ])),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Calling ${bus.driverName}...', style: AppText.mono(size: 12, color: AppTheme.textPrimary)),
                      backgroundColor: AppTheme.surface,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: AppTheme.accent.withOpacity(0.3))),
                    child: const Icon(Icons.call_rounded, color: AppTheme.accent, size: 18),
                  ),
                ),
              ])),

              const SizedBox(height: 12),

              // Location info
              GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Current Location', style: AppText.display(size: 14)),
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.location_on_rounded, color: AppTheme.accentRed, size: 16),
                  const SizedBox(width: 8),
                  Text('${bus.location.lat.toStringAsFixed(4)}, ${bus.location.lng.toStringAsFixed(4)}', style: AppText.mono(size: 12, color: AppTheme.textPrimary)),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.update_rounded, size: 14, color: AppTheme.textMuted),
                  const SizedBox(width: 8),
                  Text('Last updated just now', style: AppText.mono(size: 10)),
                ]),
              ])),
            ]),
          )),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _InfoBox({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.07),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(height: 8),
      Text(value, style: AppText.display(size: 16, color: color)),
      const SizedBox(height: 2),
      Text(label, style: AppText.mono(size: 9)),
    ]),
  ));
}
