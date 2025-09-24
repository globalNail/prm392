import 'package:flutter/foundation.dart';
import '../models/account.dart';
import '../models/product.dart';

/// Abstract storage service that can be implemented for different platforms
abstract class StorageService {
  Future<void> initialize();

  // Account operations
  Future<List<Account>> getAccounts();
  Future<void> saveAccount(Account account);
  Future<void> deleteAccount(int id);
  Future<Account?> getAccountByCredentials(String username, String password);

  // Product operations
  Future<List<Product>> getProducts();
  Future<void> saveProduct(Product product);
  Future<void> deleteProduct(int id);
  Future<Product?> getProduct(int id);
}

/// Web implementation using localStorage
class WebStorageService implements StorageService {
  final List<Product> _products = [];

  @override
  Future<void> initialize() async {
    // Initialize default data if needed
    if (kDebugMode) {
      print('WebStorageService initialized');
    }

    // Initialize with demo products
    _products.addAll([
      Product(
        id: 1,
        name: 'iPhone 15',
        imageUrl:
            'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-15-plus_1__1.png',
        description: 'Điện thoại thông minh cao cấp của Apple.',
      ),
      Product(
        id: 2,
        name: 'Galaxy S24',
        imageUrl:
            'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcSUDI8WY8vxxqhv4-8SqPmrlJ7MsDM-ThNUh9gpA92So86sMCahJpeovxYtveEAx1Vb9fzQqD0IgVBZp7zPat6a9Z_nfa_p9qkfJVmkzP-VUbsFzSUTzn1i',
        description: 'Flagship Android của Samsung.',
      ),
    ]);
  }

  @override
  Future<List<Account>> getAccounts() async {
    // For web, we'll simulate with hardcoded accounts
    return [Account(id: 1, name: 'Admin', email: 'admin@test.com')];
  }

  @override
  Future<void> saveAccount(Account account) async {
    // For demo purposes, we'll just log
    if (kDebugMode) {
      print('Saving account: ${account.name}');
    }
  }

  @override
  Future<void> deleteAccount(int id) async {
    if (kDebugMode) {
      print('Deleting account: $id');
    }
  }

  @override
  Future<Account?> getAccountByCredentials(
    String username,
    String password,
  ) async {
    // Simple hardcoded check for demo
    if (username == 'admin' && password == '1') {
      return Account(id: 1, name: 'Admin', email: 'admin@test.com');
    }
    return null;
  }

  @override
  Future<List<Product>> getProducts() async {
    return List.from(_products);
  }

  @override
  Future<void> saveProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    } else {
      _products.add(product);
    }
    if (kDebugMode) {
      print('Saving product: ${product.name}');
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    _products.removeWhere((p) => p.id == id);
    if (kDebugMode) {
      print('Deleting product: $id');
    }
  }

  @override
  Future<Product?> getProduct(int id) async {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Mobile implementation using sqflite
class MobileStorageService implements StorageService {
  final List<Product> _products = [];

  @override
  Future<void> initialize() async {
    if (kDebugMode) {
      print('MobileStorageService initialized');
    }

    // Initialize with demo products
    _products.addAll([
      Product(
        id: 1,
        name: 'iPhone 15',
        imageUrl:
            'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-15-plus_1__1.png',
        description: 'Điện thoại thông minh cao cấp của Apple.',
      ),
      Product(
        id: 2,
        name: 'Galaxy S24',
        imageUrl:
            'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcSUDI8WY8vxxqhv4-8SqPmrlJ7MsDM-ThNUh9gpA92So86sMCahJpeovxYtveEAx1Vb9fzQqD0IgVBZp7zPat6a9Z_nfa_p9qkfJVmkzP-VUbsFzSUTzn1i',
        description: 'Flagship Android của Samsung.',
      ),
    ]);
  }

  @override
  Future<List<Account>> getAccounts() async {
    return [Account(id: 1, name: 'Admin', email: 'admin@test.com')];
  }

  @override
  Future<void> saveAccount(Account account) async {
    if (kDebugMode) {
      print('Saving account: ${account.name}');
    }
  }

  @override
  Future<void> deleteAccount(int id) async {
    if (kDebugMode) {
      print('Deleting account: $id');
    }
  }

  @override
  Future<Account?> getAccountByCredentials(
    String username,
    String password,
  ) async {
    if (username == 'admin' && password == '1') {
      return Account(id: 1, name: 'Admin', email: 'admin@test.com');
    }
    return null;
  }

  @override
  Future<List<Product>> getProducts() async {
    return List.from(_products);
  }

  @override
  Future<void> saveProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    } else {
      _products.add(product);
    }
    if (kDebugMode) {
      print('Saving product: ${product.name}');
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    _products.removeWhere((p) => p.id == id);
    if (kDebugMode) {
      print('Deleting product: $id');
    }
  }

  @override
  Future<Product?> getProduct(int id) async {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Factory to create appropriate storage service based on platform
class StorageServiceFactory {
  static StorageService create() {
    if (kIsWeb) {
      return WebStorageService();
    } else {
      return MobileStorageService();
    }
  }
}
