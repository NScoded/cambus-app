import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard_screen.dart';
import 'map_screen.dart';
import 'routes_screen.dart';
import 'alerts_screen.dart';
import 'profile_screen.dart';
import '../theme/app_theme.dart';
import '../services/bus_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _navCtrl;

  final List<Widget> _screens = const [
    DashboardScreen(), MapScreen(), RoutesScreen(), AlertsScreen(), ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _navCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() { _navCtrl.dispose(); super.dispose(); }

  void _onTabTap(int i) {
    if (i == _currentIndex) return;
    setState(() => _currentIndex = i);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final busService = context.watch<BusService>();
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: const Border(top: BorderSide(color: AppTheme.border)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.dashboard_rounded, label: 'Home', index: 0, current: _currentIndex, onTap: _onTabTap),
                _NavItem(icon: Icons.map_rounded, label: 'Map', index: 1, current: _currentIndex, onTap: _onTabTap),
                _NavItem(icon: Icons.route_rounded, label: 'Routes', index: 2, current: _currentIndex, onTap: _onTabTap),
                _NavItem(icon: Icons.notifications_rounded, label: 'Alerts', index: 3, current: _currentIndex, onTap: _onTabTap, badge: busService.unreadAlerts),
                _NavItem(icon: Icons.person_rounded, label: 'Profile', index: 4, current: _currentIndex, onTap: _onTabTap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current;
  final Function(int) onTap;
  final int badge;

  const _NavItem({required this.icon, required this.label, required this.index, required this.current, required this.onTap, this.badge = 0});

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected ? Border.all(color: AppTheme.accent.withOpacity(0.2)) : null,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(children: [
            Icon(icon, color: selected ? AppTheme.accent : AppTheme.textMuted, size: 22),
            if (badge > 0)
              Positioned(right: -2, top: -2, child: Container(
                width: 14, height: 14,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.accentRed),
                child: Center(child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700))),
              )),
          ]),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: selected ? AppTheme.accent : AppTheme.textMuted, fontSize: 10, fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
        ]),
      ),
    );
  }
}
