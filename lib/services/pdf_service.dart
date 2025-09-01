import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../models/hourly_activity.dart';
import 'database_service.dart';

class PdfService {
  static Future<File> generateMonthlyReport(int year, int month) async {
    final pdf = pw.Document();
    final monthName = DateFormat('MMMM yyyy').format(DateTime(year, month));

    // Get data for the month
    final tasks = DatabaseService.getTasksForMonth(year, month);
    final categories = DatabaseService.getCategories();

    // Get hourly activities for the month
    final hourlyActivitiesBox = await Hive.openBox<HourlyActivity>(
      'hourlyActivities',
    );
    final hourlyActivities = hourlyActivitiesBox.values
        .where(
          (activity) =>
              activity.date.year == year &&
              activity.date.month == month &&
              activity.activity.isNotEmpty,
        )
        .toList();

    // Group tasks by date
    final tasksByDate = <String, List<Task>>{};
    for (final task in tasks) {
      final dateKey = task.dateString;
      if (!tasksByDate.containsKey(dateKey)) {
        tasksByDate[dateKey] = [];
      }
      tasksByDate[dateKey]!.add(task);
    }

    // Group hourly activities by date
    final activitiesByDate = <String, List<HourlyActivity>>{};
    for (final activity in hourlyActivities) {
      final dateKey =
          '${activity.date.year}-${activity.date.month.toString().padLeft(2, '0')}-${activity.date.day.toString().padLeft(2, '0')}';
      if (!activitiesByDate.containsKey(dateKey)) {
        activitiesByDate[dateKey] = [];
      }
      activitiesByDate[dateKey]!.add(activity);
    }

    // Create PDF pages
    await _addCoverPage(pdf, monthName);
    await _addDailyChecklistPages(
      pdf,
      tasksByDate,
      activitiesByDate,
      year,
      month,
    );
    await _addCategoryPages(pdf, categories);

    // Save PDF to device
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/daily_planner_${year}_${month.toString().padLeft(2, '0')}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static Future<void> _addCoverPage(pw.Document pdf, String monthName) async {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Daily Planner',
                  style: pw.TextStyle(
                    fontSize: 36,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(monthName, style: pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 40),
                pw.Text(
                  'Generated on ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Future<void> _addDailyChecklistPages(
    pw.Document pdf,
    Map<String, List<Task>> tasksByDate,
    Map<String, List<HourlyActivity>> activitiesByDate,
    int year,
    int month,
  ) async {
    // Get all days in the month
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final dayTasks = tasksByDate[dateKey] ?? [];
      final dayActivities = activitiesByDate[dateKey] ?? [];

      // Sort activities by hour
      dayActivities.sort((a, b) => a.hour.compareTo(b.hour));

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.indigo,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    DateFormat('EEEE, MMMM dd, yyyy').format(date),
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Tasks Section
                if (dayTasks.isNotEmpty) ...[
                  pw.Text(
                    'Tasks',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.indigo,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Column(
                    children: dayTasks.map((task) {
                      return pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 8),
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Row(
                          children: [
                            pw.Container(
                              width: 80,
                              child: pw.Text(
                                task.timeString,
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.indigo,
                                ),
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                task.title,
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  decoration: task.isCompleted
                                      ? pw.TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            pw.Container(
                              width: 14,
                              height: 14,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.grey),
                                borderRadius: pw.BorderRadius.circular(2),
                                color: task.isCompleted
                                    ? PdfColors.green
                                    : PdfColors.white,
                              ),
                              child: task.isCompleted
                                  ? pw.Center(
                                      child: pw.Text(
                                        '✓',
                                        style: pw.TextStyle(
                                          fontSize: 8,
                                          color: PdfColors.white,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  pw.SizedBox(height: 20),
                ],

                // Hourly Activities Section
                if (dayActivities.isNotEmpty) ...[
                  pw.Text(
                    'Hourly Activities',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.purple,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Expanded(
                    child: pw.Column(
                      children: dayActivities.map((activity) {
                        return pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 8),
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.purple50,
                            border: pw.Border.all(color: PdfColors.purple200),
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Container(
                                width: 80,
                                child: pw.Text(
                                  _getHourDisplay(activity.hour),
                                  style: pw.TextStyle(
                                    fontSize: 11,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.purple,
                                  ),
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Text(
                                  activity.activity,
                                  style: pw.TextStyle(
                                    fontSize: 11,
                                    color: PdfColors.purple800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                // Empty day message
                if (dayTasks.isEmpty && dayActivities.isEmpty)
                  pw.Center(
                    child: pw.Text(
                      'No tasks or activities for this day',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      );
    }
  }

  static Future<void> _addCategoryPages(
    pw.Document pdf,
    List<Category> categories,
  ) async {
    for (final category in categories) {
      if (category.entries.isEmpty) continue;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Category title
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: _hexToColor(category.color),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    category.name,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Category entries
                pw.Expanded(
                  child: pw.Column(
                    children: category.entries.map((entry) {
                      return pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 16),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              entry.content,
                              style: pw.TextStyle(
                                fontSize: 14,
                                color: PdfColors.blue,
                                fontStyle: pw.FontStyle.italic,
                              ),
                            ),
                            pw.Container(
                              margin: const pw.EdgeInsets.only(top: 4),
                              height: 1,
                              color: PdfColors.grey300,
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              'Created: ${DateFormat('MMM dd, yyyy - hh:mm a').format(entry.createdAt)}',
                              style: pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
  }

  static PdfColor _hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    final color = int.parse('FF$hexCode', radix: 16);
    return PdfColor(
      ((color >> 16) & 0xFF) / 255,
      ((color >> 8) & 0xFF) / 255,
      (color & 0xFF) / 255,
    );
  }

  static String _getHourDisplay(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }

  static Future<void> sharePdf(File pdfFile) async {
    await Share.shareXFiles([XFile(pdfFile.path)]);
  }

  static Future<bool> shouldGenerateMonthlyPdf() async {
    final settings = DatabaseService.getUserSettings();
    final now = DateTime.now();
    final lastGenerated = settings.lastPdfGenerated;

    // Check if it's the last day of the month and we haven't generated for this month
    if (now.day == DateTime(now.year, now.month + 1, 0).day) {
      return lastGenerated.month != now.month || lastGenerated.year != now.year;
    }

    return false;
  }
}
