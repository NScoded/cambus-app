import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bus_service.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});
  @override State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  String? _expandedRoute;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<BusService>();
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Routes', style: AppText.display(size: 28)),
              const SizedBox(height: 4),
              Text('${service.routes.length} active routes on campus', style: AppText.mono(size: 12)),
            ]),
          )),

          SliverList(
            delegate: SliverChildBuilderDelegate((ctx, i) {
              final route = service.routes[i];
              final buses = service.getBusesOnRoute(route.id);
              final color = _hexToColor(route.color);
              final isExpanded = _expandedRoute == route.id;
              final isFav = service.favoriteRouteId == route.id;

              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: GestureDetector(
                  onTap: () => setState(() => _expandedRoute = isExpanded ? null : route.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isExpanded ? color.withOpacity(0.4) : AppTheme.border),
                      boxShadow: isExpanded ? [BoxShadow(color: color.withOpacity(0.1), blurRadius: 20)] : [],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: color.withOpacity(0.3)),
                              ),
                              child: Center(child: Text('🚌', style: const TextStyle(fontSize: 18))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(route.name, style: AppText.display(size: 16, color: color)),
                              Text('Every ${route.frequency} min · ${route.startTime} – ${route.endTime}', style: AppText.mono(size: 10)),
                            ])),
                            GestureDetector(
                              onTap: () => service.setFavoriteRoute(route.id),
                              child: Icon(isFav ? Icons.star_rounded : Icons.star_border_rounded, color: isFav ? AppTheme.accentOrange : AppTheme.textMuted, size: 20),
                            ),
                            const SizedBox(width: 8),
                            Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: AppTheme.textMuted, size: 20),
                          ]),
                          const SizedBox(height: 14),
                          Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('FROM', style: AppText.mono(size: 9)),
                              const SizedBox(height: 2),
                              Text(route.from, style: AppText.display(size: 13)),
                            ])),
                            const Icon(Icons.arrow_forward_rounded, color: AppTheme.textMuted, size: 16),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text('TO', style: AppText.mono(size: 9)),
                              const SizedBox(height: 2),
                              Text(route.to, style: AppText.display(size: 13), textAlign: TextAlign.end),
                            ])),
                          ]),
                          const SizedBox(height: 12),
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: color.withOpacity(0.2)),
                              ),
                              child: Text('${buses.length} bus${buses.length != 1 ? "es" : ""}', style: AppText.mono(size: 10, color: color, weight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.border)),
                              child: Text('${route.stops.length} stops', style: AppText.mono(size: 10)),
                            ),
                          ]),
                        ]),
                      ),

                      // Expanded: stops list
                      if (isExpanded) ...[
                        Container(height: 1, color: AppTheme.border),
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('STOPS', style: AppText.mono(size: 10, color: color)),
                            const SizedBox(height: 14),
                            ...route.stops.asMap().entries.map((entry) {
                              final i = entry.key;
                              final stop = entry.value;
                              final isLast = i == route.stops.length - 1;
                              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Column(children: [
                                  Container(width: 12, height: 12, decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: i == 0 || isLast ? color : Colors.transparent,
                                    border: Border.all(color: color, width: 2),
                                  )),
                                  if (!isLast) Container(width: 2, height: 36, color: color.withOpacity(0.3)),
                                ]),
                                const SizedBox(width: 14),
                                Expanded(child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(stop.name, style: AppText.display(size: 13)),
                                    Text('+${stop.scheduledTime} min', style: AppText.mono(size: 10)),
                                  ]),
                                )),
                              ]);
                            }),

                            // Active buses on this route
                            if (buses.isNotEmpty) ...[
                              Text('ACTIVE BUSES', style: AppText.mono(size: 10, color: color)),
                              const SizedBox(height: 10),
                              ...buses.map((bus) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(children: [
                                  const Text('🚌', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 10),
                                  Text(bus.number, style: AppText.display(size: 13)),
                                  const Spacer(),
                                  StatusChip(status: bus.status),
                                  const SizedBox(width: 10),
                                  Text('ETA: ${bus.etaLabel}', style: AppText.mono(size: 10, color: AppTheme.accent)),
                                ]),
                              )),
                            ],
                          ]),
                        ),
                      ],
                    ]),
                  ),
                ),
              );
            }, childCount: service.routes.length),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) => Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
}
