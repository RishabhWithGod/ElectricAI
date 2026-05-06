import 'dart:io';

import 'package:ai_app/core/utils/app_formatters.dart';
import 'package:ai_app/data/models/upload_history_model.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class PdfExportService {
  Future<String> saveBoqPdf(UploadHistoryModel session) async {
    final fileName = _buildFileName(session.fileName);
    final directory = await getApplicationDocumentsDirectory();
    final outputFile = File(path.join(directory.path, fileName));

    await outputFile.writeAsBytes(await _buildPdfBytes(session));
    return outputFile.path;
  }

  Future<void> shareBoqPdf(UploadHistoryModel session) async {
    final filePath = await saveBoqPdf(session);
    await Share.shareXFiles(
      <XFile>[XFile(filePath)],
      text: 'BOQ report for ${session.fileName}',
      subject: 'BOQ Export',
    );
  }

  Future<List<int>> _buildPdfBytes(UploadHistoryModel session) async {
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(28),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
        ),
        build: (pw.Context context) => <pw.Widget>[
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF102543),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(
                  'AI Drawing Estimator',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'File: ${session.fileName}',
                  style: const pw.TextStyle(color: PdfColors.white),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Generated: ${AppFormatters.dateTime(session.createdAt)}',
                  style: const pw.TextStyle(color: PdfColors.white),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF173358),
            ),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 10),
            cellPadding: const pw.EdgeInsets.all(10),
            headers: const <String>['Item', 'Count', 'Rate', 'Total'],
            data: session.items
                .map(
                  (item) => <String>[
                    item.name,
                    item.count.toString(),
                    AppFormatters.currency(item.rate),
                    AppFormatters.currency(item.total),
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 18),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFEAF6FF),
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(12)),
              ),
              child: pw.Text(
                'Grand Total: ${AppFormatters.currency(session.grandTotal)}',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF07162D),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return document.save();
  }

  String _buildFileName(String originalFileName) {
    final baseName = path.basenameWithoutExtension(originalFileName);
    final sanitized = baseName.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'boq_${sanitized}_$timestamp.pdf';
  }
}
