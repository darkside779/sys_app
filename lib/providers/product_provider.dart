import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get active products only
  List<Product> get activeProducts => _products.where((product) => product.isActive).toList();

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category && product.isActive).toList();
  }

  // Get unique categories
  List<String> get categories {
    final categorySet = <String>{};
    for (final product in _products) {
      if (product.isActive) {
        categorySet.add(product.category);
      }
    }
    return categorySet.toList()..sort();
  }

  // Get product by ID
  Product? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  Future<void> initialize() async {
    await loadAllProducts();
  }

  Future<void> loadAllProducts() async {
    _setLoading(true);
    _clearError();
    
    try {
      final querySnapshot = await _firestore.collection('products').get();
      
      _products = querySnapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), documentId: doc.id);
      }).toList();

      // Sort products by name
      _products.sort((a, b) => a.name.compareTo(b.name));
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load products: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createProduct(Product product) async {
    _clearError();
    
    try {
      final docRef = await _firestore.collection('products').add(product.toMap());
      
      final newProduct = product.copyWith(
        id: docRef.id,
        updatedAt: DateTime.now(),
      );
      
      _products.add(newProduct);
      _products.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to create product: $e');
      return false;
    }
  }

  Future<bool> updateProduct(String productId, Map<String, dynamic> updates) async {
    _clearError();
    
    try {
      updates['updatedAt'] = DateTime.now().toIso8601String();
      
      await _firestore.collection('products').doc(productId).update(updates);
      
      // Update local product
      final index = _products.indexWhere((product) => product.id == productId);
      if (index != -1) {
        final currentProduct = _products[index];
        final updatedProductMap = {
          ...currentProduct.toMap(),
          ...updates,
        };
        
        _products[index] = Product.fromMap(updatedProductMap, documentId: productId);
        _products.sort((a, b) => a.name.compareTo(b.name));
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError('Failed to update product: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    _clearError();
    
    try {
      await _firestore.collection('products').doc(productId).delete();
      
      _products.removeWhere((product) => product.id == productId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to delete product: $e');
      return false;
    }
  }

  Future<bool> toggleProductStatus(String productId) async {
    final product = getProductById(productId);
    if (product == null) return false;
    
    return await updateProduct(productId, {
      'isActive': !product.isActive,
    });
  }

  // Search products by name or description
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return activeProducts;
    
    final lowercaseQuery = query.toLowerCase();
    return activeProducts.where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
             product.description.toLowerCase().contains(lowercaseQuery) ||
             product.category.toLowerCase().contains(lowercaseQuery) ||
             (product.sku?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Get statistics
  Map<String, dynamic> getProductStatistics() {
    return {
      'total': _products.length,
      'active': activeProducts.length,
      'inactive': _products.where((p) => !p.isActive).length,
      'categories': categories.length,
    };
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

}
