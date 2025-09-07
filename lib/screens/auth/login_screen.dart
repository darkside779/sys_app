// ignore_for_file: deprecated_member_use, unused_import, unused_element

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../app/theme.dart';
import '../../localization/app_localizations.dart';
import '../../screens/admin/admin_dashboard.dart';
import '../../screens/user/user_dashboard.dart';
import '../../screens/super_admin/super_admin_dashboard.dart';
import '../../screens/common/system_locked_screen.dart';
import '../../models/user_model.dart';
import '../../widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      // Show success message
      CommonWidgets.showLocalizedSnackBar(
        context: context,
        getMessage: (tr) => tr.login_success,
        type: SnackBarType.success,
      );

      // Navigate based on user role
      _navigateBasedOnRole(authProvider);
    } else if (mounted) {
      // Show error message
      CommonWidgets.showLocalizedSnackBar(
        context: context,
        getMessage: (tr) => authProvider.errorMessage ?? tr.login_failed,
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _navigateBasedOnRole(AuthProvider authProvider) async {
    // Super admins can always access the system
    if (authProvider.user?.role == UserRole.superAdmin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SuperAdminDashboard()),
      );
      return;
    }

    // Check if system is locked for non-super admin users
    try {
      final doc = await FirebaseFirestore.instance
          .collection('system_settings')
          .doc('security')
          .get();
      
      final isSystemLocked = doc.data()?['is_locked'] ?? false;
      
      if (isSystemLocked) {
        // System is locked, redirect to locked screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SystemLockedScreen()),
          );
        }
        return;
      }
    } catch (e) {
      // If we can't check the lock status, assume system is unlocked
      // and continue with normal navigation
    }

    // System is unlocked, navigate based on role
    Widget destination;
    switch (authProvider.user?.role) {
      case UserRole.admin:
        destination = const AdminDashboard();
        break;
      case UserRole.user:
      default:
        destination = const UserDashboard();
        break;
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => destination),
      );
    }
  }

  void _navigateToRegister() {
    // Registration functionality can be added here later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  String? _validateEmail(String? value) {
    final tr = AppLocalizations.of(context);

    if (value == null || value.isEmpty) {
      return tr.required_field;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return tr.invalid_email;
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final tr = AppLocalizations.of(context);

    if (value == null || value.isEmpty) {
      return tr.required_field;
    }

    if (value.length < 6) {
      return tr.password_too_short;
    }

    return null;
  }

  void _changeLanguage(Locale locale) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.updateProfile(language: locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Language Switcher
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CommonWidgets.languageSwitcher(
                      context: context,
                      onLanguageChanged: _changeLanguage,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // App Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'favicon.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Welcome Text
                CommonWidgets.localizedText(
                  context,
                  (tr) => tr.welcome,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                CommonWidgets.localizedText(
                  context,
                  (tr) => tr.login,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Email Field
                CommonWidgets.localizedTextFormField(
                  context: context,
                  getLabel: (tr) => tr.email,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  enabled: !_isLoading,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),

                const SizedBox(height: 20),

                // Password Field
                CommonWidgets.localizedTextFormField(
                  context: context,
                  getLabel: (tr) => tr.password,
                  controller: _passwordController,
                  obscureText: _isObscurePassword,
                  validator: _validatePassword,
                  enabled: !_isLoading,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscurePassword = !_isObscurePassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Login Button
                CommonWidgets.primaryButton(
                  context: context,
                  getText: (tr) => tr.login,
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                  icon: Icons.login,
                ),

                const SizedBox(height: 24),

                // Register Link
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     CommonWidgets.localizedText(
                //       context,
                //       (tr) =>
                //           "Don't have an account? ", // This should be added to translations
                //       style: Theme.of(context).textTheme.bodyMedium,
                //     ),
                //     GestureDetector(
                //       onTap: _isLoading ? null : _navigateToRegister,
                //       child: CommonWidgets.localizedText(
                //         context,
                //         (tr) => tr.register,
                //         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                //           color: Theme.of(context).primaryColor,
                //           fontWeight: FontWeight.w600,
                //           decoration: TextDecoration.underline,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
