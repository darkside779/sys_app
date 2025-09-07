// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../app/theme.dart';
import '../../localization/app_localizations.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  UserRole? _roleFilter;
  List<User> _filteredUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.loadUsers();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _isLoading = true;
    });

    final userProvider = context.read<UserProvider>();
    List<User> users = List.from(userProvider.users);

    // Filter out super admin users for regular admins
    users = users.where((user) => user.role != UserRole.superAdmin).toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      users = users
          .where(
            (user) =>
                user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                user.phone.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Apply role filter
    if (_roleFilter != null) {
      users = users.where((user) => user.role == _roleFilter).toList();
    }

    // Sort by creation date (newest first)
    users.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _filteredUsers = users;
      _isLoading = false;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _roleFilter = null;
    });
    _loadUsers();
  }

  void _showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (context) => UserDialog(onUserSaved: _applyFilters),
    );
  }

  void _showEditUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => UserDialog(user: user, onUserSaved: _applyFilters),
    );
  }

  void _showDeleteUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).delete_user),
        content: Text(
          '${AppLocalizations.of(context).are_you_sure_delete_user} "${user.name}"? ${AppLocalizations.of(context).action_cannot_be_undone}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          CommonWidgets.errorButton(
            context: context,
            getText: (tr) => tr.delete,
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(User user) async {
    final userProvider = context.read<UserProvider>();
    final success = await userProvider.deleteUser(user.id);

    if (success) {
      _applyFilters();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).user} "${user.name}" ${AppLocalizations.of(context).deleted_successfully}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).failed_to_delete_user}: ${userProvider.errorMessage}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleUserStatus(User user) async {
    final userProvider = context.read<UserProvider>();
    final success = await userProvider.toggleUserStatus(user.id);

    if (success) {
      _applyFilters();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).user} "${user.name}" ${!user.isActive ? AppLocalizations.of(context).activated : AppLocalizations.of(context).deactivated}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).failed_to_update_user_status}: ${userProvider.errorMessage}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showResetPasswordDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password'),
        content: Text(
          'Are you sure you want to reset the password for "${user.name}" to the default password "user1234"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetUserPassword(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('Reset Password'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetUserPassword(User user) async {
    final userProvider = context.read<UserProvider>();
    final success = await userProvider.resetUserPassword(user.id);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to "${user.email}"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to reset password: ${userProvider.errorMessage}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _isLoading
                ? CommonWidgets.localizedLoading(context, (tr) => tr.loading)
                : _buildUsersList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateUserDialog,
        tooltip: AppLocalizations.of(context).add_user,
        heroTag: "manage_users_fab",
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).search_users,
                      hintText: AppLocalizations.of(context).name_or_phone,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                                _applyFilters();
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<UserRole>(
                    initialValue: _roleFilter,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).role,
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      DropdownMenuItem<UserRole>(
                        value: null,
                        child: Text(AppLocalizations.of(context).all_roles),
                      ),
                      ...UserRole.values
                          .where((role) => role != UserRole.superAdmin)
                          .map(
                            (role) => DropdownMenuItem<UserRole>(
                              value: role,
                              child: Text(role.displayName),
                            ),
                          ),
                    ],
                    onChanged: (value) {
                      setState(() => _roleFilter = value);
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
            if (_searchQuery.isNotEmpty || _roleFilter != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context).filters_applied,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear, size: 16),
                    label: Text(AppLocalizations.of(context).clear_all),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    if (_filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).no_users_found,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _roleFilter != null
                  ? AppLocalizations.of(context).try_adjusting_filters
                  : AppLocalizations.of(context).add_users_to_get_started,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(User user) {
    Color roleColor;
    IconData roleIcon;
    switch (user.role) {
      case UserRole.superAdmin:
        roleColor = Colors.deepPurple;
        roleIcon = Icons.security;
        break;
      case UserRole.admin:
        roleColor = AppTheme.errorColor;
        roleIcon = Icons.admin_panel_settings;
        break;
      case UserRole.user:
        roleColor = AppTheme.primaryColor;
        roleIcon = Icons.local_shipping;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: roleColor.withOpacity(0.1),
                  child: Icon(roleIcon, color: roleColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.phone,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: roleColor),
                  ),
                  child: Text(
                    user.role.displayName,
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user.isActive
                        ? AppTheme.successColor.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: user.isActive
                          ? AppTheme.successColor
                          : Colors.grey,
                    ),
                  ),
                  child: Text(
                    user.isActive
                        ? AppLocalizations.of(context).active
                        : AppLocalizations.of(context).inactive,
                    style: TextStyle(
                      color: user.isActive
                          ? AppTheme.successColor
                          : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => _showEditUserDialog(user),
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 18),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context).edit),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () => _toggleUserStatus(user),
                      child: Row(
                        children: [
                          Icon(
                            user.isActive ? Icons.block : Icons.check_circle,
                            size: 18,
                            color: user.isActive ? Colors.blue : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user.isActive
                                ? AppLocalizations.of(context).deactivate
                                : AppLocalizations.of(context).activate,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () => _showResetPasswordDialog(user),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock_reset,
                            size: 18,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text('Reset Password'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () => _showDeleteUserDialog(user),
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 18, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context).delete,
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${AppLocalizations.of(context).created}: ${user.createdAt.toString().split(' ')[0]}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserDialog extends StatefulWidget {
  final User? user;
  final VoidCallback? onUserSaved;

  const UserDialog({super.key, this.user, this.onUserSaved});

  @override
  State<UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends State<UserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.user;
  bool _isActive = true;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _phoneController.text = widget.user!.phone;
      _selectedRole = widget.user!.role;
      _isActive = widget.user!.isActive;
    } else {
      // For new users, always set role to 'user'
      _selectedRole = UserRole.user;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = context.read<UserProvider>();
      bool success;

      if (widget.user == null) {
        // Create new user with 'user' role only
        final newUser = User(
          id: '', // Will be set by Firestore
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          role: UserRole.user, // Always create with 'user' role
          language: 'en', // Default language
          createdAt: DateTime.now(),
          isActive: _isActive,
        );
        success = await userProvider.createUser(newUser, _passwordController.text.trim());
      } else {
        // Update existing user
        final updatedUser = widget.user!.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _selectedRole,
          isActive: _isActive,
        );
        success = await userProvider.updateUser(updatedUser);
      }

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          widget.onUserSaved?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.user == null
                    ? AppLocalizations.of(context).user_created_successfully
                    : AppLocalizations.of(context).user_updated_successfully,
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AppLocalizations.of(context).operation_failed}: ${userProvider.errorMessage}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).operation_failed}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.user == null
            ? AppLocalizations.of(context).create_user
            : AppLocalizations.of(context).edit_user,
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).full_name,
                  hintText: AppLocalizations.of(context).enter_users_full_name,
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context).name_is_required;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).email_address,
                  hintText: AppLocalizations.of(context).enter_email_address,
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context).email_is_required;
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return AppLocalizations.of(
                      context,
                    ).please_enter_valid_email;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Show password field only for new users
              if (widget.user == null) ...[
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).password,
                    hintText: AppLocalizations.of(context).enter_password,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context).password_is_required;
                    }
                    if (value.length < 6) {
                      return AppLocalizations.of(context).password_min_length;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).phone_number,
                  hintText: AppLocalizations.of(context).enter_phone_number,
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(
                      context,
                    ).phone_number_is_required;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Show role dropdown only when editing existing users
              if (widget.user != null)
                DropdownButtonFormField<UserRole>(
                  initialValue: _selectedRole,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).role,
                    prefixIcon: const Icon(Icons.security),
                  ),
                  items: UserRole.values
                      .where((role) => role != UserRole.superAdmin)
                      .map(
                        (role) => DropdownMenuItem<UserRole>(
                          value: role,
                          child: Row(
                            children: [
                              Icon(
                                role == UserRole.admin
                                    ? Icons.admin_panel_settings
                                    : Icons.person,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(role.displayName),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRole = value;
                      });
                    }
                  },
                )
              else
                // For new users, show read-only role info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).role,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context).user,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          AppLocalizations.of(context).default_role,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(AppLocalizations.of(context).active_user),
                subtitle: Text(
                  AppLocalizations.of(context).user_can_login_access_system,
                ),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveUser,
          child: _isLoading
              ? const CircularProgressIndicator()
              : Text(
                  widget.user == null
                      ? AppLocalizations.of(context).create
                      : AppLocalizations.of(context).update,
                ),
        ),
      ],
    );
  }
}
