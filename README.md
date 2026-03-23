# 🎓 EduAiTutors - Learning Management System

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-02569B?logo=flutter)](https://flutter.dev)
[![GetX](https://img.shields.io/badge/GetX-4.6.6-8B5CF6)](https://pub.dev/packages/get)
[![License](https://img.shields.io/badge/License-Proprietary-red)]()

A robust, secure, and responsive Learning Management System built with Flutter using Clean Architecture and MVC pattern with GetX.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Documentation](#documentation)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Development](#development)
- [Contributing](#contributing)

---

## 🎯 Overview

EduAiTutors is a subscription-driven learning platform designed for educational institutions. It provides a hierarchical content structure (Board → Grade → Subject → Chapter) with dynamic pricing, rich content delivery, and comprehensive assessment capabilities.

### Project Objectives

- ✅ Build secure, responsive mobile LMS
- ✅ Implement subscription-driven access control
- ✅ Provide multi-format content delivery (video, documents, polls)
- ✅ Enable comprehensive assessment and progress tracking
- ✅ Support dynamic pricing and payment integration

---

## ✨ Features

### 🔐 Authentication & Authorization
- JWT-based authentication
- Automatic token refresh
- Secure local storage
- Role-based access control

### 📚 Content Hierarchy
- Board → Grade → Subject → Chapter structure
- Dynamic content organization
- Subscription-based access
- Free & premium content support

### 💳 Subscription Management
- Multiple plan types (Monthly, Quarterly, Yearly)
- Dynamic pricing with discounts
- Payment gateway integration (Razorpay)
- Subscription history tracking

### 🎬 Content Delivery
- **Video Streaming** with quality selection
- **Document Viewer** (PDF/PPT)
- **Interactive Polls** with real-time results
- **Assessments** with timed quizzes

### 📊 Progress Tracking
- Chapter completion tracking
- Quiz performance analytics
- Learning statistics dashboard
- Personalized progress reports

---

## 🏗️ Architecture

This project implements **Clean Architecture** with **MVC (Model-View-Controller)** pattern using **GetX** for state management.

### Architecture Layers

```
┌─────────────────────────────────────────┐
│     Presentation Layer (Views + Controllers)     │
├─────────────────────────────────────────┤
│     Domain Layer (Repositories + Models)         │
├─────────────────────────────────────────┤
│     Data Layer (API Client + Storage)            │
└─────────────────────────────────────────┘
```

### MVC Pattern

- **Model**: Data structures and business entities (`app/data/models/`)
- **View**: UI components (`app/modules/[module]/views/`)
- **Controller**: Business logic and state (`app/modules/[module]/controllers/`)

**Full architecture documentation**: [ARCHITECTURE.md](ARCHITECTURE.md)

---

## 📁 Project Structure

```
lib/
├── app/
│   ├── core/                    # Core infrastructure
│   │   ├── bindings/            # Dependency injection
│   │   ├── constants/           # App constants
│   │   ├── network/             # API client
│   │   ├── services/            # Core services
│   │   └── theme/               # App theming
│   │
│   ├── data/                    # Data layer
│   │   ├── models/              # Data models
│   │   └── repositories/        # Data repositories
│   │
│   ├── modules/                 # Feature modules (MVC)
│   │   ├── auth/                # Authentication
│   │   ├── dashboard/           # Dashboard (Complete)
│   │   └── ...                  # Other modules
│   │
│   ├── routes/                  # Navigation
│   │   ├── app_pages.dart       # Route definitions
│   │   └── app_routes.dart      # Route constants
│   │
│   └── middlewares/             # Route guards
│       └── auth_middleware.dart
│
└── main.dart                    # App entry point
```

**Detailed structure**: [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.8.1)
- Dart SDK
- Android Studio / Xcode
- VS Code (recommended)

### Installation

1. **Clone the repository**
   ```bash
   cd "path/to/najahapp"
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   
   Edit `lib/app/core/constants/api_constants.dart`:
   ```dart
   static const String baseUrl = 'https://your-api-url.com/api/v1';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

**Complete setup guide**: [QUICKSTART.md](QUICKSTART.md)

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Detailed architecture guide with examples |
| [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) | Complete file structure and organization |
| [ARCHITECTURE_DIAGRAMS.md](ARCHITECTURE_DIAGRAMS.md) | Visual architecture diagrams |
| [QUICKSTART.md](QUICKSTART.md) | Getting started guide |
| [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) | What's implemented |
| [CHECKLIST.md](CHECKLIST.md) | Implementation checklist |
| [TODO.md](TODO.md) | Upcoming features and tasks |

---

## 📱 Screenshots

### Current Implementation

#### ✅ Login Screen
- Email/password validation
- Error handling
- Loading states

#### ✅ Dashboard (Complete)
- User welcome section
- Subscription status card
- Learning progress tracker
- Quick action buttons
- Statistics display
- Pull-to-refresh

*Note: Add screenshots once UI is finalized*

---

## 🛠️ Tech Stack

### Core
- **Flutter** (3.8.1) - UI framework
- **Dart** - Programming language
- **GetX** (4.6.6) - State management, DI, routing

### Network & API
- **Dio** (5.4.0) - HTTP client
- **Connectivity Plus** - Network status

### Local Storage
- **Shared Preferences** - Key-value storage
- **Hive** - NoSQL database
- **Flutter Secure Storage** - Encrypted storage

### Media
- **Video Player** - Video playback
- **Chewie** - Video player UI
- **Cached Network Image** - Image caching
- **Flutter PDF View** - PDF rendering

### UI Components
- **Material 3** - Design system
- **Shimmer** - Loading effects
- **Lottie** - Animations

### Payment & Analytics
- **Razorpay Flutter** - Payment gateway
- **Firebase Analytics** - User analytics

**Full dependency list**: [pubspec.yaml](pubspec.yaml)

---

## 👨‍💻 Development

### Code Structure

Each feature follows this MVC structure:

```dart
// Controller (Business Logic)
class MyController extends GetxController {
  final RxList<Item> items = <Item>[].obs;
  
  Future<void> fetchData() async {
    final data = await repository.getData();
    items.value = data;
  }
}

// View (UI)
class MyView extends GetView<MyController> {
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
      itemCount: controller.items.length,
      itemBuilder: (context, index) => ...,
    ));
  }
}

// Binding (DI)
class MyBinding extends Bindings {
  void dependencies() {
    Get.lazyPut(() => MyController());
  }
}
```

### Adding a New Module

1. Create module folder structure
2. Implement Controller with business logic
3. Create View with UI
4. Setup Binding for dependencies
5. Register route in `app_pages.dart`

**Example**: See `lib/app/modules/dashboard/` for complete implementation.

### Best Practices

- ✅ Keep Views pure (UI only)
- ✅ Put logic in Controllers
- ✅ Use reactive variables (`.obs`)
- ✅ Handle errors at all layers
- ✅ Show loading states
- ✅ Use constants, avoid hardcoding
- ✅ Document complex logic

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/auth_test.dart
```

---

## 📦 Building

### Debug Build
```bash
flutter build apk --debug
flutter build ios --debug
```

### Release Build
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
flutter build ipa --release
```

---

## 📈 Project Status

**Overall Completion: 60%**

- ✅ Core Infrastructure: 100%
- ✅ Data Layer: 100%
- ✅ Auth Module: 80%
- ✅ Dashboard Module: 100%
- ⏳ Content Modules: 20% (placeholders)
- ✅ Documentation: 100%

**Production Readiness**: Foundation Complete ✅

The project has a solid foundation with proven architecture. The Dashboard module demonstrates the complete MVC implementation that can be replicated for other features.

---

## 🗺️ Roadmap

### Phase 1: Core Features (In Progress)
- [x] Authentication system
- [x] Dashboard
- [ ] Content hierarchy (Boards, Grades, Subjects, Chapters)
- [ ] Video player
- [ ] Quiz module

### Phase 2: Enhanced Features
- [ ] Progress tracking
- [ ] Payment integration
- [ ] Notifications
- [ ] Offline mode
- [ ] Search & filters

### Phase 3: Advanced Features
- [ ] Social features
- [ ] Analytics dashboard
- [ ] Admin panel
- [ ] Multi-language support

---

## 🤝 Contributing

This is a private project. For contributions, please contact the development team.

### Development Workflow

1. Create feature branch
2. Implement following MVC pattern
3. Write tests
4. Submit pull request
5. Code review
6. Merge to main

---

## 📄 License

This project is proprietary and confidential.

---

## 👥 Team

- **Developer**: Najah Development Team
- **Architecture**: Clean Architecture with MVC/GetX
- **Design**: Material Design 3

---

## 📞 Support

For technical support and queries:
- 📧 Email: support@najahapp.com
- 📚 Documentation: See [docs](/)
- 🐛 Issues: Contact development team

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- GetX community for excellent state management
- Material Design for beautiful design system

---

**Built with ❤️ using Flutter & GetX**

*Last Updated: December 2025*
