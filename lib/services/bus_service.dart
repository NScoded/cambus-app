import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';

class BusService extends ChangeNotifier {
  final _random = Random();
  Timer? _updateTimer;

  // Simulated college location (Lucknow area)
  static const double collegeLat = 26.8467;
  static const double collegeLng = 80.9462;

  List<Bus> _buses = [];
  List<BusRoute> _routes = [];
  List<Alert> _alerts = [];
  Bus? _trackedBus;
  String? _favoriteRouteId;
  bool _isLoading = true;

  List<Bus> get buses => _buses;
  List<BusRoute> get routes => _routes;
  List<Alert> get alerts => _alerts;
  Bus? get trackedBus => _trackedBus;
  String? get favoriteRouteId => _favoriteRouteId;
  bool get isLoading => _isLoading;
  int get unreadAlerts => _alerts.where((a) => !a.isRead).length;

  BusService() {
    _initData();
    _startSimulation();
  }

  void _initData() {
    _routes = [
      const BusRoute(
        id: 'r1', name: 'Route A', from: 'Main Gate', to: 'City Centre',
        startTime: '07:30', endTime: '20:00', frequency: 20, color: '#00F5A0',
        stops: [
          RouteStop(id: 's1', name: 'Main Gate', lat: 26.8467, lng: 80.9462, scheduledTime: 0),
          RouteStop(id: 's2', name: 'Library Block', lat: 26.8480, lng: 80.9490, scheduledTime: 5),
          RouteStop(id: 's3', name: 'Hostel Zone', lat: 26.8495, lng: 80.9520, scheduledTime: 10),
          RouteStop(id: 's4', name: 'Sports Complex', lat: 26.8510, lng: 80.9545, scheduledTime: 15),
          RouteStop(id: 's5', name: 'City Centre', lat: 26.8540, lng: 80.9580, scheduledTime: 22),
        ],
      ),
      const BusRoute(
        id: 'r2', name: 'Route B', from: 'Gate 2', to: 'Railway Station',
        startTime: '06:00', endTime: '22:00', frequency: 30, color: '#00D9F5',
        stops: [
          RouteStop(id: 's6', name: 'Gate 2', lat: 26.8450, lng: 80.9440, scheduledTime: 0),
          RouteStop(id: 's7', name: 'Admin Block', lat: 26.8460, lng: 80.9430, scheduledTime: 4),
          RouteStop(id: 's8', name: 'Medical Centre', lat: 26.8445, lng: 80.9410, scheduledTime: 9),
          RouteStop(id: 's9', name: 'Market Chowk', lat: 26.8430, lng: 80.9390, scheduledTime: 15),
          RouteStop(id: 's10', name: 'Railway Station', lat: 26.8400, lng: 80.9350, scheduledTime: 25),
        ],
      ),
      const BusRoute(
        id: 'r3', name: 'Route C', from: 'Campus', to: 'Airport',
        startTime: '05:00', endTime: '23:00', frequency: 45, color: '#FFB830',
        stops: [
          RouteStop(id: 's11', name: 'Campus Square', lat: 26.8467, lng: 80.9462, scheduledTime: 0),
          RouteStop(id: 's12', name: 'Ring Road', lat: 26.8520, lng: 80.9600, scheduledTime: 12),
          RouteStop(id: 's13', name: 'Gomti Nagar', lat: 26.8580, lng: 80.9700, scheduledTime: 22),
          RouteStop(id: 's14', name: 'Airport', lat: 26.8700, lng: 80.9900, scheduledTime: 40),
        ],
      ),
      const BusRoute(
        id: 'r4', name: 'Route D', from: 'Boys Hostel', to: 'Girls Hostel',
        startTime: '08:00', endTime: '18:00', frequency: 15, color: '#FF4757',
        stops: [
          RouteStop(id: 's15', name: 'Boys Hostel', lat: 26.8460, lng: 80.9470, scheduledTime: 0),
          RouteStop(id: 's16', name: 'Canteen', lat: 26.8465, lng: 80.9480, scheduledTime: 3),
          RouteStop(id: 's17', name: 'Academic Block', lat: 26.8470, lng: 80.9490, scheduledTime: 6),
          RouteStop(id: 's18', name: 'Girls Hostel', lat: 26.8475, lng: 80.9500, scheduledTime: 10),
        ],
      ),
    ];

    _buses = [
      Bus(id: 'b1', number: 'CB-01', routeId: 'r1', driverName: 'Ramesh Kumar', driverPhone: '+91 98765 43210', capacity: 50, passengers: 32, status: BusStatus.onRoute, etaMinutes: 4,
        location: BusLocation(lat: 26.8480, lng: 80.9490, timestamp: DateTime.now(), speed: 28, heading: 45)),
      Bus(id: 'b2', number: 'CB-02', routeId: 'r2', driverName: 'Suresh Singh', driverPhone: '+91 87654 32109', capacity: 40, passengers: 18, status: BusStatus.atStop, etaMinutes: 0,
        location: BusLocation(lat: 26.8445, lng: 80.9410, timestamp: DateTime.now(), speed: 0, heading: 0)),
      Bus(id: 'b3', number: 'CB-03', routeId: 'r3', driverName: 'Mahesh Yadav', driverPhone: '+91 76543 21098', capacity: 50, passengers: 45, status: BusStatus.onRoute, etaMinutes: 11,
        location: BusLocation(lat: 26.8550, lng: 80.9650, timestamp: DateTime.now(), speed: 35, heading: 60)),
      Bus(id: 'b4', number: 'CB-04', routeId: 'r4', driverName: 'Dinesh Patel', driverPhone: '+91 65432 10987', capacity: 30, passengers: 12, status: BusStatus.delayed, etaMinutes: 18,
        location: BusLocation(lat: 26.8462, lng: 80.9475, timestamp: DateTime.now(), speed: 0, heading: 90)),
      Bus(id: 'b5', number: 'CB-05', routeId: 'r1', driverName: 'Ganesh Tiwari', driverPhone: '+91 54321 09876', capacity: 50, passengers: 38, status: BusStatus.onRoute, etaMinutes: 7,
        location: BusLocation(lat: 26.8490, lng: 80.9510, timestamp: DateTime.now(), speed: 22, heading: 30)),
    ];

    _alerts = [
      Alert(id: 'a1', title: 'CB-04 Delayed', message: 'Bus CB-04 on Route D is delayed by 8 minutes due to traffic near Market Chowk.', type: AlertType.delay, time: DateTime.now().subtract(const Duration(minutes: 5)), busId: 'b4'),
      Alert(id: 'a2', title: 'CB-02 Arrived', message: 'Bus CB-02 has arrived at Medical Centre stop. Board quickly!', type: AlertType.arrival, time: DateTime.now().subtract(const Duration(minutes: 12)), busId: 'b2', isRead: true),
      Alert(id: 'a3', title: 'Route A Update', message: 'Extra bus CB-01 added to Route A for today\'s evening shift due to high demand.', type: AlertType.general, time: DateTime.now().subtract(const Duration(hours: 1))),
      Alert(id: 'a4', title: 'CB-03 Breakdown', message: 'CB-03 had a minor issue. Resolved now, back on route with 5 min delay.', type: AlertType.breakdown, time: DateTime.now().subtract(const Duration(hours: 2)), busId: 'b3', isRead: true),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void _startSimulation() {
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _simulateBusMovement();
    });
  }

