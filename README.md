# TripBond

A Flutter-based travel companion application that helps users connect through shared travel experiences and personality compatibility.

## 📱 About

TripBond is a mobile application designed to help travelers bond through personalized travel experiences. The app features:

- **MBTI Personality Assessment**: Understand your travel personality
- **Personalized Recommendations**: Travel suggestions based on your preferences
- **Modern UI/UX**: Smooth animations and intuitive design
- **Cross-Platform**: Built with Flutter for iOS, Android, and Web support

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.6.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- A code editor (VS Code, Android Studio, or IntelliJ IDEA)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tripbond_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/
│   ├── animations/          # Animation utilities and page transitions
│   └── constants/           # App-wide constants (colors, text styles, dimensions)
└── screens/                 # UI screens
    ├── auth_screen.dart
    ├── onboarding_screen.dart
    ├── mbti_screen.dart
    ├── home_screen.dart
    └── ...
```

## 🎨 Features

- ✅ **Authentication**: User login and registration
- ✅ **Onboarding**: Welcome experience for new users
- ✅ **MBTI Assessment**: Travel personality questionnaire
- ✅ **Profile Management**: User profile customization
- ✅ **Smooth Animations**: Flutter Animate integration
- ✅ **Responsive Design**: Adapts to different screen sizes

## 📦 Dependencies

Key packages used in this project:

- `google_fonts` - Beautiful typography
- `shared_preferences` - Local data storage
- `flutter_animate` - Smooth animations
- `lottie` - Vector animations
- `animations` - Material Design motion

See [pubspec.yaml](pubspec.yaml) for the complete list.

## 🧪 Testing

Run unit tests:
```bash
flutter test
```

Run integration tests:
```bash
flutter test integration_test
```

## 📸 Screenshots

*Coming soon*

<!-- 
Add your app screenshots here:
| Home | Profile | MBTI Assessment |
|------|---------|----------------|
| ![Home](screenshots/home.png) | ![Profile](screenshots/profile.png) | ![MBTI](screenshots/mbti.png) |
-->

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is private and not licensed for public use.

## 👥 Team

Developed by the TripBond team.

## 📞 Contact

For questions or support, please contact: [your-email@example.com]

---

Built with ❤️ using Flutter
