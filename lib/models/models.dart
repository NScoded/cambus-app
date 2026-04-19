import 'dart:math';

enum BusStatus { onRoute, atStop, delayed, offDuty }

class BusLocation {
  final double lat;
  final double lng;
  final DateTime timestamp;
  final double speed; // km/h
  final double heading; // degrees

  const BusLocation({
    required this.lat,
    required this.lng,
    required this.timestamp,
    this.speed = 0,
    this.heading = 0,
  });
}

class Bus {
  final String id;
  final String number;
  final String routeId;
  final String driverName;
  final String driverPhone;
  final int capacity;
  final int passengers;
  BusStatus status;
  BusLocation location;
  int etaMinutes;

  Bus({
    required this.id,
    required this.number,
    required this.routeId,
    required this.driverName,
    required this.driverPhone,
    required this.capacity,
    required this.passengers,
    required this.status,
    required this.location,
    required this.etaMinutes,
  });

  double get occupancyPercent => (passengers / capacity) * 100;

  String get statusLabel {
    switch (status) {
      case BusStatus.onRoute: return 'On Route';
      case BusStatus.atStop: return 'At Stop';
      case BusStatus.delayed: return 'Delayed';
      case BusStatus.offDuty: return 'Off Duty';
    }
  }

  String get etaLabel {
    if (status == BusStatus.atStop) return 'Arrived';
    if (etaMinutes <= 0) return 'Arriving';
    if (etaMinutes == 1) return '1 min';
    return '$etaMinutes mins';
  }
}

class RouteStop {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final int scheduledTime; // minutes from route start

  const RouteStop({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.scheduledTime,
  });
}

class BusRoute {
  final String id;
  final String name;
  final String from;
  final String to;
  final List<RouteStop> stops;
  final String startTime;
  final String endTime;
  final int frequency; // minutes between buses
  final String color;

  const BusRoute({
    required this.id,
    required this.name,
    required this.from,
    required this.to,
    required this.stops,
    required this.startTime,
    required this.endTime,
    required this.frequency,
    required this.color,
  });
}

class Alert {
  final String id;
  final String title;
  final String message;
  final AlertType type;
  final DateTime time;
  final String? busId;
  bool isRead;

  Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    this.busId,
    this.isRead = false,
  });
}

enum AlertType { delay, arrival, breakdown, general }