  void _simulateBusMovement() {
    for (var bus in _buses) {
      if (bus.status == BusStatus.onRoute) {
        final newLat = bus.location.lat + (_random.nextDouble() - 0.5) * 0.0008;
        final newLng = bus.location.lng + (_random.nextDouble() - 0.3) * 0.0008;
        bus.location = BusLocation(
          lat: newLat, lng: newLng,
          timestamp: DateTime.now(),
          speed: 20 + _random.nextDouble() * 20,
          heading: bus.location.heading + (_random.nextDouble() - 0.5) * 10,
        );
        if (bus.etaMinutes > 0) {
          bus.etaMinutes = max(0, bus.etaMinutes - (_random.nextBool() ? 1 : 0));
        }
      }
    }
    notifyListeners();
  }

  void trackBus(Bus bus) {
    _trackedBus = bus;
    notifyListeners();
  }

  void setFavoriteRoute(String routeId) {
    _favoriteRouteId = _favoriteRouteId == routeId ? null : routeId;
    notifyListeners();
  }

  void markAllRead() {
    for (var a in _alerts) { a.isRead = true; }
    notifyListeners();
  }

  BusRoute? getRoute(String routeId) => _routes.firstWhere((r) => r.id == routeId, orElse: () => _routes.first);

  List<Bus> getBusesOnRoute(String routeId) => _buses.where((b) => b.routeId == routeId).toList();

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}
