import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bus_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<BusService>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 28),
            child: Column(children: [
              // Avatar
              Container(
                width: 84, height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.accentBlue]),
                  boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.3), blurRadius: 24)],
                ),
                child: const Center(child: Text('N', style: TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.w800))),
              ),
              const SizedBox(height: 16),
              Text('Nilesh Sahu', style: AppText.display(size: 22)),
              const SizedBox(height: 4),
              Text('College Student · CS Dept', style: AppText.mono(size: 12)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                ),
                child: Text('Student ID: CS2021045', style: AppText.mono(size: 11, color: AppTheme.accent, weight: FontWeight.w700)),
              ),
            ]),
          )),

          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              // Favorite route
              GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Favourite Route', style: AppText.display(size: 14)),
                const SizedBox(height: 12),
                if (service.favoriteRouteId != null)
                  () {
                    final route = service.getRoute(service.favoriteRouteId!);
                    return Row(children: [
                      const Icon(Icons.star_rounded, color: AppTheme.accentOrange, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(route?.name ?? '—', style: AppText.display(size: 15)),
                        Text('${route?.from} → ${route?.to}', style: AppText.mono(size: 11)),
                      ])),
                      GestureDetector(
                        onTap: () => service.setFavoriteRoute(service.favoriteRouteId!),
                        child: const Icon(Icons.close_rounded, color: AppTheme.textMuted, size: 18),
                      ),
                    ]);
                  }()
                else
                  Row(children: [
                    const Icon(Icons.star_border_rounded, color: AppTheme.textMuted, size: 20),
                    const SizedBox(width: 10),
                    Text('No favourite route set. Go to Routes to add one.', style: AppText.body(size: 13)),
                  ]),
              ])),

              const SizedBox(height: 12),

              // Stats
              Row(children: [
                _StatTile(label: 'Buses Tracked', value: '${service.buses.length}', icon: '🚌'),
                const SizedBox(width: 12),
                _StatTile(label: 'Routes Active', value: '${service.routes.length}', icon: '🛣️'),
                const SizedBox(width: 12),
                _StatTile(label: 'Alerts', value: '${service.alerts.length}', icon: '🔔'),
              ]),

              const SizedBox(height: 12),

              // Settings sections
              _SettingsSection(title: 'Notifications', items: [
                _SettingRow(label: 'Bus Arrival Alerts', trailing: _Toggle(value: true, onChanged: (_) {})),
                _SettingRow(label: 'Delay Notifications', trailing: _Toggle(value: true, onChanged: (_) {})),
                _SettingRow(label: 'Route Updates', trailing: _Toggle(value: false, onChanged: (_) {})),
              ]),

              const SizedBox(height: 12),

              _SettingsSection(title: 'Preferences', items: [
                _SettingRow(label: 'Dark Mode', trailing: _Toggle(value: true, onChanged: (_) {})),
                _SettingRow(label: 'Live Map Auto-Refresh', trailing: _Toggle(value: true, onChanged: (_) {})),
              ]),

              const SizedBox(height: 12),

              _SettingsSection(title: 'About', items: [
                _SettingRow(label: 'App Version', trailing: Text('1.0.0', style: AppText.mono(size: 12, color: AppTheme.accent))),
                _SettingRow(label: 'Made by', trailing: Text('Nilesh Sahu', style: AppText.mono(size: 12, color: AppTheme.accent))),
                _SettingRow(label: 'Contact Admin', trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted)),
              ]),

              const SizedBox(height: 100),
            ]),
          )),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value, icon;
  const _StatTile({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
    child: Column(children: [
      Text(icon, style: const TextStyle(fontSize: 24)),
      const SizedBox(height: 6),
      Text(value, style: AppText.display(size: 20, color: AppTheme.accent)),
      const SizedBox(height: 2),
      Text(label, style: AppText.mono(size: 9), textAlign: TextAlign.center),
    ]),
  ));
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _SettingsSection({required this.title, required this.items});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
        child: Text(title.toUpperCase(), style: AppText.mono(size: 10, color: AppTheme.textMuted)),
      ),
      ...items.map((item) => Column(children: [
        const Divider(height: 1, color: AppTheme.border),
        item,
      ])),
    ]),
  );
}

class _SettingRow extends StatelessWidget {
  final String label;
  final Widget trailing;
  const _SettingRow({required this.label, required this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    child: Row(children: [
      Expanded(child: Text(label, style: AppText.body(size: 14, color: AppTheme.textPrimary))),
      trailing,
    ]),
  );
}

class _Toggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.value, required this.onChanged});
  @override State<_Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<_Toggle> {
  late bool _val;
  @override void initState() { super.initState(); _val = widget.value; }
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () { setState(() => _val = !_val); widget.onChanged(_val); },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44, height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _val ? AppTheme.accent.withOpacity(0.2) : AppTheme.bg,
        border: Border.all(color: _val ? AppTheme.accent : AppTheme.border, width: 1.5),
      ),
      child: Align(
        alignment: _val ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Container(
            width: 16, height: 16,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _val ? AppTheme.accent : AppTheme.textMuted,
              boxShadow: _val ? [BoxShadow(color: AppTheme.accent.withOpacity(0.4), blurRadius: 6)] : []),
          ),
        ),
      ),
    ),
  );
}
