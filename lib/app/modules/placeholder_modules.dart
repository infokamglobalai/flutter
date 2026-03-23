import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Re-export actual Dashboard implementation
export 'package:najahapp/app/modules/dashboard/views/dashboard_view.dart';
export 'package:najahapp/app/modules/dashboard/bindings/dashboard_binding.dart';

// Placeholder views and bindings - You'll implement these based on your needs

// Onboarding is now implemented in onboarding_module.dart

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _gradeController = TextEditingController();
  final _schoolController = TextEditingController();
  final _obscurePassword = ValueNotifier<bool>(true);
  final _obscureConfirmPassword = ValueNotifier<bool>(true);

  String _selectedGrade = 'Grade 1';
  String _selectedBoard = 'CBSE';

  final List<String> _grades = List.generate(12, (i) => 'Grade ${i + 1}');
  final List<String> _boards = [
    'CBSE',
    'ICSE',
    'State Board',
    'IB',
    'Cambridge',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _studentIdController.dispose();
    _gradeController.dispose();
    _schoolController.dispose();
    _obscurePassword.dispose();
    _obscureConfirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Premium App Bar
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF38388C),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
              ),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Student Registration',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF38388C),
                      Color(0xFF5858A8),
                      Color(0xFFD47036),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Form Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(color: Colors.grey[50]),
              child: Column(
                children: [
                  // Welcome Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF38388C).withOpacity(0.1),
                          const Color(0xFFD47036).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF38388C).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF38388C), Color(0xFFD47036)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Join EduAiTutors',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Start your learning journey today',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Registration Form
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Personal Information'),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_rounded,
                            hint: 'Enter your full name',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            icon: Icons.email_rounded,
                            hint: 'your.email@example.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!GetUtils.isEmail(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_rounded,
                            hint: '+1 (555) 000-0000',
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),
                          _buildSectionTitle('Academic Information'),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _studentIdController,
                            label: 'Student ID (Optional)',
                            icon: Icons.badge_rounded,
                            hint: 'Enter your student ID',
                          ),
                          const SizedBox(height: 16),

                          _buildDropdown(
                            label: 'Grade/Class',
                            value: _selectedGrade,
                            items: _grades,
                            icon: Icons.stairs_rounded,
                            onChanged: (value) {
                              setState(() {
                                _selectedGrade = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildDropdown(
                            label: 'Board',
                            value: _selectedBoard,
                            items: _boards,
                            icon: Icons.dashboard_customize_rounded,
                            onChanged: (value) {
                              setState(() {
                                _selectedBoard = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _schoolController,
                            label: 'School Name',
                            icon: Icons.apartment_rounded,
                            hint: 'Enter your school name',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your school name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),
                          _buildSectionTitle('Security'),
                          const SizedBox(height: 16),

                          ValueListenableBuilder<bool>(
                            valueListenable: _obscurePassword,
                            builder: (context, obscure, _) => _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              icon: Icons.lock_rounded,
                              hint: 'Create a strong password',
                              obscureText: obscure,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscure
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                onPressed: () =>
                                    _obscurePassword.value = !obscure,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          ValueListenableBuilder<bool>(
                            valueListenable: _obscureConfirmPassword,
                            builder: (context, obscure, _) => _buildTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              icon: Icons.lock_outline_rounded,
                              hint: 'Re-enter your password',
                              obscureText: obscure,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscure
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                onPressed: () =>
                                    _obscureConfirmPassword.value = !obscure,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Get.snackbar(
                                    'Success',
                                    'Registration successful! Please check your email.',
                                    backgroundColor: const Color(0xFF43A047),
                                    colorText: Colors.white,
                                    icon: const Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.white,
                                    ),
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: const EdgeInsets.all(16),
                                    borderRadius: 12,
                                    duration: const Duration(seconds: 3),
                                  );
                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      Get.offAllNamed('/login');
                                    },
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                backgroundColor: const Color(0xFF38388C),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Get.back(),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Color(0xFF38388C),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6B4CE6), Color(0xFF00BFA6)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(fontSize: 14),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF38388C)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF38388C), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE53935)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20, color: const Color(0xFF38388C)),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Forgot Password')));
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Home')));
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {}
}

// Use the actual Dashboard implementation from exports above

class BoardsView extends StatelessWidget {
  const BoardsView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Boards')));
}

class BoardsBinding extends Bindings {
  @override
  void dependencies() {}
}

class GradesView extends StatelessWidget {
  const GradesView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Grades')));
}

class GradesBinding extends Bindings {
  @override
  void dependencies() {}
}

class SubjectsView extends StatelessWidget {
  const SubjectsView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Subjects')));
}

class SubjectsBinding extends Bindings {
  @override
  void dependencies() {}
}

class ChaptersView extends StatelessWidget {
  const ChaptersView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Chapters')));
}

class ChaptersBinding extends Bindings {
  @override
  void dependencies() {}
}

class ChapterDetailView extends StatelessWidget {
  const ChapterDetailView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Chapter Detail')));
}

class ChapterDetailBinding extends Bindings {
  @override
  void dependencies() {}
}

class VideoPlayerView extends StatelessWidget {
  const VideoPlayerView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Video Player')));
}

class VideoPlayerBinding extends Bindings {
  @override
  void dependencies() {}
}

class DocumentViewerView extends StatelessWidget {
  const DocumentViewerView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Document Viewer')));
}

class DocumentViewerBinding extends Bindings {
  @override
  void dependencies() {}
}

class QuizView extends StatelessWidget {
  const QuizView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Quiz')));
}

class QuizBinding extends Bindings {
  @override
  void dependencies() {}
}

class QuizResultView extends StatelessWidget {
  const QuizResultView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Quiz Result')));
}

class QuizResultBinding extends Bindings {
  @override
  void dependencies() {}
}

class SubscriptionsView extends StatelessWidget {
  const SubscriptionsView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Subscriptions')));
}

class SubscriptionsBinding extends Bindings {
  @override
  void dependencies() {}
}

class SubscriptionPlansView extends StatelessWidget {
  const SubscriptionPlansView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Subscription Plans')));
}

class SubscriptionPlansBinding extends Bindings {
  @override
  void dependencies() {}
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Profile')));
}

class ProfileBinding extends Bindings {
  @override
  void dependencies() {}
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Settings')));
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() {}
}

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Notifications')));
}

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {}
}

class ProgressView extends StatelessWidget {
  const ProgressView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Progress')));
}

class ProgressBinding extends Bindings {
  @override
  void dependencies() {}
}
