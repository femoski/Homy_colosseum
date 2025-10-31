import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/repositories/user_repository.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/utils/constants/text_strings.dart';
import 'package:homy/common/ui.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = UniqueKey();
  final _formState = GlobalKey<FormState>();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRepository userRepository = UserRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Change Password',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Get.theme.colorScheme.primary,
          ),
        ),
        elevation: 0,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Get.theme.colorScheme.primary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formState,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your old password and new password to change your password.',
                  style: Get.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSizes.xl),
                _buildPasswordField(
                  'Current Password',
                  HugeIcons.strokeRoundedLockPassword,
                  controller: _oldPasswordController,
                  isPassword: true,
                  isPasswordVisible: _isOldPasswordVisible,
                  onVisibilityChanged: () {
                    setState(() => _isOldPasswordVisible = !_isOldPasswordVisible);
                  },
                ),
                const SizedBox(height: AppSizes.xl),
                _buildPasswordField(
                  'New Password',
                  HugeIcons.strokeRoundedLockPassword,
                  controller: _newPasswordController,
                  isPassword: true,
                  isPasswordVisible: _isNewPasswordVisible,
                  onVisibilityChanged: () {
                    setState(() => _isNewPasswordVisible = !_isNewPasswordVisible);
                  },
                ),
                const SizedBox(height: AppSizes.xl),
                _buildPasswordField(
                  'Confirm New Password',
                  HugeIcons.strokeRoundedLockPassword,
                  controller: _confirmPasswordController,
                  isPassword: true,
                  isPasswordVisible: _isConfirmPasswordVisible,
                  onVisibilityChanged: () {
                    setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Get.toNamed('/forgot-password');
                    },
                    child: Text(
                      'Forgot your current password?',
                      style: TextStyle(
                        color: Get.theme.colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_formState.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              // CommonUI.loader();
                              try {
                                Map<String, dynamic> params = {
                                  'current_password': _oldPasswordController.text,
                                  'new_password': _newPasswordController.text,
                                  'new_password_confirmation': _confirmPasswordController.text,
                                };
                                await userRepository.changePassword(params);
                                // Get.back();
                                _oldPasswordController.clear();
                                _newPasswordController.clear();
                                _confirmPasswordController.clear();
                                Get.showSnackbar(CommonUI.SuccessSnackBar(message: 'Password changed successfully'));
                                setState(() => _isLoading = false);
                              } catch(e) {
                                Get.back();
                                Get.showSnackbar(CommonUI.ErrorSnackBar(message: e.toString()));
                              }
                            

                              // Simulate API call
                              await Future.delayed(const Duration(seconds: 2));
                              
                              setState(() => _isLoading = false);
                              Get.snackbar('Success', 'Password changed successfully');
                              await Future.delayed(const Duration(milliseconds: 500));
                              Get.back(result: true);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: _isLoading ? 0 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      disabledBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                      disabledForegroundColor: Colors.white.withOpacity(0.6),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(
                            'Change Password',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String hint,
    IconData icon, {
    bool isPassword = false,
    bool isPasswordVisible = false,
    TextEditingController? controller,
    VoidCallback? onVisibilityChanged,
  }) {
    return TextFormField(
      enabled: !_isLoading,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: onVisibilityChanged,
                icon: Icon(
                  isPasswordVisible
                      ? HugeIcons.strokeRoundedView
                      : HugeIcons.strokeRoundedViewOffSlash,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Get.isDarkMode
                ? Theme.of(context).colorScheme.outline
                : const Color(0xFF253341).withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
} 