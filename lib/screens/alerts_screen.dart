import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bus_service.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

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
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Alerts', style: AppText.display(size: 28)),
                Text('${service.unreadAlerts} unread notifications', style: AppText.mono(size: 12)),
              ])),
              if (service.unreadAlerts > 0)
                GestureDetector(
                  onTap: service.markAllRead,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surface, borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text('Mark all read', style: AppText.mono(size: 11, color: AppTheme.accent)),
                  ),
                ),
            ]),
          )),

          SliverList(
            delegate: SliverChildBuilderDelegate((ctx, i) {
              final alert = service.alerts[i];
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _AlertCard(alert: alert),
              );
            }, childCount: service.alerts.length),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Alert alert;
  const _AlertCard({required this.alert});

  Color get _color {
    switch (alert.type) {
      case AlertType.delay: return AppTheme.accentOrange;
      case AlertType.arrival: return AppTheme.accent;
      case AlertType.breakdown: return AppTheme.accentRed;
      case AlertType.general: return AppTheme.accentBlue;
    }
  }

  IconData get _icon {
    switch (alert.type) {
      case AlertType.delay: return Icons.schedule_rounded;
      case AlertType.arrival: return Icons.directions_bus_rounded;
      case AlertType.breakdown: return Icons.warning_rounded;
      case AlertType.general: return Icons.info_rounded;
    }
  }

  String get _timeAgo {
    final diff = DateTime.now().difference(alert.time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: alert.isRead ? AppTheme.surface : AppTheme.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: alert.isRead ? AppTheme.border : _color.withOpacity(0.25)),
      boxShadow: alert.isRead ? [] : [BoxShadow(color: _color.withOpacity(0.08), blurRadius: 16)],
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: _color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _color.withOpacity(0.3)),
        ),
        child: Icon(_icon, color: _color, size: 20),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(alert.title, style: AppText.display(size: 14))),
          if (!alert.isRead)
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: _color,
                boxShadow: [BoxShadow(color: _color.withOpacity(0.5), blurRadius: 6)]),
            ),
        ]),
        const SizedBox(height: 6),
        Text(alert.message, style: AppText.body(size: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.access_time_rounded, size: 11, color: AppTheme.textMuted),
          const SizedBox(width: 4),
          Text(_timeAgo, style: AppText.mono(size: 10)),
          if (alert.busId != null) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(alert.busId!, style: AppText.mono(size: 9, color: _color, weight: FontWeight.w700)),
            ),
          ],
        ]),
      ])),
    ]),
  );
}
