import 'package:flutter/foundation.dart';
import '../models/driver_model.dart';
import '../models/company_model.dart';
import '../services/db_service.dart';

enum DriverLoadState { initial, loading, loaded, error }

class DriverProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  DriverLoadState _state = DriverLoadState.initial;
  List<Driver> _drivers = [];
  List<Driver> _filteredDrivers = [];
  String? _errorMessage;
  String? _searchQuery;
  String? _companyFilter;

  // Getters
  DriverLoadState get state => _state;
  List<Driver> get drivers => _filteredDrivers;
  List<Driver> get allDrivers => _drivers;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == DriverLoadState.loading;
  bool get hasError => _state == DriverLoadState.error;
  String? get searchQuery => _searchQuery;
  String? get companyFilter => _companyFilter;

  // Initialize and load drivers
  Future<void> initialize() async {
    await loadAllDrivers();
  }

  // Load all drivers
  Future<void> loadAllDrivers() async {
    try {
      _setState(DriverLoadState.loading);
      _drivers = await _dbService.getAllDrivers();
      _applyFilters();
      _setState(DriverLoadState.loaded);
    } catch (e) {
      _setError('Failed to load drivers: $e');
    }
  }

  // Load drivers by company
  Future<void> loadDriversByCompany(String companyId) async {
    try {
      _setState(DriverLoadState.loading);
      _drivers = await _dbService.getDriversByCompany(companyId);
      _applyFilters();
      _setState(DriverLoadState.loaded);
    } catch (e) {
      _setError('Failed to load drivers: $e');
    }
  }

  // Create new driver
  Future<bool> createDriver(Driver driver) async {
    try {
      final driverId = await _dbService.createDriver(driver);
      final newDriver = driver.copyWith(id: driverId);
      _drivers.add(newDriver);
      _sortDrivers();
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create driver: $e');
      return false;
    }
  }

  // Update driver
  Future<bool> updateDriver(String driverId, Map<String, dynamic> updates) async {
    try {
      await _dbService.updateDriver(driverId, updates);
      
      // Update local driver
      final driverIndex = _drivers.indexWhere((driver) => driver.id == driverId);
      if (driverIndex != -1) {
        // Reload the updated driver from database to ensure consistency
        final updatedDriver = await _dbService.getDriverById(driverId);
        if (updatedDriver != null) {
          _drivers[driverIndex] = updatedDriver;
          _sortDrivers();
          _applyFilters();
          notifyListeners();
        }
      }
      return true;
    } catch (e) {
      _setError('Failed to update driver: $e');
      return false;
    }
  }

  // Delete driver
  Future<bool> deleteDriver(String driverId) async {
    try {
      await _dbService.deleteDriver(driverId);
      _drivers.removeWhere((driver) => driver.id == driverId);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete driver: $e');
      return false;
    }
  }

  // Get driver by ID
  Driver? getDriverById(String driverId) {
    try {
      return _drivers.firstWhere((driver) => driver.id == driverId);
    } catch (e) {
      return null;
    }
  }

  // Filter methods
  void setSearchQuery(String? query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setCompanyFilter(String? companyId) {
    _companyFilter = companyId;
    _applyFilters();
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = null;
    _companyFilter = null;
    _applyFilters();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = null;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters
  void _applyFilters() {
    _filteredDrivers = _drivers.where((driver) {
      // Company filter
      if (_companyFilter != null && driver.companyId != _companyFilter) {
        return false;
      }

      // Search query filter
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        final query = _searchQuery!.toLowerCase();
        return driver.name.toLowerCase().contains(query) ||
               driver.phone.toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  // Sort drivers alphabetically by name
  void _sortDrivers() {
    _drivers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  // Get drivers by company ID
  List<Driver> getDriversByCompanyId(String companyId) {
    return _drivers.where((driver) => driver.companyId == companyId).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  // Get driver statistics
  Map<String, dynamic> getDriverStatistics() {
    // Count drivers per company
    Map<String, int> driversByCompany = {};
    for (final driver in _drivers) {
      driversByCompany[driver.companyId] = (driversByCompany[driver.companyId] ?? 0) + 1;
    }

    return {
      'total': _drivers.length,
      'filtered': _filteredDrivers.length,
      'byCompany': driversByCompany,
    };
  }

  // Check if driver name already exists in the same company
  bool isDriverNameExistsInCompany(String name, String companyId, {String? excludeId}) {
    return _drivers.any((driver) => 
        driver.name.toLowerCase() == name.toLowerCase() && 
        driver.companyId == companyId &&
        driver.id != excludeId);
  }

  // Check if phone number already exists
  bool isPhoneNumberExists(String phone, {String? excludeId}) {
    return _drivers.any((driver) => 
        driver.phone == phone && 
        driver.id != excludeId);
  }

  // Get drivers for dropdown/selection
  List<Driver> getDriversForSelection({String? companyId}) {
    List<Driver> driversToReturn;
    
    if (companyId != null) {
      driversToReturn = _drivers.where((driver) => driver.companyId == companyId).toList();
    } else {
      driversToReturn = List.from(_drivers);
    }
    
    return driversToReturn..sort((a, b) => a.name.compareTo(b.name));
  }

  // Get company name for driver (requires company data to be available)
  String getCompanyNameForDriver(String driverId, List<DeliveryCompany> companies) {
    final driver = getDriverById(driverId);
    if (driver == null) return 'Unknown';
    
    try {
      final company = companies.firstWhere((c) => c.id == driver.companyId);
      return company.name;
    } catch (e) {
      return 'Unknown Company';
    }
  }

  // Refresh drivers
  Future<void> refresh() async {
    await loadAllDrivers();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == DriverLoadState.error) {
      _setState(DriverLoadState.loaded);
    }
  }

  // Private helper methods
  void _setState(DriverLoadState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _state = DriverLoadState.error;
    _errorMessage = message;
    notifyListeners();
  }
}
