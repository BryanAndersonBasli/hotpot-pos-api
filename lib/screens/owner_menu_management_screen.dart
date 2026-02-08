import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotpot/providers/menu_provider.dart';
import 'package:hotpot/models/menu_item.dart';

class OwnerMenuManagementScreen extends StatefulWidget {
  const OwnerMenuManagementScreen({super.key});

  @override
  State<OwnerMenuManagementScreen> createState() =>
      _OwnerMenuManagementScreenState();
}

class _OwnerMenuManagementScreenState extends State<OwnerMenuManagementScreen> {
  MenuCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = MenuCategory.broth;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Menu'), centerTitle: true),
      body: Column(
        children: [
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
                        label: Text(category.name.toUpperCase()),
                        selected: isSelected,
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
          Expanded(
            child: Consumer<MenuProvider>(
              builder: (context, menuProvider, _) {
                final items =
                    menuProvider.menuByCategory[_selectedCategory] ?? [];

                if (items.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada menu untuk kategori ini'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildMenuItemTile(item, context, menuProvider);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenuDialog(context),
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMenuItemTile(
    MenuItem item,
    BuildContext context,
    MenuProvider menuProvider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text('Rp ${item.price.toStringAsFixed(0)}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  child: const Text('Edit'),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      _showEditMenuDialog(context, item, menuProvider);
                    });
                  },
                ),
                PopupMenuItem(
                  child: const Text('Hapus'),
                  onTap: () {
                    _showDeleteConfirmation(context, item, menuProvider);
                  },
                ),
              ],
        ),
      ),
    );
  }

  void _showAddMenuDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    MenuCategory selectedCategory = _selectedCategory ?? MenuCategory.broth;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Tambah Menu'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Menu',
                          ),
                        ),
                        TextField(
                          controller: descController,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi',
                          ),
                          maxLines: 2,
                        ),
                        TextField(
                          controller: priceController,
                          decoration: const InputDecoration(labelText: 'Harga'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        DropdownButton<MenuCategory>(
                          value: selectedCategory,
                          isExpanded: true,
                          items:
                              MenuCategory.values
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.name),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedCategory = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty ||
                            descController.text.isEmpty ||
                            priceController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Semua field harus diisi'),
                            ),
                          );
                          return;
                        }

                        try {
                          final price = double.parse(priceController.text);
                          if (price <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Harga harus lebih dari 0'),
                              ),
                            );
                            return;
                          }

                          final newItem = MenuItem(
                            name: nameController.text,
                            description: descController.text,
                            price: price,
                            category: selectedCategory,
                          );

                          final result = await context
                              .read<MenuProvider>()
                              .addMenuItem(newItem);
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message']),
                                backgroundColor:
                                    result['success']
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Format harga tidak valid. Gunakan angka (contoh: 50000)',
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Tambah'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showEditMenuDialog(
    BuildContext context,
    MenuItem item,
    MenuProvider menuProvider,
  ) {
    final nameController = TextEditingController(text: item.name);
    final descController = TextEditingController(text: item.description);
    final priceController = TextEditingController(text: item.price.toString());
    MenuCategory selectedCategory = item.category;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Edit Menu'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Menu',
                          ),
                        ),
                        TextField(
                          controller: descController,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi',
                          ),
                          maxLines: 2,
                        ),
                        TextField(
                          controller: priceController,
                          decoration: const InputDecoration(labelText: 'Harga'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        DropdownButton<MenuCategory>(
                          value: selectedCategory,
                          isExpanded: true,
                          items:
                              MenuCategory.values
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.name),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedCategory = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty ||
                            descController.text.isEmpty ||
                            priceController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Semua field harus diisi'),
                            ),
                          );
                          return;
                        }

                        try {
                          final price = double.parse(priceController.text);
                          if (price <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Harga harus lebih dari 0'),
                              ),
                            );
                            return;
                          }

                          final updatedItem = item.copyWith(
                            name: nameController.text,
                            description: descController.text,
                            price: price,
                            category: selectedCategory,
                          );

                          final result = await menuProvider.updateMenuItem(
                            updatedItem,
                          );
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message']),
                                backgroundColor:
                                    result['success']
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Format harga tidak valid. Gunakan angka (contoh: 50000)',
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    MenuItem item,
    MenuProvider menuProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Menu'),
            content: Text('Apakah Anda yakin ingin menghapus "${item.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await menuProvider.deleteMenuItem(item);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message']),
                        backgroundColor:
                            result['success'] ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
