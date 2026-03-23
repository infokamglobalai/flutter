# EduAiTutors - Learning Management System

A robust, secure, and responsive Learning Management System built with Flutter and GetX architecture pattern.

## 🎯 Project Objectives

- Build a subscription-driven LMS with hierarchical content access (Board → Grade → Subject → Chapter)
- Implement dynamic pricing and subscription management
- Provide rich content delivery (videos, documents, interactive polls)
- Comprehensive assessment capabilities with quizzes and progress tracking
- Secure authentication and role-based access control

## 🏗️ Architecture Overview

This project follows **Clean Architecture** principles with **MVC (Model-View-Controller)** pattern using **GetX** for state management, dependency injection, and routing.

### Folder Structure

```
lib/
├── app/
│   ├── core/                      # Core application components
│   │   ├── bindings/              # Initial app bindings
│   │   │   └── initial_binding.dart
│   │   ├── constants/             # App-wide constants
│   │   │   ├── api_constants.dart
│   │   │   └── app_constants.dart
│   │   ├── network/               # Network layer
│   │   │   └── api_client.dart    # Dio-based API client with interceptors
│   │   ├── services/              # Core services
│   │   │   └── storage_service.dart
│   │   └── theme/                 # App theming
│   │       └── app_theme.dart
│   │
│   ├── data/                      # Data Layer
│   │   ├── models/                # Data models
│   │   │   ├── user_model.dart
│   │   │   ├── content_hierarchy_models.dart
│   │   │   ├── subscription_model.dart
│   │   │   ├── content_model.dart
│   │   │   └── quiz_model.dart
│   │   └── repositories/          # Data repositories
│   │       ├── auth_repository.dart
│   │       ├── content_hierarchy_repository.dart
│   │       └── subscription_repository.dart
│   │
│   ├── modules/                   # Feature Modules (MVC)
│   │   ├── auth/
│   │   │   ├── bindings/          # Dependency injection
│   │   │   │   └── auth_binding.dart
│   │   │   ├── controllers/       # Business logic (Controller)
│   │   │   │   └── auth_controller.dart
│   │   │   └── views/             # UI layer (View)
│   │   │       └── login_view.dart
│   │   ├── splash/
│   │   │   └── splash_module.dart
│   │   └── placeholder_modules.dart
│   │
│   ├── routes/                    # Navigation
│   │   ├── app_pages.dart         # Route definitions
│   │   └── app_routes.dart        # Route constants
│   │
│   └── middlewares/               # Route middlewares
│       └── auth_middleware.dart   # Authentication guard
│
└── main.dart                      # App entry point
```

## 🎨 Architecture Layers

### 1. **Data Layer** (`app/data/`)

Responsible for data management and business logic.

#### Models
- `UserModel` - User authentication and profile data
- `BoardModel`, `GradeModel`, `SubjectModel`, `ChapterModel` - Content hierarchy
- `SubscriptionModel`, `SubscriptionPlanModel` - Subscription management
- `VideoContentModel`, `DocumentContentModel`, `PollModel` - Content types
- `QuizModel`, `QuestionModel`, `QuizResultModel` - Assessment data

#### Repositories
Handle API communication and data operations:
- `AuthRepository` - Authentication, registration, profile management
- `ContentHierarchyRepository` - Board/Grade/Subject/Chapter CRUD
- `SubscriptionRepository` - Subscription plans and payment handling

### 2. **Presentation Layer** (`app/modules/`)

Implements MVC pattern using GetX:

#### Controller (C)
- Manages business logic and state
- Communicates with repositories
- Reactive state management with `.obs`
- Example: `AuthController`

#### View (V)
- Pure UI components
- Observes controller state with `Obx()` or `GetX<>`
- No business logic
- Example: `LoginView`

#### Bindings
- Dependency injection for each module
- Lazy loading of controllers and repositories
- Example: `LoginBinding`

### 3. **Core Layer** (`app/core/`)

#### Network
- `ApiClient` - Centralized HTTP client with Dio
  - Automatic token injection
  - Token refresh mechanism
  - Error handling and retry logic
  - Request/Response interceptors

#### Services
- `StorageService` - Local data persistence with SharedPreferences
  - Token management
  - User data caching
  - App preferences

#### Theme
- `AppTheme` - Centralized theming
  - Light and dark themes
  - Color schemes
  - Typography system

#### Constants
- `ApiConstants` - API endpoints
- `AppConstants` - App-wide configuration

### 4. **Routing** (`app/routes/`)

