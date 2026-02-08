import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotpot/providers/menu_provider.dart';
import 'package:hotpot/providers/cart_provider.dart';
import 'package:hotpot/models/menu_item.dart';
import 'package:hotpot/models/user.dart';

class CustomerMenuScreen extends StatefulWidget {
  final User? user;

  const CustomerMenuScreen({super.key, this.user});

  @override
  State<CustomerMenuScreen> createState() => _CustomerMenuScreenState();
}

class _CustomerMenuScreenState extends State<CustomerMenuScreen> {
  MenuCategory? _selectedCategory;
  bool _menuLoaded = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = MenuCategory.broth;
    // Load menu items once when screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_menuLoaded) {
        context.read<MenuProvider>().loadMenuItems();
        setState(() => _menuLoaded = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Hotpot'), centerTitle: true),
      body: Column(
        children: [
          // Category tabs
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children:
                  MenuCategory.values.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(
                          category.label,
                          style: TextStyle(
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        backgroundColor: Colors.grey[200],
                        selectedColor: Colors.red,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                    );
                  }).toList(),
            ),
          ),
          // Menu items
          Expanded(
            child: Consumer<MenuProvider>(
              builder: (context, menuProvider, _) {
                if (menuProvider.allMenuItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Memuat menu...'),
                      ],
                    ),
                  );
                }

                final items =
                    menuProvider.menuByCategory[_selectedCategory] ?? [];

                if (items.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada menu untuk kategori ini'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildMenuCard(item, context);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/cart', arguments: widget.user);
        },
        label: Consumer<CartProvider>(
          builder: (context, cart, _) {
            return Text('Keranjang (${cart.itemCount})');
          },
        ),
        icon: const Icon(Icons.shopping_cart),
      ),
    );
  }

  void _showAddToCartDialog(MenuItem item, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddToCartDialog(item: item),
    );
  }

  Widget _buildMenuCard(MenuItem item, BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          _showAddToCartDialog(item, context);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child:
                  item.image != null && item.image!.isNotEmpty
                      ? Image.network(
                        item.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          );
                        },
                      )
                      : _buildImagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${item.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 100,
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 40, color: Colors.grey[700]),
            const SizedBox(height: 4),
            Text(
              'No Image',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddToCartDialog extends StatefulWidget {
  final MenuItem item;

  const _AddToCartDialog({required this.item});

  @override
  State<_AddToCartDialog> createState() => _AddToCartDialogState();
}

class _AddToCartDialogState extends State<_AddToCartDialog> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = 1;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.item.description),
          const SizedBox(height: 16),
          Text('Harga: Rp ${widget.item.price.toStringAsFixed(0)}'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (quantity > 1) {
                    setState(() => quantity--);
                  }
                },
                icon: const Icon(Icons.remove),
              ),
              Text(quantity.toString(), style: const TextStyle(fontSize: 16)),
              IconButton(
                onPressed: () {
                  setState(() => quantity++);
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<CartProvider>().addItem(widget.item, quantity);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.item.name} ditambahkan ke keranjang'),
              ),
            );
          },
          child: const Text('Tambahkan'),
        ),
      ],
    );
  }
}

extension MenuCategoryLabels on MenuCategory {
  String get label {
    const categoryLabels = {
      MenuCategory.broth: 'Kuah',
      MenuCategory.beef: 'Daging Sapi',
      MenuCategory.chicken: 'Ayam',
      MenuCategory.seafood: 'Hasil Laut',
      MenuCategory.vegetable: 'Sayuran',
      MenuCategory.tofu: 'Tahu',
      MenuCategory.noodle: 'Mie',
      MenuCategory.rice: 'Nasi',
      MenuCategory.drink: 'Minuman',
      MenuCategory.dessert: 'Dessert',
    };
    return categoryLabels[this] ?? name;
  }
}
