// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/driver_provider.dart';
import '../../providers/company_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/driver_model.dart';
import '../../models/company_model.dart';
import '../../localization/app_localizations.dart';
import '../../app/theme.dart';

class ManageDriversScreen extends StatefulWidget {
  const ManageDriversScreen({super.key});

  @override
  State<ManageDriversScreen> createState() => _ManageDriversScreenState();
}

class _ManageDriversScreenState extends State<ManageDriversScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCompanyFilter;

  @override
  void initState() {
    super.initState();
    // Load drivers and companies when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().loadAllDrivers();
      context.read<CompanyProvider>().loadAllCompanies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateDriverDialog() {
    showDialog(
      context: context,
      builder: (context) => DriverDialog(),
    );
  }

  void _showEditDriverDialog(Driver driver) {
    showDialog(
      context: context,
      builder: (context) => DriverDialog(driver: driver),
    );
  }

  void _showDeleteConfirmation(String driverId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).delete_driver),
        content: Text(AppLocalizations.of(context).delete_driver_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<DriverProvider>().deleteDriver(driverId).then((success) {
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).driver_deleted),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              });
            },
            child: Text(AppLocalizations.of(context).delete),
          ),
        ],
      ),
    );
  }

  List<Driver> _getFilteredDrivers(List<Driver> drivers) {
    var filtered = drivers;

    // Apply company filter
    if (_selectedCompanyFilter != null && _selectedCompanyFilter!.isNotEmpty) {
      filtered = filtered.where((driver) => driver.companyId == _selectedCompanyFilter).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((driver) {
        return driver.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               driver.phone.contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).manage_drivers),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DriverProvider>().loadAllDrivers(),
            tooltip: AppLocalizations.of(context).refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar and Company Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).search_drivers,
                    hintText: AppLocalizations.of(context).enter_driver_search,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Company Filter Dropdown
                Consumer<CompanyProvider>(
                  builder: (context, companyProvider, child) {
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedCompanyFilter,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).filter_by_company,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.business),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(AppLocalizations.of(context).all_companies),
                        ),
                        ...companyProvider.companies.map((company) =>
                          DropdownMenuItem<String>(
                            value: company.id,
                            child: Text(company.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCompanyFilter = value;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Drivers List
          Expanded(
            child: Consumer2<DriverProvider, CompanyProvider>(
              builder: (context, driverProvider, companyProvider, child) {
                if (driverProvider.isLoading && driverProvider.drivers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (driverProvider.errorMessage != null) {
                  return Card(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error, color: AppTheme.errorColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  driverProvider.errorMessage!,
                                  style: TextStyle(color: AppTheme.errorColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => driverProvider.loadAllDrivers(),
                            child: Text(AppLocalizations.of(context).retry),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final filteredDrivers = _getFilteredDrivers(driverProvider.drivers);

                if (filteredDrivers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.local_shipping_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _selectedCompanyFilter != null
                              ? AppLocalizations.of(context).no_drivers_filter
                              : AppLocalizations.of(context).no_drivers_available,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (_searchQuery.isEmpty && _selectedCompanyFilter == null) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _showCreateDriverDialog,
                            icon: const Icon(Icons.add),
                            label: Text(AppLocalizations.of(context).create_driver),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => driverProvider.loadAllDrivers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDrivers.length,
                    itemBuilder: (context, index) {
                      final driver = filteredDrivers[index];
                      final company = companyProvider.getCompanyById(driver.companyId);
                      return DriverCard(
                        driver: driver,
                        company: company,
                        onEdit: () => _showEditDriverDialog(driver),
                        onDelete: () => _showDeleteConfirmation(driver.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDriverDialog,
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context).create_driver),
        heroTag: "manage_drivers_fab",
      ),
    );
  }
}

class DriverCard extends StatelessWidget {
  final Driver driver;
  final DeliveryCompany? company;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DriverCard({
    super.key,
    required this.driver,
    required this.company,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    driver.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: onEdit,
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 18),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context).edit),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: onDelete,
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 18, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context).delete, style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone, driver.phone),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.business, company?.name ?? AppLocalizations.of(context).unknown_company),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: driver.isActive ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    driver.isActive ? AppLocalizations.of(context).active : AppLocalizations.of(context).inactive,
                    style: TextStyle(
                      color: driver.isActive ? Colors.green.shade800 : Colors.red.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${AppLocalizations.of(context).created} ${driver.createdAt.toString().split(' ')[0]}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class DriverDialog extends StatefulWidget {
  final Driver? driver;

  const DriverDialog({super.key, this.driver});

  @override
  State<DriverDialog> createState() => _DriverDialogState();
}

class _DriverDialogState extends State<DriverDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedCompanyId;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.driver != null) {
      _nameController.text = widget.driver!.name;
      _phoneController.text = widget.driver!.phone;
      _selectedCompanyId = widget.driver!.companyId;
      _isActive = widget.driver!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveDriver() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCompanyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).please_select_company),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final driverProvider = context.read<DriverProvider>();
      final authProvider = context.read<AuthProvider>();

      if (widget.driver == null) {
        // Create new driver
        final newDriver = Driver(
          id: '', // Will be set by the provider
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          companyId: _selectedCompanyId!,
          createdBy: authProvider.user?.id ?? 'unknown_user',
          createdAt: DateTime.now(),
          isActive: _isActive,
        );
        await driverProvider.createDriver(newDriver);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).driver_created),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Update existing driver
        final updates = {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'companyId': _selectedCompanyId!,
          'isActive': _isActive,
        };
        await driverProvider.updateDriver(widget.driver!.id, updates);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).driver_updated),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).operation_failed}: $e'),
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
      title: Text(widget.driver == null
          ? AppLocalizations.of(context).create_driver
          : AppLocalizations.of(context).edit_driver),
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
                  labelText: AppLocalizations.of(context).driver_name,
                  hintText: AppLocalizations.of(context).enter_driver_name,
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context).driver_name_required;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
                    return AppLocalizations.of(context).phone_number_required;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Consumer<CompanyProvider>(
                builder: (context, companyProvider, child) {
                  return DropdownButtonFormField<String>(
                    value: _selectedCompanyId,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).company,
                      prefixIcon: const Icon(Icons.business),
                    ),
                    items: companyProvider.companies.map((company) =>
                      DropdownMenuItem<String>(
                        value: company.id,
                        child: Text(company.name),
                      ),
                    ).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCompanyId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context).please_select_company;
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: Text(AppLocalizations.of(context).active_driver),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value ?? true;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
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
          onPressed: _isLoading ? null : () => _saveDriver(),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Text(widget.driver == null
                  ? AppLocalizations.of(context).create
                  : AppLocalizations.of(context).update),
        ),
      ],
    );
  }
}
