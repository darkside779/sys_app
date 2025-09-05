import 'package:flutter/foundation.dart';
import '../models/company_model.dart';
import '../services/db_service.dart';

enum CompanyLoadState { initial, loading, loaded, error }

class CompanyProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  CompanyLoadState _state = CompanyLoadState.initial;
  List<DeliveryCompany> _companies = [];
  List<DeliveryCompany> _filteredCompanies = [];
  String? _errorMessage;
  String? _searchQuery;

  // Getters
  CompanyLoadState get state => _state;
  List<DeliveryCompany> get companies => _filteredCompanies;
  List<DeliveryCompany> get allCompanies => _companies;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == CompanyLoadState.loading;
  bool get hasError => _state == CompanyLoadState.error;
  String? get searchQuery => _searchQuery;

  // Initialize and load companies
  Future<void> initialize() async {
    await loadAllCompanies();
  }

  // Load all companies
  Future<void> loadAllCompanies() async {
    try {
      _setState(CompanyLoadState.loading);
      _companies = await _dbService.getAllCompanies();
      _applyFilters();
      _setState(CompanyLoadState.loaded);
    } catch (e) {
      _setError('Failed to load companies: $e');
    }
  }

  // Create new company
  Future<bool> createCompany(DeliveryCompany company) async {
    try {
      final companyId = await _dbService.createCompany(company);
      final newCompany = company.copyWith(id: companyId);
      _companies.add(newCompany);
      _sortCompanies();
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create company: $e');
      return false;
    }
  }

  // Update company
  Future<bool> updateCompany(String companyId, Map<String, dynamic> updates) async {
    try {
      await _dbService.updateCompany(companyId, updates);
      
      // Update local company
      final companyIndex = _companies.indexWhere((company) => company.id == companyId);
      if (companyIndex != -1) {
        // Reload the updated company from database to ensure consistency
        final updatedCompany = await _dbService.getCompanyById(companyId);
        if (updatedCompany != null) {
          _companies[companyIndex] = updatedCompany;
          _sortCompanies();
          _applyFilters();
          notifyListeners();
        }
      }
      return true;
    } catch (e) {
      _setError('Failed to update company: $e');
      return false;
    }
  }

  // Delete company
  Future<bool> deleteCompany(String companyId) async {
    try {
      await _dbService.deleteCompany(companyId);
      _companies.removeWhere((company) => company.id == companyId);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete company: $e');
      return false;
    }
  }

  // Get company by ID
  DeliveryCompany? getCompanyById(String companyId) {
    try {
      return _companies.firstWhere((company) => company.id == companyId);
    } catch (e) {
      return null;
    }
  }

  // Search companies
  void setSearchQuery(String? query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = null;
    _applyFilters();
    notifyListeners();
  }

  // Apply search filter
  void _applyFilters() {
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      _filteredCompanies = List.from(_companies);
    } else {
      final query = _searchQuery!.toLowerCase();
      _filteredCompanies = _companies.where((company) {
        return company.name.toLowerCase().contains(query) ||
               company.address.toLowerCase().contains(query) ||
               company.contact.toLowerCase().contains(query);
      }).toList();
    }
  }

  // Sort companies alphabetically by name
  void _sortCompanies() {
    _companies.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  // Get company statistics
  Map<String, dynamic> getCompanyStatistics() {
    return {
      'total': _companies.length,
      'filtered': _filteredCompanies.length,
    };
  }

  // Check if company name already exists
  bool isCompanyNameExists(String name, {String? excludeId}) {
    return _companies.any((company) => 
        company.name.toLowerCase() == name.toLowerCase() && 
        company.id != excludeId);
  }

  // Get companies for dropdown/selection
  List<DeliveryCompany> getCompaniesForSelection() {
    return List.from(_companies)..sort((a, b) => a.name.compareTo(b.name));
  }

  // Refresh companies
  Future<void> refresh() async {
    await loadAllCompanies();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == CompanyLoadState.error) {
      _setState(CompanyLoadState.loaded);
    }
  }

  // Private helper methods
  void _setState(CompanyLoadState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _state = CompanyLoadState.error;
    _errorMessage = message;
    notifyListeners();
  }
}
