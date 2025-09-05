// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/common_widgets.dart';
import '../../app/theme.dart';
import '../admin/admin_dashboard.dart';
import '../user/user_dashboard.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.user;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set initial language based on current locale
    final currentLocale = Localizations.localeOf(context);
    _selectedLanguage = currentLocale.languageCode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.registerWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      role: _selectedRole,
      language: _selectedLanguage,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      // Show success message
      CommonWidgets.showLocalizedSnackBar(
        context: context,
        getMessage: (tr) => tr.registration_success,
        type: SnackBarType.success,
      );

      // Navigate based on user role
      _navigateBasedOnRole(authProvider);
    } else if (mounted) {
      // Show error message
      CommonWidgets.showLocalizedSnackBar(
        context: context,
        getMessage: (tr) => authProvider.errorMessage ?? tr.registration_failed,
        type: SnackBarType.error,
      );
    }
  }

  void _navigateBasedOnRole(AuthProvider authProvider) {
    Widget destination;
    
    if (authProvider.isAdmin) {
      destination = const AdminDashboard();
    } else {
      destination = const UserDashboard();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  String? _validateName(String? value) {
    final tr = AppLocalizations.of(context);
    
    if (value == null || value.isEmpty) {
      return tr.required_field;
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters'; // Add to translations
    }
    
    return null;
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

  String? _validatePhone(String? value) {
    final tr = AppLocalizations.of(context);
    
    if (value == null || value.isEmpty) {
      return tr.required_field;
    }
    
    final phoneRegex = RegExp(r'^[+]?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return tr.invalid_phone_number;
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

  String? _validateConfirmPassword(String? value) {
    final tr = AppLocalizations.of(context);
    
    if (value == null || value.isEmpty) {
      return tr.required_field;
    }
    
    if (value != _passwordController.text) {
      return tr.passwords_do_not_match;
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: CommonWidgets.localizedAppBar(
        context,
        (tr) => tr.register,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Registration Title
                CommonWidgets.localizedText(
                  context,
                  (tr) => 'Create Account', // Add to translations
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Name Field
                CommonWidgets.localizedTextFormField(
                  context: context,
                  getLabel: (tr) => tr.name,
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  validator: _validateName,
                  enabled: !_isLoading,
                  prefixIcon: const Icon(Icons.person_outlined),
                ),
                
                const SizedBox(height: 20),
                
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
                
                // Phone Field
                CommonWidgets.localizedTextFormField(
                  context: context,
                  getLabel: (tr) => tr.phone,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  enabled: !_isLoading,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                
                const SizedBox(height: 20),
                
                // Role Selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonWidgets.localizedText(
                          context,
                          (tr) => tr.user_role,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RadioListTile<UserRole>(
                          title: CommonWidgets.localizedText(
                            context,
                            (tr) => tr.user,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          subtitle: CommonWidgets.localizedText(
                            context,
                            (tr) => 'Regular user with basic access', // Add to translations
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          value: UserRole.user,
                          groupValue: _selectedRole,
                          onChanged: _isLoading ? null : (value) {
                            setState(() => _selectedRole = value!);
                          },
                        ),
                        RadioListTile<UserRole>(
                          title: CommonWidgets.localizedText(
                            context,
                            (tr) => tr.admin,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          subtitle: CommonWidgets.localizedText(
                            context,
                            (tr) => 'Administrator with full access', // Add to translations
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          value: UserRole.admin,
                          groupValue: _selectedRole,
                          onChanged: _isLoading ? null : (value) {
                            setState(() => _selectedRole = value!);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Language Selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonWidgets.localizedText(
                          context,
                          (tr) => tr.language,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedLanguage,
                          decoration: AppTheme.getInputDecoration(
                            labelText: tr.language,
                            prefixIcon: const Icon(Icons.language),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'en',
                              child: Row(
                                children: [
                                  const Text('🇺🇸'),
                                  const SizedBox(width: 8),
                                  Text(tr.english),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'ar',
                              child: Row(
                                children: [
                                  const Text('🇸🇦'),
                                  const SizedBox(width: 8),
                                  Text(tr.arabic),
                                ],
                              ),
                            ),
                          ],
                          onChanged: _isLoading ? null : (value) {
                            setState(() => _selectedLanguage = value!);
                          },
                        ),
                      ],
                    ),
                  ),
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
                
                const SizedBox(height: 20),
                
                // Confirm Password Field
                CommonWidgets.localizedTextFormField(
                  context: context,
                  getLabel: (tr) => tr.confirm_password,
                  controller: _confirmPasswordController,
                  obscureText: _isObscureConfirmPassword,
                  validator: _validateConfirmPassword,
                  enabled: !_isLoading,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscureConfirmPassword = !_isObscureConfirmPassword;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Register Button
                CommonWidgets.primaryButton(
                  context: context,
                  getText: (tr) => tr.register,
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                  icon: Icons.person_add,
                ),
                
                const SizedBox(height: 24),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonWidgets.localizedText(
                      context,
                      (tr) => "Already have an account? ", // Add to translations
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: CommonWidgets.localizedText(
                        context,
                        (tr) => tr.login,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
