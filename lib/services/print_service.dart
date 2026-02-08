import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:hotpot/models/order.dart';
import 'package:intl/intl.dart';

class PrintService {
  static Future<void> printOrderReceipt(Order order) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'HOTPOT POS',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Order #${order.id}'),
                  pw.Text(dateFormat.format(order.createdAt)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Text('Customer: ${order.customerName}'),
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Column(
                children: [
                  pw.TableHelper.fromTextArray(
                    headers: ['Item', 'Qty', 'Price', 'Total'],
                    data:
                        order.items
                            .map(
                              (item) => [
                                item.menuItemName,
                                item.quantity.toString(),
                                'Rp ${item.price.toStringAsFixed(0)}',
                                'Rp ${item.subtotal.toStringAsFixed(0)}',
                              ],
                            )
                            .toList(),
                    columnWidths: {
                      0: pw.FlexColumnWidth(2),
                      1: pw.FlexColumnWidth(1),
                      2: pw.FlexColumnWidth(1.5),
                      3: pw.FlexColumnWidth(1.5),
                    },
                    cellStyle: pw.TextStyle(fontSize: 10),
                    headerStyle: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Rp ${order.totalAmount.toStringAsFixed(0)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Status: ${order.status.toString().split('.').last}',
                style: pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'Payment: ${order.paymentStatus.toString().split('.').last}',
                style: pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Terima Kasih!',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
