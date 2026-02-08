import 'package:flutter/foundation.dart';
import 'package:hotpot/models/menu_item.dart';
import 'package:hotpot/services/database_service.dart';
import 'package:hotpot/services/firebase_service.dart';

class MenuProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final FirebaseService _firebaseService = FirebaseService();

  // Cache untuk menu yang sudah di-load
  static bool _isMenuLoaded = false;
  static List<MenuItem> _cachedMenuItems = [];
  static Map<MenuCategory, List<MenuItem>> _cachedMenuByCategory = {};

  // Mock menu untuk web testing
  static final List<MenuItem> _mockMenuItems = [
    // ===== KUAH HOTPOT =====
    MenuItem(
      id: 1,
      name: 'Kuah Original',
      description: 'Kuah asli yang nikmat dengan aromaterapi menyegarkan',
      price: 35000,
      category: MenuCategory.broth,
      isAvailable: true,
    ),
    MenuItem(
      id: 2,
      name: 'Kuah Pedas',
      description: 'Kuah panas dengan cabai pilihan level 3',
      price: 35000,
      category: MenuCategory.broth,
      isAvailable: true,
    ),
    MenuItem(
      id: 3,
      name: 'Kuah Tom Yum',
      description: 'Kuah asam pedas dengan serai dan jeruk nipis',
      price: 40000,
      category: MenuCategory.broth,
      isAvailable: true,
    ),
    MenuItem(
      id: 4,
      name: 'Kuah Ayam Putih',
      description: 'Kuah dari kaldu ayam berkualitas premium',
      price: 38000,
      category: MenuCategory.broth,
      isAvailable: true,
    ),
    MenuItem(
      id: 5,
      name: 'Kuah Tulang Sapi',
      description: 'Kuah kaya dari rebusan tulang sapi 12 jam',
      price: 45000,
      category: MenuCategory.broth,
      isAvailable: true,
    ),

    // ===== DAGING SAPI =====
    MenuItem(
      id: 10,
      name: 'Wagyu Premium',
      description: 'Daging wagyu asli Jepang dengan marbling sempurna',
      price: 185000,
      category: MenuCategory.beef,
      isAvailable: true,
    ),
    MenuItem(
      id: 11,
      name: 'Beef Sliced US',
      description: 'Irisan daging sapi premium dari Amerika',
      price: 125000,
      category: MenuCategory.beef,
      isAvailable: true,
    ),
    MenuItem(
      id: 12,
      name: 'Sirloin Potongan',
      description: 'Potongan sirloin tebal empuk berkualitas tinggi',
      price: 95000,
      category: MenuCategory.beef,
      isAvailable: true,
    ),
    MenuItem(
      id: 13,
      name: 'Beef Brisket',
      description: 'Daging brisket lembut dan berlemak',
      price: 85000,
      category: MenuCategory.beef,
      isAvailable: true,
    ),
    MenuItem(
      id: 14,
      name: 'Meatball Beef',
      description: 'Bola daging sapi lembut dengan bumbu pilihan',
      price: 65000,
      category: MenuCategory.beef,
      isAvailable: true,
    ),

    // ===== AYAM =====
    MenuItem(
      id: 20,
      name: 'Dada Ayam Slice',
      description: 'Irisan dada ayam segar tanpa lemak',
      price: 65000,
      category: MenuCategory.chicken,
      isAvailable: true,
    ),
    MenuItem(
      id: 21,
      name: 'Paha Ayam Premium',
      description: 'Potongan paha ayam empuk dan berempah',
      price: 55000,
      category: MenuCategory.chicken,
      isAvailable: true,
    ),
    MenuItem(
      id: 22,
      name: 'Chicken Meatball',
      description: 'Bola daging ayam homemade lembut dan juicy',
      price: 48000,
      category: MenuCategory.chicken,
      isAvailable: true,
    ),
    MenuItem(
      id: 23,
      name: 'Ayam Goreng Potong',
      description: 'Potongan ayam goreng crispy siap makan',
      price: 45000,
      category: MenuCategory.chicken,
      isAvailable: true,
    ),

    // ===== HASIL LAUT =====
    MenuItem(
      id: 30,
      name: 'Udang Tiger Premium',
      description: 'Udang tiger besar segar dari laut',
      price: 145000,
      category: MenuCategory.seafood,
      isAvailable: true,
    ),
    MenuItem(
      id: 31,
      name: 'Cumi-Cumi Fresh',
      description: 'Cumi-cumi segar dengan tekstur lembut',
      price: 95000,
      category: MenuCategory.seafood,
      isAvailable: true,
    ),
    MenuItem(
      id: 32,
      name: 'Ikan Salmon',
      description: 'Fillet salmon Norwegia berkualitas A',
      price: 125000,
      category: MenuCategory.seafood,
      isAvailable: true,
    ),
    MenuItem(
      id: 33,
      name: 'Kerang Hijau',
      description: 'Kerang hijau segar dengan rasa asin alami',
      price: 65000,
      category: MenuCategory.seafood,
      isAvailable: true,
    ),
    MenuItem(
      id: 34,
      name: 'Seafood Mix',
      description: 'Campuran udang, cumi, dan ikan pilihan',
      price: 135000,
      category: MenuCategory.seafood,
      isAvailable: true,
    ),

    // ===== SAYURAN =====
    MenuItem(
      id: 40,
      name: 'Sayuran Hijau Segar',
      description: 'Campuran selada, kangkung, dan bayam organik',
      price: 28000,
      category: MenuCategory.vegetable,
      isAvailable: true,
    ),
    MenuItem(
      id: 41,
      name: 'Jamur Campuran',
      description: 'Jamur shiitake, enoki, dan oyster pilihan',
      price: 35000,
      category: MenuCategory.vegetable,
      isAvailable: true,
    ),
    MenuItem(
      id: 42,
      name: 'Brokoli & Kembang Kol',
      description: 'Brokoli dan kembang kol segar dipotong kecil',
      price: 32000,
      category: MenuCategory.vegetable,
      isAvailable: true,
    ),
    MenuItem(
      id: 43,
      name: 'Jagung Manis & Wortel',
      description: 'Jagung manis dan wortel potong sesuai selera',
      price: 25000,
      category: MenuCategory.vegetable,
      isAvailable: true,
    ),
    MenuItem(
      id: 44,
      name: 'Tomat & Bawang Prei',
      description: 'Tomat merah segar dan bawang prei hijau',
      price: 20000,
      category: MenuCategory.vegetable,
      isAvailable: true,
    ),

    // ===== TAHU & SEJENISNYA =====
    MenuItem(
      id: 50,
      name: 'Tahu Putih Premium',
      description: 'Tahu putih lembut dari kedelai pilihan',
      price: 22000,
      category: MenuCategory.tofu,
      isAvailable: true,
    ),
    MenuItem(
      id: 51,
      name: 'Tahu Goreng',
      description: 'Tahu goreng golden crispy di luar empuk di dalam',
      price: 25000,
      category: MenuCategory.tofu,
      isAvailable: true,
    ),
    MenuItem(
      id: 52,
      name: 'Telur Puyuh',
      description: 'Telur puyuh segar siap langsung dimakan',
      price: 18000,
      category: MenuCategory.tofu,
      isAvailable: true,
    ),
    MenuItem(
      id: 53,
      name: 'Bakso Ikan',
      description: 'Bakso ikan putih homemade lembut',
      price: 38000,
      category: MenuCategory.tofu,
      isAvailable: true,
    ),
    MenuItem(
      id: 54,
      name: 'Surimi Stick',
      description: 'Stick surimi import dengan tekstur chewy',
      price: 32000,
      category: MenuCategory.tofu,
      isAvailable: true,
    ),

    // ===== MIE & KARBO =====
    MenuItem(
      id: 60,
      name: 'Mie Kuning',
      description: 'Mie kuning tradisional yang gurih dan lembut',
      price: 18000,
      category: MenuCategory.noodle,
      isAvailable: true,
    ),
    MenuItem(
      id: 61,
      name: 'Mie Putih',
      description: 'Mie putih segar dengan tekstur halus',
      price: 18000,
      category: MenuCategory.noodle,
      isAvailable: true,
    ),
    MenuItem(
      id: 62,
      name: 'Ramen Telur',
      description: 'Mie ramen spiral dengan telur puyuh',
      price: 28000,
      category: MenuCategory.noodle,
      isAvailable: true,
    ),
    MenuItem(
      id: 63,
      name: 'Glass Noodle',
      description: 'Mie bening transparan lembut dan kenyal',
      price: 22000,
      category: MenuCategory.noodle,
      isAvailable: true,
    ),
    MenuItem(
      id: 64,
      name: 'Kentang Goreng',
      description: 'Kentang goreng crispy golden brown',
      price: 20000,
      category: MenuCategory.noodle,
      isAvailable: true,
    ),

    // ===== NASI =====
    MenuItem(
      id: 70,
      name: 'Nasi Putih',
      description: 'Nasi putih fluffy matang sempurna',
      price: 12000,
      category: MenuCategory.rice,
      isAvailable: true,
    ),
    MenuItem(
      id: 71,
      name: 'Nasi Goreng Telur',
      description: 'Nasi goreng spesial dengan telur ceplok',
      price: 28000,
      category: MenuCategory.rice,
      isAvailable: true,
    ),
    MenuItem(
      id: 72,
      name: 'Nasi Goreng Ayam',
      description: 'Nasi goreng dengan potongan ayam premium',
      price: 32000,
      category: MenuCategory.rice,
      isAvailable: true,
    ),
    MenuItem(
      id: 73,
      name: 'Nasi Goreng Seafood',
      description: 'Nasi goreng istimewa dengan udang dan cumi',
      price: 38000,
      category: MenuCategory.rice,
      isAvailable: true,
    ),

    // ===== MINUMAN =====
    MenuItem(
      id: 80,
      name: 'Es Teh Manis',
      description: 'Teh hitam dingin dengan rasa manis pas',
      price: 8000,
      category: MenuCategory.drink,
      isAvailable: true,
    ),
    MenuItem(
      id: 81,
      name: 'Es Jeruk Nipis',
      description: 'Minuman segar dari jeruk nipis asli',
      price: 10000,
      category: MenuCategory.drink,
      isAvailable: true,
    ),
    MenuItem(
      id: 82,
      name: 'Es Lemon Tea',
      description: 'Teh premium dengan potongan lemon segar',
      price: 12000,
      category: MenuCategory.drink,
      isAvailable: true,
    ),
    MenuItem(
      id: 83,
      name: 'Kopi Iced',
      description: 'Kopi premium es dengan susu kental',
      price: 15000,
      category: MenuCategory.drink,
      isAvailable: true,
    ),
    MenuItem(
      id: 84,
      name: 'Air Mineral',
      description: 'Air mineral dingin dari brand ternama',
      price: 5000,
      category: MenuCategory.drink,
      isAvailable: true,
    ),

    // ===== DESSERT =====
    MenuItem(
      id: 90,
      name: 'Pudding Coklat',
      description: 'Pudding coklat lembut dengan topping whipped cream',
      price: 18000,
      category: MenuCategory.dessert,
      isAvailable: true,
    ),
    MenuItem(
      id: 91,
      name: 'Es Krim Vanilla',
      description: 'Es krim vanilla premium dari label terkenal',
      price: 15000,
      category: MenuCategory.dessert,
      isAvailable: true,
    ),
    MenuItem(
      id: 92,
      name: 'Soto Ayam Dessert',
      description: 'Manisan tradisional soto ayam yang unik',
      price: 12000,
      category: MenuCategory.dessert,
      isAvailable: true,
    ),
    MenuItem(
      id: 93,
      name: 'Panna Cotta',
      description: 'Panna cotta Italia dengan krim lembut',
      price: 22000,
      category: MenuCategory.dessert,
      isAvailable: true,
    ),
  ];

  List<MenuItem> _allMenuItems = [];
  Map<MenuCategory, List<MenuItem>> _menuByCategory = {};

  List<MenuItem> get allMenuItems => _allMenuItems;
  Map<MenuCategory, List<MenuItem>> get menuByCategory => _menuByCategory;

  bool get _isWeb => kIsWeb;

  Future<void> loadMenuItems() async {
    try {
      // Clear cache pada web untuk force reload saat kategori mungkin berubah
      if (_isWeb && _isMenuLoaded) {
        // Jika sudah load sebelumnya dan masih cache, reload dari Firebase
        // Ini memastikan data terbaru dimuat
        print('[Menu] Clearing cache dan reload dari Firebase...');
        _isMenuLoaded = false;
        _cachedMenuItems = [];
        _cachedMenuByCategory = {};
      }

      // Gunakan cache jika sudah pernah di-load sebelumnya dan valid
      if (_isMenuLoaded && _cachedMenuItems.isNotEmpty) {
        _allMenuItems = _cachedMenuItems;
        _menuByCategory = _cachedMenuByCategory;
        notifyListeners();
        return;
      }

      // Seed Firebase jika kosong (di web platform)
      if (_isWeb) {
        try {
          await _firebaseService.seedMenuItemsIfEmpty();
        } catch (e) {
          print('[Menu] Seed Firebase error: $e');
        }
      }

      // Try Firebase first
      List<MenuItem> firebaseItems = [];
      try {
        firebaseItems = await _firebaseService.getMenuItems();
        print('[Menu] Loaded ${firebaseItems.length} items from Firebase');
      } catch (e) {
        print('[Menu] Firebase error, fallback to database: $e');
      }

      // Gunakan Firebase items di web (untuk persistensi)
      if (_isWeb) {
        // Di web, HANYA gunakan Firebase items + mock items sebagai fallback
        _allMenuItems =
            firebaseItems.isNotEmpty ? firebaseItems : _mockMenuItems;
        print('[Menu] Web platform - using ${_allMenuItems.length} items');
      } else {
        // Try database
        try {
          final dbItems = await _db.getAllMenuItems();
          if (dbItems.isNotEmpty) {
            _allMenuItems = dbItems;
            print(
              '[Menu] Mobile platform - using ${_allMenuItems.length} items from database',
            );
          } else {
            // Use Firebase items or mock
            _allMenuItems =
                firebaseItems.isNotEmpty ? firebaseItems : _mockMenuItems;
            print(
              '[Menu] Mobile platform - DB empty, using ${_allMenuItems.length} items from Firebase or mock',
            );
          }
        } catch (e) {
          print('[Menu] Database error: $e');
          _allMenuItems =
              firebaseItems.isNotEmpty ? firebaseItems : _mockMenuItems;
        }
      }

      // Group by category secara efisien
      _menuByCategory = {};
      for (var category in MenuCategory.values) {
        final items =
            _allMenuItems.where((item) => item.category == category).toList();
        if (items.isNotEmpty) {
          _menuByCategory[category] = items;
          print(
            '[Menu] Category ${category.toString()}: ${items.length} items',
          );
        }
      }
      print('[Menu] Total categories with items: ${_menuByCategory.length}');

      // Cache hasil loading
      _cachedMenuItems = _allMenuItems;
      _cachedMenuByCategory = _menuByCategory;
      _isMenuLoaded = true;

      notifyListeners();
    } catch (e) {
      print('Error loading menu items: $e');
      // Fallback ke mock data
      _allMenuItems = _mockMenuItems;
      _menuByCategory = {};
      for (var category in MenuCategory.values) {
        final items =
            _allMenuItems.where((item) => item.category == category).toList();
        if (items.isNotEmpty) {
          _menuByCategory[category] = items;
        }
      }
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> addMenuItem(MenuItem item) async {
    try {
      if (_isWeb) {
        // For web: ONLY save to Firebase for persistence
        bool firebaseSuccess = await _firebaseService.addMenuItem(item);
        if (!firebaseSuccess) {
          return {
            'success': false,
            'message':
                '❌ Firebase Error - Tidak dapat terhubung ke server\n\nPastikan:\n• Firebase Console sudah setup\n• Internet aktif\n• Firestore Database aktif di Firebase',
          };
        }
        // Clear cache agar item baru ditampilkan dari Firebase
        _isMenuLoaded = false;
        await loadMenuItems();
        return {
          'success': true,
          'message': '✅ Menu berhasil ditambahkan dan disimpan',
        };
      } else {
        // For mobile/desktop: try Firebase first, fallback to database
        bool firebaseSuccess = await _firebaseService.addMenuItem(item);

        try {
          // Also save to local database as backup
          await _db.insertMenuItem(item);
        } catch (dbError) {
          print('Local database error (backup): $dbError');
        }

        if (!firebaseSuccess) {
          print('Firebase gagal, tapi data tersimpan di local database');
        }

        // Clear cache agar item baru ditampilkan
        _isMenuLoaded = false;
        await loadMenuItems();
        return {'success': true, 'message': '✅ Menu berhasil ditambahkan'};
      }
    } catch (e) {
      final errorMsg =
          'Gagal menambahkan menu karena: ${e.toString().replaceAll('Exception: ', '')}';
      print('Error adding menu item: $errorMsg');
      return {
        'success': false,
        'message':
            '❌ Gagal Menyimpan\n\n$errorMsg\n\nPastikan Firebase Console sudah dikonfigurasi dengan benar',
      };
    }
  }

  Future<Map<String, dynamic>> updateMenuItem(MenuItem item) async {
    try {
      // Use docId for Firebase operations (it's the actual document ID)
      final String updateId = item.docId ?? item.id?.toString() ?? '';

      if (updateId.isEmpty) {
        return {
          'success': false,
          'message': '❌ Error: Tidak dapat menemukan ID menu untuk diperbarui',
        };
      }

      if (_isWeb) {
        // For web: ONLY update Firebase for persistence
        bool firebaseSuccess = await _firebaseService.updateMenuItem(
          updateId,
          item,
        );
        if (!firebaseSuccess) {
          return {
            'success': false,
            'message':
                '❌ Firebase Error - Tidak dapat terhubung ke server\n\nPastikan:\n• Firebase Console sudah setup\n• Internet aktif\n• Firestore Database aktif',
          };
        }
        // Clear cache agar update ditampilkan dari Firebase
        _isMenuLoaded = false;
        await loadMenuItems();
        return {
          'success': true,
          'message': '✅ Menu berhasil diperbarui dan disimpan',
        };
      } else {
        // For mobile/desktop: try Firebase first, fallback to database
        bool firebaseSuccess = await _firebaseService.updateMenuItem(
          updateId,
          item,
        );

        try {
          // Also save to local database as backup
          await _db.updateMenuItem(item);
        } catch (dbError) {
          print('Local database error (backup): $dbError');
        }

        if (!firebaseSuccess) {
          print('Firebase gagal, tapi data tersimpan di local database');
        }

        // Clear cache agar update ditampilkan
        _isMenuLoaded = false;
        await loadMenuItems();
        return {'success': true, 'message': '✅ Menu berhasil diperbarui'};
      }
    } catch (e) {
      final errorMsg =
          'Gagal memperbarui menu karena: ${e.toString().replaceAll('Exception: ', '')}';
      print('Error updating menu item: $errorMsg');
      return {
        'success': false,
        'message':
            '❌ Gagal Menyimpan\n\n$errorMsg\n\nPastikan Firebase Console sudah dikonfigurasi dengan benar',
      };
    }
  }

  Future<Map<String, dynamic>> deleteMenuItem(MenuItem item) async {
    try {
      // Use docId for Firebase deletion (it's the actual document ID)
      final String deleteId = item.docId ?? item.id?.toString() ?? '';

      if (deleteId.isEmpty) {
        return {
          'success': false,
          'message': '❌ Error: Tidak dapat menemukan ID menu untuk dihapus',
        };
      }

      if (_isWeb) {
        // For web: ONLY delete from Firebase for persistence
        bool firebaseSuccess = await _firebaseService.deleteMenuItem(deleteId);
        if (!firebaseSuccess) {
          return {
            'success': false,
            'message':
                '❌ Firebase Error - Tidak dapat terhubung ke server\n\nPastikan:\n• Firebase Console sudah setup\n• Internet aktif\n• Firestore Database aktif',
          };
        }
        // Clear cache agar delete ditampilkan dari Firebase
        _isMenuLoaded = false;
        await loadMenuItems();
        return {
          'success': true,
          'message': '✅ Menu berhasil dihapus dan disimpan',
        };
      } else {
        // For mobile/desktop: try Firebase first, fallback to database
        bool firebaseSuccess = await _firebaseService.deleteMenuItem(deleteId);

        try {
          // Also delete from local database as backup
          if (item.id != null) {
            await _db.deleteMenuItem(item.id!);
          }
        } catch (dbError) {
          print('Local database error (backup): $dbError');
        }

        if (!firebaseSuccess) {
          print('Firebase gagal, tapi data dihapus dari local database');
        }

        // Clear cache agar delete ditampilkan
        _isMenuLoaded = false;
        await loadMenuItems();
        return {'success': true, 'message': '✅ Menu berhasil dihapus'};
      }
    } catch (e) {
      final errorMsg =
          'Gagal menghapus menu karena: ${e.toString().replaceAll('Exception: ', '')}';
      print('Error deleting menu item: $errorMsg');
      return {
        'success': false,
        'message':
            '❌ Gagal Menyimpan\n\n$errorMsg\n\nPastikan Firebase Console sudah dikonfigurasi dengan benar',
      };
    }
  }
}
