import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/modules/auth/controllers/auth_controller.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final obscureNewPassword = ValueNotifier<bool>(true);
  final obscureConfirmPassword = ValueNotifier<bool>(true);
  final currentStep = ValueNotifier<int>(0); // 0: email, 1: otp & password

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    obscureNewPassword.dispose();
    obscureConfirmPassword.dispose();
    currentStep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                  AppTheme.secondaryColor,
                ],
              ),
            ),
          ),
          // Decorative circles
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // White card with form
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ValueListenableBuilder<int>(
                        valueListenable: currentStep,
                        builder: (context, step, _) {
                          return Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Progress indicator
                                _buildProgressIndicator(step),
                                const SizedBox(height: 32),

                                // Step content
                                if (step == 0) ...[
                                  _buildEmailStep(controller),
                                ] else ...[
                                  _buildResetStep(controller),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int step) {
    return Row(
      children: [
        _buildStepCircle(0, step, 'Email'),
        Expanded(
          child: Container(
            height: 2,
            color: step >= 1 ? AppTheme.primaryColor : Colors.grey[300],
          ),
        ),
        _buildStepCircle(1, step, 'Reset'),
      ],
    );
  }

  Widget _buildStepCircle(int stepNumber, int currentStep, String label) {
    final isActive = currentStep >= stepNumber;
    final isCurrent = currentStep == stepNumber;

    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppTheme.primaryColor : Colors.grey[300],
            border: Border.all(
              color: isCurrent ? AppTheme.primaryColor : Colors.transparent,
              width: 3,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isActive
                ? Icon(
                    stepNumber < currentStep
                        ? Icons.check_rounded
                        : Icons.mail_rounded,
                    color: Colors.white,
                    size: 24,
                  )
                : Text(
                    '${stepNumber + 1}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? AppTheme.primaryColor : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailStep(AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_reset_rounded,
            size: 60,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        // Title
        const Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Enter your email address and we\'ll send you an OTP to reset your password',
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // Email field
        TextFormField(
          controller: emailController,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            labelText: 'Email Address',
            labelStyle: const TextStyle(fontSize: 14),
            hintText: 'Enter your registered email',
            hintStyle: const TextStyle(fontSize: 13),
            prefixIcon: Icon(
              Icons.email_rounded,
              color: AppTheme.primaryColor,
              size: 22,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
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
        const SizedBox(height: 24),
        // Error message
        Obx(
          () => controller.errorMessage.value.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        // Send OTP button
        Obx(
          () => ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () async {
                    if (formKey.currentState!.validate()) {
                      final success = await controller.sendPasswordResetOtp(
                        email: emailController.text.trim(),
                      );

                      if (success) {
                        currentStep.value = 1;
                        Get.snackbar(
                          'OTP Sent',
                          'Please check your email for the OTP',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                        );
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.6),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Send OTP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
        // Back to login
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Back to Login',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetStep(AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.verified_user_rounded,
            size: 60,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 24),
        // Title
        const Text(
          'Reset Your Password',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Enter the OTP sent to ${emailController.text} and create a new password',
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // OTP field
        TextFormField(
          controller: otpController,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            labelText: 'OTP Code',
            labelStyle: const TextStyle(fontSize: 14),
            hintText: '000000',
            hintStyle: TextStyle(
              fontSize: 20,
              letterSpacing: 8,
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(
              Icons.security_rounded,
              color: Colors.green,
              size: 22,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the OTP';
            }
            if (value.length != 6) {
              return 'OTP must be 6 digits';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // New password field
        ValueListenableBuilder<bool>(
          valueListenable: obscureNewPassword,
          builder: (context, obscure, _) => TextFormField(
            controller: newPasswordController,
            obscureText: obscure,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              labelText: 'New Password',
              labelStyle: const TextStyle(fontSize: 14),
              hintText: 'Enter your new password',
              hintStyle: const TextStyle(fontSize: 13),
              prefixIcon: Icon(
                Icons.lock_rounded,
                color: Colors.grey[600],
                size: 22,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: Colors.grey[600],
                  size: 20,
                ),
                onPressed: () => obscureNewPassword.value = !obscure,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a new password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        // Confirm password field
        ValueListenableBuilder<bool>(
          valueListenable: obscureConfirmPassword,
          builder: (context, obscure, _) => TextFormField(
            controller: confirmPasswordController,
            obscureText: obscure,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              labelStyle: const TextStyle(fontSize: 14),
              hintText: 'Re-enter your new password',
              hintStyle: const TextStyle(fontSize: 13),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: Colors.grey[600],
                size: 22,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: Colors.grey[600],
                  size: 20,
                ),
                onPressed: () => obscureConfirmPassword.value = !obscure,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 24),
        // Error message
        Obx(
          () => controller.errorMessage.value.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        // Reset password button
        Obx(
          () => ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () async {
                    if (formKey.currentState!.validate()) {
                      final success = await controller.resetPassword(
                        email: emailController.text.trim(),
                        otp: otpController.text.trim(),
                        newPassword: newPasswordController.text,
                      );

                      if (success) {
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Password reset successfully. Please login with your new password',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 4),
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                        );
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              disabledBackgroundColor: Colors.green.withOpacity(0.6),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.check_circle_rounded, size: 20),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
        // Resend OTP
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive OTP? ",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            TextButton(
              onPressed: () async {
                final success = await controller.sendPasswordResetOtp(
                  email: emailController.text.trim(),
                );
                if (success) {
                  Get.snackbar(
                    'OTP Resent',
                    'A new OTP has been sent to your email',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Resend',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
