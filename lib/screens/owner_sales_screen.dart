import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotpot/providers/sales_provider.dart';
import 'package:hotpot/models/sale.dart' as sale_model;
import 'package:intl/intl.dart';

class OwnerSalesScreen extends StatefulWidget {
  const OwnerSalesScreen({super.key});

  @override
  State<OwnerSalesScreen> createState() => _OwnerSalesScreenState();
}

class _OwnerSalesScreenState extends State<OwnerSalesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  DateTime? _selectedSearchDate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSalesData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadSalesData() {
    context.read<SalesProvider>().loadSaleReportRange(_startDate, _endDate);
  }

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadSalesData();
    }
  }

  void _selectSearchDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedSearchDate = picked;
        _searchController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Harian', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Bulanan', icon: Icon(Icons.calendar_month)),
            Tab(text: 'Cari', icon: Icon(Icons.search)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildDailyView(), _buildMonthlyView(), _buildSearchView()],
      ),
    );
  }

  // ========== DAILY VIEW ==========
  Widget _buildDailyView() {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, _) {
        return RefreshIndicator(
          onRefresh: () async {
            _loadSalesData();
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Summary cards
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Total Pendapatan',
                              value:
                                  'Rp ${salesProvider.getTotalRevenue().toStringAsFixed(0)}',
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Total Pesanan',
                              value: salesProvider.getTotalOrders().toString(),
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCard(
                        title: 'Rata-rata per Pesanan',
                        value:
                            'Rp ${salesProvider.getAverageOrderValue().toStringAsFixed(0)}',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Daily breakdown
                if (salesProvider.dailyReports.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.analytics, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Tidak ada data'),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: salesProvider.dailyReports.length,
                    itemBuilder: (context, index) {
                      final report = salesProvider.dailyReports[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          title: Text(
                            DateFormat(
                              'EEEE, dd MMMM yyyy',
                            ).format(report.date),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pesanan: ${report.totalOrders}'),
                              Text(
                                'Pendapatan: Rp ${report.totalRevenue.toStringAsFixed(0)}',
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showDayDetails(report.date),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ========== MONTHLY VIEW ==========
  Widget _buildMonthlyView() {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, _) {
        // Group daily reports by month
        Map<String, List<sale_model.SaleReport>> monthlyData = {};

        for (var report in salesProvider.dailyReports) {
          String monthKey = DateFormat('MMMM yyyy').format(report.date);
          if (!monthlyData.containsKey(monthKey)) {
            monthlyData[monthKey] = [];
          }
          monthlyData[monthKey]!.add(report);
        }

        return RefreshIndicator(
          onRefresh: () async {
            _loadSalesData();
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Total Pendapatan',
                              value:
                                  'Rp ${salesProvider.getTotalRevenue().toStringAsFixed(0)}',
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Total Pesanan',
                              value: salesProvider.getTotalOrders().toString(),
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),
                if (monthlyData.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.analytics, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Tidak ada data'),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: monthlyData.length,
                    itemBuilder: (context, index) {
                      String monthKey = monthlyData.keys.toList()[index];
                      List<sale_model.SaleReport> reports =
                          monthlyData[monthKey]!;

                      double monthRevenue = reports.fold(
                        0,
                        (sum, r) => sum + r.totalRevenue,
                      );
                      int monthOrders = reports.fold(
                        0,
                        (sum, r) => sum + r.totalOrders,
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          title: Text(monthKey),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pesanan: $monthOrders'),
                              Text(
                                'Pendapatan: Rp ${monthRevenue.toStringAsFixed(0)}',
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.expand_more),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ========== SEARCH VIEW ==========
  Widget _buildSearchView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Pilih tanggal',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onTap: _selectSearchDate,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _selectedSearchDate != null ? () {} : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        if (_selectedSearchDate != null)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Monthly Summary
                  _buildMonthlySearchSummary(_selectedSearchDate!),
                  const Divider(),
                  // Daily Details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Penjualan ${DateFormat('dd MMMM yyyy').format(_selectedSearchDate!)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _buildSelectedDayDetails(_selectedSearchDate!),
                ],
              ),
            ),
          )
        else
          const Expanded(
            child: Center(child: Text('Pilih tanggal untuk melihat detail')),
          ),
      ],
    );
  }

  /// Build monthly summary for search view
  Widget _buildMonthlySearchSummary(DateTime date) {
    return FutureBuilder<sale_model.SaleReport?>(
      future: context.read<SalesProvider>().getMonthlyReport(date),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final monthlyReport = snapshot.data;
        if (monthlyReport == null) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ringkasan Bulan ${DateFormat('MMMM yyyy').format(date)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem('Total Pesanan', '0', Colors.blue),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoItem(
                        'Total Pendapatan',
                        'Rp 0',
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoItem('Rata-rata', 'Rp 0', Colors.orange),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan Bulan ${DateFormat('MMMM yyyy').format(date)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Total Pesanan',
                      monthlyReport.totalOrders.toString(),
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoItem(
                      'Total Pendapatan',
                      'Rp ${monthlyReport.totalRevenue.toStringAsFixed(0)}',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoItem(
                      'Rata-rata',
                      'Rp ${monthlyReport.averageOrderValue.toStringAsFixed(0)}',
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ========== DETAIL PENJUALAN PER HARI ==========
  void _showDayDetails(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => FractionallySizedBox(
            heightFactor: 0.9,
            child: _buildDayDetailSheet(date),
          ),
    );
  }

  Widget _buildSelectedDayDetails(DateTime date) {
    return FutureBuilder<List<sale_model.Sale>>(
      future: _getSalesForDate(date),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<sale_model.Sale> sales = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child:
              sales.isEmpty
                  ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text('Tidak ada penjualan pada hari ini'),
                    ),
                  )
                  : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: sales.length,
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pesanan #${sale.orderId}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      sale.customerName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Rp ${sale.totalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Chip(
                                label: Text(sale.paymentMethod),
                                backgroundColor: Colors.grey.shade200,
                                labelStyle: const TextStyle(fontSize: 11),
                              ),
                              Text(
                                DateFormat('HH:mm:ss').format(sale.createdAt),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          children: [_buildOrderItemsList(sale.orderId)],
                        ),
                      );
                    },
                  ),
        );
      },
    );
  }

  Widget _buildDayDetailSheet(DateTime date) {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, _) {
        // Find the report for this date
        final report = salesProvider.dailyReports.firstWhere(
          (r) =>
              r.date.year == date.year &&
              r.date.month == date.month &&
              r.date.day == date.day,
          orElse:
              () => sale_model.SaleReport(
                date: date,
                totalOrders: 0,
                totalRevenue: 0,
                averageOrderValue: 0,
              ),
        );

        return FutureBuilder<List<sale_model.Sale>>(
          future: _getSalesForDate(date),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            List<sale_model.Sale> sales = snapshot.data ?? [];

            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy').format(date),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              'Total Pesanan',
                              report.totalOrders.toString(),
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildInfoItem(
                              'Total Pendapatan',
                              'Rp ${report.totalRevenue.toStringAsFixed(0)}',
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildInfoItem(
                              'Rata-rata',
                              'Rp ${report.averageOrderValue.toStringAsFixed(0)}',
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Sales list
                Expanded(
                  child:
                      sales.isEmpty
                          ? const Center(
                            child: Text('Tidak ada penjualan pada hari ini'),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: sales.length,
                            itemBuilder: (context, index) {
                              final sale = sales[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Pesanan #${sale.orderId}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  sale.customerName,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            'Rp ${sale.totalAmount.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Chip(
                                            label: Text(sale.paymentMethod),
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            labelStyle: const TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                          Text(
                                            DateFormat(
                                              'HH:mm:ss',
                                            ).format(sale.createdAt),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ========== HELPER METHODS ==========
  Future<List<sale_model.Sale>> _getSalesForDate(DateTime date) async {
    final salesProvider = context.read<SalesProvider>();
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await salesProvider.getSalesForDate(startOfDay, endOfDay);
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Build list of items in an order
  Widget _buildOrderItemsList(String orderId) {
    return FutureBuilder<List>(
      future: _getOrderItems(orderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Tidak ada item'),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const Text(
                'Item Pesanan:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              ...items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item['menuItemName']} x${item['quantity']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Rp ${(item['price'] as num).toStringAsFixed(0)}/item',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rp ${(item['subtotal'] as num).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// Get order items from Firebase
  Future<List> _getOrderItems(String orderId) async {
    try {
      final salesProvider = context.read<SalesProvider>();
      // Call method to get order items - we need to add this to SalesProvider
      final items = await salesProvider.getOrderItems(orderId);
      return items ?? [];
    } catch (e) {
      print('Error getting order items: $e');
      return [];
    }
  }
}
