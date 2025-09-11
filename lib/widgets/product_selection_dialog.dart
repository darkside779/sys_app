// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../localization/localization_extension.dart';

class ProductSelectionDialog extends StatefulWidget {
  final List<Product> availableProducts;
  final Function(List<OrderItem>) onProductsSelected;

  const ProductSelectionDialog({
    super.key,
    required this.availableProducts,
    required this.onProductsSelected,
  });

  @override
  State<ProductSelectionDialog> createState() => _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends State<ProductSelectionDialog> {
  final Map<String, int> _selectedQuantities = {};
  final Map<String, TextEditingController> _notesControllers = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    for (var controller in _notesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _getFilteredProducts();

    return AlertDialog(
      title: Text(context.tr.select_products),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: context.tr.search_products,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: filteredProducts.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? context.tr.no_products_match_search
                            : context.tr.no_products_add_first,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final quantity = _selectedQuantities[product.id] ?? 0;
                        
                        if (!_notesControllers.containsKey(product.id)) {
                          _notesControllers[product.id] = TextEditingController();
                        }

                        return Card(
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: quantity > 0 ? Colors.green : Colors.grey,
                              child: Text(
                                product.name.isNotEmpty ? product.name[0].toUpperCase() : 'P',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              product.name,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.description),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        product.category,
                                        style: TextStyle(fontSize: 12, color: Colors.blue),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: quantity > 0 ? () => _updateQuantity(product.id, quantity - 1) : null,
                                  icon: Icon(Icons.remove_circle_outline),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    quantity.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _updateQuantity(product.id, quantity + 1),
                                  icon: Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                            children: [
                              if (quantity > 0)
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${context.tr.order_total}: \$${(product.price * quantity).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.green,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      TextField(
                                        controller: _notesControllers[product.id],
                                        decoration: InputDecoration(
                                          labelText: context.tr.enter_notes,
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr.cancel),
        ),
        ElevatedButton(
          onPressed: _getSelectedItemsCount() > 0 ? _confirmSelection : null,
          child: Text('${context.tr.add_to_order} (${_getSelectedItemsCount()})'),
        ),
      ],
    );
  }

  List<Product> _getFilteredProducts() {
    if (_searchQuery.isEmpty) {
      return widget.availableProducts;
    }
    
    final query = _searchQuery.toLowerCase();
    return widget.availableProducts.where((product) {
      return product.name.toLowerCase().contains(query) ||
             product.description.toLowerCase().contains(query) ||
             product.category.toLowerCase().contains(query);
    }).toList();
  }

  void _updateQuantity(String productId, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _selectedQuantities.remove(productId);
      } else {
        _selectedQuantities[productId] = quantity;
      }
    });
  }

  int _getSelectedItemsCount() {
    return _selectedQuantities.values.fold(0, (sum, qty) => sum + qty);
  }

  void _confirmSelection() {
    final selectedItems = <OrderItem>[];
    
    for (final entry in _selectedQuantities.entries) {
      final productId = entry.key;
      final quantity = entry.value;
      
      final product = widget.availableProducts.firstWhere((p) => p.id == productId);
      final notes = _notesControllers[productId]?.text.trim();
      
      selectedItems.add(OrderItem(
        productId: product.id,
        productName: product.name,
        productPrice: product.price,
        quantity: quantity,
        totalPrice: product.price * quantity,
        notes: notes?.isEmpty == true ? null : notes,
      ));
    }
    
    widget.onProductsSelected(selectedItems);
    Navigator.pop(context);
  }
}
