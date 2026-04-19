import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bus_service.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'bus_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<BusService>();
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(child: Container(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF0D1117), AppTheme.bg],
              ),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(greeting, style: AppText.mono(size: 12, color: AppTheme.textMuted)),
                  const SizedBox(height: 4),
                  Text('Nilesh 👋', style: AppText.display(size: 24)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(children: [
                    StatusDot(color: AppTheme.accent, size: 5),
                    const SizedBox(width: 8),
                    Text('Live', style: AppText.mono(size: 11, color: AppTheme.accent, weight: FontWeight.w700)),
                  ]),
                ),
              ]),
              const SizedBox(height: 20),
              // Search bar
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search, color: AppTheme.textMuted, size: 18),
                  const SizedBox(width: 10),
                  Text('Search routes, stops...', style: AppText.body(size: 13)),
                ]),
              ),
            ]),
          )),

          // Stats row
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              _StatCard(label: 'Active Buses', value: '${service.buses.where((b) => b.status != BusStatus.offDuty).length}', color: AppTheme.accent, icon: Icons.directions_bus_rounded),
              const SizedBox(width: 12),
              _StatCard(label: 'Routes', value: '${service.routes.length}', color: AppTheme.accentBlue, icon: Icons.route_rounded),
              const SizedBox(width: 12),
              _StatCard(label: 'Alerts', value: '${service.unreadAlerts}', color: AppTheme.accentOrange, icon: Icons.notifications_rounded),
            ]),
          )),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // Live buses header
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(label: 'Live Buses', action: 'See All →'),
          )),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Bus cards
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final bus = service.buses[i];
                final route = service.getRoute(bus.routeId);
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _BusCard(bus: bus, route: route),
                );
              },
              childCount: service.buses.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // Quick routes
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(label: 'Quick Routes', action: 'All Routes →'),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(child: SizedBox(
            height: 90,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: service.routes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final r = service.routes[i];
                final isFav = service.favoriteRouteId == r.id;
                return GestureDetector(
                  onTap: () => service.setFavoriteRoute(r.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 160,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isFav ? AppTheme.accent.withOpacity(0.1) : AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isFav ? AppTheme.accent.withOpacity(0.4) : AppTheme.border),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Row(children: [
                        Text(r.name, style: AppText.display(size: 13, color: isFav ? AppTheme.accent : AppTheme.textPrimary)),
                        const Spacer(),
                        if (isFav) const Icon(Icons.star_rounded, color: AppTheme.accent, size: 14),
                      ]),
                      const SizedBox(height: 4),
                      Text('${r.from} → ${r.to}', style: AppText.mono(size: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('Every ${r.frequency} min', style: AppText.mono(size: 9, color: AppTheme.accent)),
                    ]),
                  ),
                );
              },
            ),
          )),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(height: 8),
      Text(value, style: AppText.display(size: 22, color: color)),
      const SizedBox(height: 2),
      Text(label, style: AppText.mono(size: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
    ]),
  ));
}

class _BusCard extends StatefulWidget {
  final Bus bus;
  final BusRoute? route;
  const _BusCard({required this.bus, this.route});
  @override State<_BusCard> createState() => _BusCardState();
}

class _BusCardState extends State<_BusCard> {
  bool _pressed = false;

  Color get _statusColor {
    switch (widget.bus.status) {
      case BusStatus.onRoute: return AppTheme.accentBlue;
      case BusStatus.atStop: return AppTheme.accent;
      case BusStatus.delayed: return AppTheme.accentOrange;
      case BusStatus.offDuty: return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => setState(() => _pressed = true),
    onTapUp: (_) { setState(() => _pressed = false);
      Navigator.push(context, MaterialPageRoute(builder: (_) => BusDetailScreen(bus: widget.bus, route: widget.route)));
    },
    onTapCancel: () => setState(() => _pressed = false),
    child: AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            // Bus icon + number
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _statusColor.withOpacity(0.3)),
              ),
              child: Center(child: Text('🚌', style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.bus.number, style: AppText.display(size: 17)),
              const SizedBox(height: 2),
              Text(widget.route?.name ?? 'Unknown Route', style: AppText.mono(size: 10, color: AppTheme.textMuted)),
            ])),
            StatusChip(status: widget.bus.status),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('FROM', style: AppText.mono(size: 9)),
              const SizedBox(height: 2),
              Text(widget.route?.from ?? '—', style: AppText.display(size: 12)),
            ])),
            const Icon(Icons.arrow_forward_rounded, color: AppTheme.textMuted, size: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('TO', style: AppText.mono(size: 9)),
              const SizedBox(height: 2),
              Text(widget.route?.to ?? '—', style: AppText.display(size: 12), textAlign: TextAlign.end),
            ])),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: OccupancyBar(passengers: widget.bus.passengers, capacity: widget.bus.capacity)),
            const SizedBox(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('ETA', style: AppText.mono(size: 9)),
              Text(widget.bus.etaLabel, style: AppText.display(size: 16, color: _statusColor)),
            ]),
          ]),
          const SizedBox(height: 12),
          // Speed indicator if on route
          if (widget.bus.status == BusStatus.onRoute)
            Row(children: [
              Icon(Icons.speed_rounded, size: 12, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text('${widget.bus.location.speed.toStringAsFixed(0)} km/h', style: AppText.mono(size: 10)),
              const Spacer(),
              Text('Tap for details →', style: AppText.mono(size: 9, color: AppTheme.accent)),
            ]),
        ]),
      ),
    ),
  );
}
