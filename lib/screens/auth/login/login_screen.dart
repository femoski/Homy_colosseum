import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/services/config_service.dart';
import 'package:homy/utils/constants/text_strings.dart';
// import 'package:homy/utils/constants/icons.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:homy/screens/auth/controllers/auth_controller.dart';

final configService = Get.find<ConfigService>();
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Get.offAllNamed('/root');
            },
            child: Text(
              'Skip',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.02),
              Theme.of(context).colorScheme.secondary.withOpacity(0.02),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: SizedBox(
                  height: size.height - MediaQuery.of(context).padding.top - kToolbarHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        const Spacer(flex: 1),
                        // Animated Logo
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Center(
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Icon(
                                Icons.home_work_rounded,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(flex: 1),

                        // Welcome Text with Animation
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                Text(
                                  MTexts.loginTitle,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  MTexts.loginSubTitle,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(flex: 1),

                        // Login Form with Animation
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildLoginForm(),
                          ),
                        ),
                        const Spacer(flex: 1),

                        // Social Login
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildSocialLogin(),
                          ),
                        ),
                        const Spacer(flex: 1),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.xl),
        child: Column(
          children: [
            _buildTextField(
              hint: 'Email or Username',
              icon: HugeIcons.strokeRoundedInbox,
              inputAction: TextInputAction.next,
              controller: _emailController,
            ),
            const SizedBox(height: AppSizes.xl),
            _buildTextField(
              hint: MTexts.password,
              icon: HugeIcons.strokeRoundedLockPassword,
              isPassword: true,
              inputAction: TextInputAction.done,
              controller: _passwordController,
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(''),
                TextButton(
                  onPressed: () {
                    Get.toNamed('/forgot-password');
                  },
                  child: Text(MTexts.forgotPassword, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(() => ElevatedButton(
                onPressed: _authController.isLoading.value
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {

                        await _authController.signIn(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                      }
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: _authController.isLoading.value ? 0 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  disabledBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                  disabledForegroundColor: Colors.white.withOpacity(0.6),
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
            const SizedBox(height: AppSizes.md),
            // Add Skip/Continue as Guest button
            TextButton(
              onPressed: () {
                Get.offAllNamed('/root');
              },
              child: Text(
                'Continue as Guest',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputAction? inputAction,
    TextEditingController? controller,
  }) {
    return Obx(() => TextFormField(
      enabled: !_authController.isLoading.value,
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      obscureText: isPassword && !_authController.isPasswordVisible.value,
      textInputAction: inputAction,
      style: Theme.of(context).textTheme.bodyLarge,
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
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Get.isDarkMode
                ? Theme.of(context).colorScheme.outline
                                : Color(0xFF253341).withOpacity(0.1),

                // : Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
    ));
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
                    if(configService.centralizeLogin.googleLoginStatus || configService.centralizeLogin.facebookLoginStatus)

        Text(
          MTexts.orSignInWith,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(configService.centralizeLogin.googleLoginStatus)
            _buildSocialButton(
              icon: 'assets/images/google.png',
              onTap: () {},
            ),
            const SizedBox(width: 20),
            if(configService.centralizeLogin.facebookLoginStatus)
            _buildSocialButton(
              icon: 'assets/images/facebook.png',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
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
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
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