GetX route management:
- Named routes with type safety
- Route middleware for authentication
- Lazy loading of pages
- Transition animations

## 🔐 Key Features

### Authentication & Authorization
- JWT-based authentication
- Automatic token refresh
- Secure storage with SharedPreferences
- Route guards with `AuthMiddleware`

### Subscription Management
- Hierarchical subscription model (Board → Grade → Subject)
- Dynamic pricing with discount support
- Multiple subscription types (Monthly, Quarterly, Yearly)
- Payment gateway integration (Razorpay ready)

### Content Delivery
- **Videos**: Streaming with quality selection
- **Documents**: PDF/PPT viewer
- **Interactive Polls**: Real-time voting
- **Assessments**: Timed quizzes with instant results

### State Management
- Reactive programming with GetX
- Centralized state in controllers
- Minimal boilerplate
- Memory efficient with lazy loading

## 📦 Dependencies

### Core
- `get: ^4.6.6` - State management, DI, routing
- `dio: ^5.4.0` - HTTP client
- `shared_preferences: ^2.2.2` - Local storage

### UI & Media
- `cached_network_image: ^3.3.1` - Image caching
- `video_player: ^2.8.2` - Video playback
- `chewie: ^1.7.5` - Video player UI
- `flutter_pdfview: ^1.3.2` - PDF viewing

### Utilities
- `logger: ^2.0.2+1` - Logging
- `intl: ^0.19.0` - Internationalization
- `connectivity_plus: ^5.0.2` - Network status

### Payment
- `razorpay_flutter: ^1.3.6` - Payment integration

## 🚀 Getting Started

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Update API Configuration
Edit `lib/app/core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'https://your-api-url.com/api/v1';
```

### 3. Run the App
```bash
flutter run
```

## 📝 Implementation Guide

### Creating a New Feature Module

1. **Create folder structure**:
```
app/modules/my_feature/
├── bindings/
│   └── my_feature_binding.dart
├── controllers/
│   └── my_feature_controller.dart
└── views/
    └── my_feature_view.dart
```

2. **Implement Controller**:
```dart
class MyFeatureController extends GetxController {
  final MyRepository _repository = Get.find();
  final RxList<MyModel> items = <MyModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchData();
  }
  
  Future<void> fetchData() async {
    try {
      final data = await _repository.getData();
      items.value = data;
    } catch (e) {
      // Handle error
    }
  }
}
```

3. **Create View**:
```dart
class MyFeatureView extends GetView<MyFeatureController> {
  const MyFeatureView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Feature')),
      body: Obx(() => ListView.builder(
        itemCount: controller.items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(controller.items[index].name),
          );
        },
      )),
    );
  }
}
```

4. **Setup Binding**:
```dart
class MyFeatureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyRepository>(() => MyRepository());
    Get.lazyPut<MyFeatureController>(() => MyFeatureController());
  }
}
```

5. **Add Route**:
```dart
// In app_routes.dart
static const MY_FEATURE = _Paths.MY_FEATURE;

// In _Paths
static const MY_FEATURE = '/my-feature';

// In app_pages.dart
GetPage(
  name: _Paths.MY_FEATURE,
  page: () => const MyFeatureView(),
  binding: MyFeatureBinding(),
  middlewares: [AuthMiddleware()], // if authentication required
),
```

## 🔧 API Integration

### Example: Creating a Repository
```dart
class MyRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();
  
  Future<List<MyModel>> getData() async {
    try {
      final response = await _apiClient.get('/endpoint');
      return (response.data['items'] as List)
          .map((item) => MyModel.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
```

## 🎯 Best Practices

1. **Separation of Concerns**: Keep Views pure, logic in Controllers
2. **Reactive State**: Use `.obs` for reactive variables
3. **Lazy Loading**: Use `Get.lazyPut()` for better performance
4. **Error Handling**: Always handle errors in controllers
5. **Type Safety**: Use proper model classes, avoid dynamic
6. **Dispose Resources**: Override `onClose()` in controllers
7. **Constants**: Never hardcode strings or numbers
8. **Documentation**: Comment complex business logic

## 📱 Next Steps

To complete the implementation:

1. Implement remaining view screens in `placeholder_modules.dart`
2. Create controllers for each feature module
3. Implement progress tracking system
4. Add payment gateway integration
5. Implement video player with quality selection
6. Add offline content caching
7. Implement push notifications
8. Add analytics tracking
9. Write unit and widget tests
10. Setup CI/CD pipeline

## 📄 License

This project is proprietary and confidential.

---

**Built with ❤️ using Flutter & GetX**
