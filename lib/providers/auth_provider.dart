import 'package:flutter/foundation.dart';
import 'package:hotpot/models/user.dart';
import 'package:hotpot/services/database_service.dart';
import 'package:hotpot/services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final FirebaseService _firebaseService = FirebaseService();

  // Mock data untuk web testing - create once
  static final Map<String, Map<String, dynamic>> _mockUsersData = {
    'owner': {
      'username': 'owner',
      'password': 'owner123',
      'role': 'owner',
      'name': 'Owner',
      'email': 'owner@hotpot.com',
    },
    'cashier': {
      'username': 'cashier',
      'password': 'cashier123',
      'role': 'cashier',
      'name': 'Kasir',
      'email': 'cashier@hotpot.com',
    },
    'customer1': {
      'username': 'customer1',
      'password': 'customer123',
      'role': 'customer',
      'name': 'Konsumen 1',
      'email': 'customer1@hotpot.com',
    },
    'customer2': {
      'username': 'customer2',
      'password': 'customer123',
      'role': 'customer',
      'name': 'Konsumen 2',
      'email': 'customer2@hotpot.com',
    },
    'customer3': {
      'username': 'customer3',
      'password': 'customer123',
      'role': 'customer',
      'name': 'Konsumen 3',
      'email': 'customer3@hotpot.com',
    },
  };

  User? _currentUser;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  bool get _isWeb => kIsWeb;

  Future<bool> login(String username, String password) async {
    try {
      print('[Auth] Login attempt: $username on web: $_isWeb');

      // Try Firebase first
      try {
        final mockData = _mockUsersData[username];
        if (mockData != null) {
          final user = await _firebaseService.loginUser(
            mockData['email'],
            password,
          );
          if (user != null) {
            print('[Auth] Firebase login success');
            _currentUser = user;
            _isLoggedIn = true;
            notifyListeners();
            return true;
          }
        }
      } catch (fbError) {
        print('[Auth] Firebase error, fallback to database: $fbError');
      }

      // Try database second (untuk mobile/desktop)
      if (!_isWeb) {
        try {
          final user = await _db.getUserByUsernamePassword(username, password);
          if (user != null) {
            print('[Auth] Database login success');
            _currentUser = user;
            _isLoggedIn = true;
            notifyListeners();
            return true;
          }
        } catch (dbError) {
          print('[Auth] Database error, fallback to mock: $dbError');
        }
      }

      // Gunakan mock data untuk web atau fallback
      print('[Auth] Using mock data for login');
      final mockData = _mockUsersData[username];
      if (mockData != null && mockData['password'] == password) {
        print('[Auth] Mock login success');
        _currentUser = User(
          username: mockData['username'],
          password: mockData['password'],
          role: _roleFromString(mockData['role']),
          name: mockData['name'],
        );
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }

      print('[Auth] Login failed - user not found or wrong password');
      return false;
    } catch (e) {
      print('[Auth] Login error: $e');
      return false;
    }
  }

  UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return UserRole.owner;
      case 'cashier':
        return UserRole.cashier;
      default:
        return UserRole.customer;
    }
  }

  Future<bool> registerCustomer(
    String username,
    String password,
    String name,
  ) async {
    try {
      // Cek username sudah ada
      if (_mockUsersData.containsKey(username)) {
        return false;
      }

      // Daftar ke Firebase
      final email = '$username@hotpot.com';
      bool firebaseSuccess = await _firebaseService.registerUser(
        email: email,
        password: password,
        username: username,
        name: name,
        role: 'customer',
      );

      if (!firebaseSuccess) {
        print('Firebase registration failed');
        return false;
      }

      // Untuk web, simpan ke mock
      if (_isWeb) {
        _mockUsersData[username] = {
          'username': username,
          'password': password,
          'role': 'customer',
          'name': name,
          'email': email,
        };
        return true;
      }

      // Untuk mobile, simpan ke database
      final existingUser = await _db.getUserByUsernamePassword(
        username,
        password,
      );
      if (existingUser != null) {
        return false;
      }

      final newUser = User(
        username: username,
        password: password,
        role: UserRole.customer,
        name: name,
      );

      await _db.insertUser(newUser);
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseService.logoutUser();
    } catch (e) {
      print('Firebase logout error: $e');
    }
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
