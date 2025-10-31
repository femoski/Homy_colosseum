import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/widgets/custom_button.dart';
import 'package:homy/screens/auth/controllers/auth_controller.dart';
import 'package:homy/services/config_service.dart';
import 'package:homy/utils/constants/text_strings.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:hugeicons/hugeicons.dart';

class LoginModal extends StatefulWidget {
  final Function(bool)? onLoginComplete;
  
  const LoginModal({
    super.key, 
    this.onLoginComplete,
  });

  @override
  State<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  final AuthController _authController = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  ConfigService? configService;

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  void _initConfig() async {
    configService = await ConfigService.getConfig();
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle and Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            MTexts.loginTitle,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      MTexts.loginSubTitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const ClampingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextField(
                          hint: 'Email or Username',
                          icon: HugeIcons.strokeRoundedInbox,
                          controller: _emailController,
                        ),
                        const SizedBox(height: AppSizes.lg),
                        _buildTextField(
                          hint: MTexts.password,
                          icon: HugeIcons.strokeRoundedLockPassword,
                          isPassword: true,
                          controller: _passwordController,
                        ),
                        const SizedBox(height: AppSizes.sm),
                        
                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Get.toNamed('/forgot-password');
                            },
                            child: Text(
                              MTexts.forgotPassword,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.lg),

                      //  Obx(() =>   CustomButton(
                      //     buttonText: MTexts.signIn,
                      //     height: 55,
                      //     isLoading: _authController.isLoading.value,
                      //     onPressed: _authController.isLoading.value 
                      //       ? null
                      //       : () async {
                      //           if (_formKey.currentState!.validate()) {
                      //             final success = await _authController.signInModal(
                      //               email: _emailController.text,
                      //               password: _passwordController.text,
                      //             );  
                      //             if (success && widget.onLoginComplete != null) {
                      //               widget.onLoginComplete!(true);
                      //             }
                      //           }
                      //         },
                      //  )),
                        const SizedBox(height: AppSizes.lg),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: Obx(() => ElevatedButton(
                            onPressed: _authController.isLoading.value
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    final success = await _authController.signInModal(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    );
                                    if (success && widget.onLoginComplete != null) {
                                      widget.onLoginComplete!(true);
                                    }
                                  }
                                },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _authController.isLoading.value
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
                                  MTexts.signIn,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          )),
                        ),

                        // Social Login Section
                        if (configService?.config.value?.centralizeLogin.googleLoginStatus == true || 
                            configService?.config.value?.centralizeLogin.facebookLoginStatus == true) ...[
                          const SizedBox(height: AppSizes.xl),
                          Text(
                            MTexts.orSignInWith,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (configService?.config.value?.centralizeLogin.googleLoginStatus == true)
                                _buildSocialButton(
                                  icon: 'assets/images/google.png',
                                  onTap: () {},
                                ),
                              if (configService?.config.value?.centralizeLogin.googleLoginStatus == true &&
                                  configService?.config.value?.centralizeLogin.facebookLoginStatus == true)
                                const SizedBox(width: AppSizes.lg),
                              if (configService?.config.value?.centralizeLogin.facebookLoginStatus == true)
                                _buildSocialButton(
                                  icon: 'assets/images/facebook.png',
                                  onTap: () {},
                                ),
                            ],
                          ),
                        ],

                        // Register Link
                        const SizedBox(height: AppSizes.xl),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            Get.toNamed('/register');
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Obx(() => TextFormField(
      enabled: !_authController.isLoading.value,
      controller: controller,
      obscureText: isPassword && !_authController.isPasswordVisible.value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: _authController.togglePasswordVisibility,
                icon: Icon(
                  _authController.isPasswordVisible.value
                      ? HugeIcons.strokeRoundedView
                      : HugeIcons.strokeRoundedViewOffSlash,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ));
  }

  Widget _buildSocialButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Image.asset(
          icon,
          height: 24,
          width: 24,
        ),
      ),
    );
  }
} 