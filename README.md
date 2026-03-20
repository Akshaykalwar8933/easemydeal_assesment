# 🎬 Reels App — Flutter

A production-grade Instagram/TikTok-style short video reels app built with **Flutter**, **Firebase Firestore**, **GetX** state management, and **Clean Architecture** following **SOLID principles**.

---

## 📱 Demo

> Scroll through short videos fetched from Firebase Firestore, with seamless preloading, video caching, like toggle, and error handling.

---

## ✨ Features

- 🎥 **Vertical scroll** through short video reels (like Instagram/TikTok)
- ☁️ **Firebase Firestore** — fetch video metadata (URL, username, likes, caption)
- ⚡ **Preload 3–4 videos ahead** for seamless playback
- 💾 **Video caching** via `flutter_cache_manager` — no re-downloading
- ▶️ **Auto-play / pause** based on scroll position
- 🔇 **Audio bleed prevention** — previous video muted immediately on scroll
- 🔒 **Scroll lock** — user cannot scroll until current video is ready
- ❤️ **Like toggle** with optimistic update + Firestore sync
- 📵 **Error handling** — 403, 404, network errors shown with retry button
- ♻️ **Memory management** — disposes controllers far from current index
- 📱 **iOS & Android** supported

---

## 🏗️ Architecture

This project follows **Clean Architecture** with strict layer separation. Dependencies point inward only.

```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── errors/
│   │   └── failures.dart
│   └── di/
│       └── injection.dart
├── data/
│   ├── datasources/
│   │   └── reel_remote_datasource.dart
│   ├── models/
│   │   └── reel_model.dart
│   └── repositories/
│       └── reel_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── reel_entity.dart
│   ├── repositories/
│   │   └── reel_repository.dart
│   └── usecases/
│       └── get_reels_usecase.dart
└── presentation/
    ├── controllers/
    │   └── reel_controller.dart
    ├── screens/
    │   └── reels_screen.dart
    └── widgets/
        ├── reel_page_item.dart
        ├── reel_video_player.dart
        └── reel_overlay.dart
```

---

## 🧱 SOLID Principles Applied

| Principle | Where |
|---|---|
| **S** — Single Responsibility | `GetReelsUseCase` only fetches. `ReelController` only manages UI state. `ReelRemoteDataSource` only talks to Firestore. |
| **O** — Open/Closed | New use cases added in new files without modifying existing ones. |
| **L** — Liskov Substitution | `ReelRepositoryImpl` fully satisfies `ReelRepository` contract anywhere. |
| **I** — Interface Segregation | `ReelRemoteDataSource` has only 2 focused methods — no bloated interfaces. |
| **D** — Dependency Inversion | `ReelController` depends on `GetReelsUseCase` abstraction, not concrete Firestore calls. |

---

## 🛠️ Tech Stack

| Package | Purpose |
|---|---|
| `get: ^4.6.6` | State management, navigation, dependency injection |
| `firebase_core` | Firebase initialization |
| `cloud_firestore` | Video metadata storage |
| `firebase_storage` | Video file storage |
| `video_player: ^2.8.x` | Native video playback |
| `flutter_cache_manager: ^3.x` | Video file caching |
| `cached_network_image: ^3.x` | Thumbnail caching |
| `path_provider: ^2.x` | Local file paths |

---

## 🔥 Firestore Collection Structure

Collection name: **`reels`**

| Field | Type | Example |
|---|---|---|
| `videoUrl` | String | `https://storage.googleapis.com/.../video.mp4` |
| `thumbnailUrl` | String | `https://storage.googleapis.com/.../thumb.jpg` |
| `username` | String | `@akshay` |
| `caption` | String | `Check this out! #viral` |
| `likes` | Number | `1024` |
| `isLiked` | Boolean | `false` |
| `createdAt` | Timestamp | Firebase Server Timestamp |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Firebase project (already connected)
- Android Studio / Xcode

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/your-username/reels-app.git
cd reels-app
```

**2. Install dependencies**

```bash
flutter pub get
```

**3. Firebase setup**

Your project is already connected to Firebase. Just make sure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are in their correct locations:

```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

**4. iOS setup**

```bash
cd ios
pod install
cd ..
```

**5. Run the app**

```bash
flutter run
```

---

## ⚙️ iOS Configuration

Add the following to `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
<key>NSMicrophoneUsageDescription</key>
<string>Required for video playback.</string>
<key>NSCameraUsageDescription</key>
<string>Required for video playback.</string>
```

Add the following to `ios/Runner/AppDelegate.swift`:

```swift
import AVFoundation

// Inside didFinishLaunchingWithOptions:
try? AVAudioSession.sharedInstance().setCategory(
    .playback, mode: .moviePlayback, options: []
)
try? AVAudioSession.sharedInstance().setActive(true)
```

---

## ⚙️ Android Configuration

Add the following to `android/app/src/main/AndroidManifest.xml` inside `<application>`:

```xml
android:usesCleartextTraffic="true"
```

---

## 📐 How Video Preloading Works

```
Current index: 3

[ 1 ]  disposed (too far back)
[ 2 ]  kept in memory, paused, muted
[ 3 ]  ▶ playing  ← current
[ 4 ]  preloaded, paused,
[ 5 ]  not loaded yet
```

- Scroll is **locked** until the current video's controller is initialized
- Previous video is **muted immediately** on page change to prevent audio bleed
- Controllers **beyond range** are disposed to free memory
- Videos are **cached locally** so re-visiting a reel plays instantly

---

## 🐛 Error Handling

| Error | Shown To User |
|---|---|
| HTTP 403 | "Access denied (403)." |
| HTTP 404 | "Video not found (404)." |
| HTTP 500 | "Server error (500)." |
| No internet | "No internet connection." |
| Invalid URL | "Invalid video URL." |
| ExoPlayer / format error | "Video format not supported." |

All errors show a **Tap to retry** button. Tapping clears the error, resets retry count, disposes the broken controller, and re-initializes from scratch.

---

## 📸 Screenshots

> _Add screenshots here after running the app_

| Feed | Error State | Like |
|---|---|---|
| ![feed](screenshots/feed.png) | ![error](screenshots/error.png) | ![like](screenshots/like.png) |

---

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

---

## 📄 License

```
MIT License

Copyright (c) 2025

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 👨‍💻 Author

**Akshay Kalwar**

- GitHub: [@akshaykalwar](https://github.com/Akshaykalwar8933)

---

> Built as part of a technical interview assessment for EaseMyDeal.
