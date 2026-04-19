import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

// ── Glowing status dot
class StatusDot extends StatefulWidget {
  final Color color;
  final double size;
  const StatusDot({super.key, required this.color, this.size = 8});

  @override
  State<StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<StatusDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _anim = Tween(begin: 0.0, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.size * 2.5,
    height: widget.size * 2.5,
    child: Stack(alignment: Alignment.center, children: [
      AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Transform.scale(
          scale: 1 + _anim.value,
          child: Container(
            width: widget.size * 2,
            height: widget.size * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(0.3 * (1 - _anim.value)),
            ),
          ),
        ),
      ),
      Container(
        width: widget.size, height: widget.size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color,
          boxShadow: [BoxShadow(color: widget.color.withOpacity(0.6), blurRadius: 6)]),
      ),
    ]),
  );
}

// ── Bus status chip
class StatusChip extends StatelessWidget {
  final BusStatus status;
  const StatusChip({super.key, required this.status});

  Color get _color {
    switch (status) {
      case BusStatus.onRoute: return AppTheme.accentBlue;
      case BusStatus.atStop: return AppTheme.accent;
      case BusStatus.delayed: return AppTheme.accentOrange;
      case BusStatus.offDuty: return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: _color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _color.withOpacity(0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      StatusDot(color: _color, size: 5),
      const SizedBox(width: 6),
      Text(
        status.name.toUpperCase().replaceAll('ONROUTE', 'ON ROUTE').replaceAll('ATSTOP', 'AT STOP').replaceAll('OFFDUTY', 'OFF DUTY'),
        style: AppText.mono(size: 10, color: _color, weight: FontWeight.w700),
      ),
    ]),
  );
}

// ── Occupancy bar
class OccupancyBar extends StatelessWidget {
  final int passengers;
  final int capacity;
  final double height;
  const OccupancyBar({super.key, required this.passengers, required this.capacity, this.height = 6});

  @override
  Widget build(BuildContext context) {
    final pct = passengers / capacity;
    final color = pct > 0.8 ? AppTheme.accentRed : pct > 0.6 ? AppTheme.accentOrange : AppTheme.accent;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Occupancy', style: AppText.mono(size: 10)),
        Text('$passengers/$capacity', style: AppText.mono(size: 10, color: color, weight: FontWeight.w700)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          value: pct,
          minHeight: height,
          backgroundColor: AppTheme.border,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    ]);
  }
}

// ── Glass card
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  const GlassCard({super.key, required this.child, this.padding, this.onTap, this.borderColor});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor ?? AppTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: child,
    ),
  );
}

// ── Section header
class SectionHeader extends StatelessWidget {
  final String label;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.label, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: AppText.display(size: 16)),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(action!, style: AppText.mono(size: 11, color: AppTheme.accent)),
        ),
    ],
  );
}

// ── Shimmer loading card
class ShimmerCard extends StatefulWidget {
  final double height;
  const ShimmerCard({super.key, this.height = 120});
  @override State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment(-1 + 2 * _ctrl.value, 0),
          end: Alignment(1 + 2 * _ctrl.value, 0),
          colors: [AppTheme.surface, AppTheme.surface2, AppTheme.surface],
        ),
      ),
    ),
  );
}
