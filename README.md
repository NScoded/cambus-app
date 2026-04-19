# 🚌 CamBus — College Bus Tracking App

A beautiful, production-grade Flutter app for tracking college buses in real-time.

---

## ✨ Features

| Screen | Features |
|--------|----------|
| 🌟 **Splash** | Animated logo, grid background, loading dots |
| 🏠 **Dashboard** | Live bus cards, stats, quick routes, search bar |
| 🗺️ **Map** | Dark OpenStreetMap, live bus markers, route polylines, stop markers |
| 🛣️ **Routes** | Expandable route cards, stop timeline, favourite routes |
| 🔔 **Alerts** | Delay/arrival/breakdown notifications, mark as read |
| 🚌 **Bus Detail** | ETA, speed, occupancy, driver info, call driver, stop list |
| 👤 **Profile** | Student info, favourite route, notification settings, toggles |

---

## 🚀 Setup & Run

### Prerequisites
- Flutter SDK ≥ 3.10.0
- Android Studio / VS Code
- Android device or emulator

### Steps

```bash
# 1. Clone / extract the project
cd cambus

# 2. Install dependencies
flutter pub get

# 3. Run on connected device
flutter run

# 4. Build APK (release)
flutter build apk --release

# APK will be at:
# build/app/outputs/flutter-apk/app-release.apk
```

---

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── theme/
│   └── app_theme.dart        # Colors, fonts, theme
├── models/
│   └── models.dart           # Bus, Route, Alert models
├── services/
│   └── bus_service.dart      # Data + simulated live updates
├── widgets/
│   └── widgets.dart          # Reusable UI components
└── screens/
    ├── splash_screen.dart    # Animated splash
    ├── home_screen.dart      # Bottom nav shell
    ├── dashboard_screen.dart # Main home
    ├── map_screen.dart       # Live map
    ├── routes_screen.dart    # Route list
    ├── alerts_screen.dart    # Notifications
    ├── bus_detail_screen.dart# Bus info
    └── profile_screen.dart   # User profile
```

---

## 🎨 Design

- **Theme**: Dark, futuristic — `#060A0F` background with `#00F5A0` neon green accent
- **Fonts**: Space Grotesk (display) + JetBrains Mono (code/labels)
- **Map**: CartoDB Dark Matter tiles (no API key needed!)
- **Animations**: Splash animations, scale on press, animated status dots, shimmer loading

---

## 🔧 Real Backend Integration

The app currently uses simulated data in `bus_service.dart`. To connect real GPS:

1. Replace `_initData()` with API calls using `dio`
2. Use `web_socket_channel` for live bus location updates
3. Integrate `geolocator` for student's current location
4. Add Firebase for push notifications

---

Made with ❤️ by Nilesh Sahu
