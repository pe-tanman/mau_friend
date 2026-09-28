# 🐈 Mau Friend

> *Share what you're doing — not where you are.*

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)
![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20Android-lightgrey)


## 🌟 Highlights

- 📍 **Status, not coordinates** — friends see *"Studying at the library"*, never a pin on a map
- 🔒 **Location stays on your phone** — your position is matched to places you named, on-device
- 🤝 **Private by design** — add friends only with a one-time QR code; there is no username search
- 🎨 **Built on a design system** — consistent typography, color and components across every screen
- 📱 **Cross-platform** — one Flutter codebase for iOS and Android


## ℹ️ Overview

Most location-sharing apps put you on a map. Mau Friend shares *how you're spending your time* instead.

You register the places that matter to you — home, the library, the gym — and draw an area around each one. When you're inside one of those areas, the app turns your current location into a friendly status like *"Relaxing at home 🏠"* or *"On the move 🚃"*. The conversion happens entirely on the device, so exact latitude and longitude are never uploaded.

Friends connect by scanning a one-time QR code, which keeps your network limited to people you've actually met.


### ✍️ Author

Designed and built by [Yuki Ishihara](https://github.com/pe-tanman) (product design + development). See more of my work on my [portfolio](https://portfolio-pe-tanmans-projects.vercel.app).


## 🚀 Usage

1. **Sign in** with Google or email and set up your profile.
2. **Add a place** — pick a spot on the map, give it a name and an emoji, and set its radius.
3. **Add a friend** — show your one-time QR code, or scan theirs.
4. **Glance at your friends list** to see what everyone is up to right now.


## ⬇️ Installation

> [!NOTE]
> Mau Friend is being prepared for the App Store and Google Play. Until then, you can build it from source.

Requirements: [Flutter](https://docs.flutter.dev/get-started/install) 3.x, plus Xcode (iOS) or Android Studio (Android).

```bash
git clone https://github.com/pe-tanman/mau_friend.git
cd mau_friend
flutter pub get
flutter run
```

For security, the following files are **not** in the repository. You'll need your own Firebase project and API keys:

| File | Purpose |
| --- | --- |
| `ios/Runner/GoogleService-Info.plist` | Firebase config (iOS) |
| `android/app/google-services.json` | Firebase config (Android) |
| `lib/firebase_options.dart` | Firebase config (generate with `flutterfire configure`) |
| `credential.env` | Third-party API keys |
| `key.jks` | Android signing key |

Tested on an iPhone 16 (simulator) and a Google Pixel 6a (physical device).


## 💭 Feedback and Contributing

Found a bug or have an idea? [Open an issue](https://github.com/pe-tanman/mau_friend/issues) and include your device model and OS version, or send feedback through [this form](https://docs.google.com/forms/d/e/1FAIpQLSerueDg9dyzPd4bkevzKaIL_01tvPpuIb9zTCe9FKMtNheRXQ/viewform?usp=sharing&ouid=117658194888200180241).

Pull requests are welcome: fork the repo, create a feature branch, and open a PR describing your change.
