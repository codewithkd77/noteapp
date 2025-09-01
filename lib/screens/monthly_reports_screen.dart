import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../utils/app_theme.dart';
import '../services/pdf_service.dart';
import '../services/database_service.dart';

class MonthlyReportsScreen extends StatefulWidget {
  const MonthlyReportsScreen({super.key});

  @override
  State<MonthlyReportsScreen> createState() => _MonthlyReportsScreenState();
}

class _MonthlyReportsScreenState extends State<MonthlyReportsScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  bool _isGenerating = false;
  File? _generatedPdf;

  final List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Monthly Reports'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headline1(
          context,
        ).copyWith(color: AppColors.textPrimary(context)),
        iconTheme: IconThemeData(color: AppColors.primary(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      size: 64,
                      color: AppColors.primary(context),
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    Text(
                      'Generate Monthly PDF Report',
                      style: AppTextStyles.headline2(context),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    Text(
                      'Create a comprehensive PDF report containing all your tasks, categories, and hourly activities for any month.',
                      style: AppTextStyles.bodyMedium(
                        context,
                      ).copyWith(color: AppColors.textSecondary(context)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),

            // Month and Year Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Month & Year',
                      style: AppTextStyles.headline2(context),
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),

                    // Year Selection
                    Row(
                      children: [
                        Text(
                          'Year: ',
                          style: AppTextStyles.bodyMedium(
                            context,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedYear,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMedium,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingMedium,
                                vertical: AppDimensions.paddingSmall,
                              ),
                            ),
                            items: List.generate(5, (index) {
                              final year = DateTime.now().year - index;
                              return DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                _selectedYear = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),

                    // Month Selection
                    Row(
                      children: [
                        Text(
                          'Month: ',
                          style: AppTextStyles.bodyMedium(
                            context,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedMonth,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMedium,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingMedium,
                                vertical: AppDimensions.paddingSmall,
                              ),
                            ),
                            items: List.generate(12, (index) {
                              return DropdownMenuItem(
                                value: index + 1,
                                child: Text(_monthNames[index]),
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                _selectedMonth = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),

            // Preview Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Contents',
                      style: AppTextStyles.headline2(context),
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    _buildReportItem(
                      context,
                      Icons.event_note,
                      'Daily Task Checklists',
                      'All tasks organized by date with completion status',
                    ),
                    _buildReportItem(
                      context,
                      Icons.schedule,
                      'Hourly Activities',
                      'Time-based activity tracking for each day',
                    ),
                    _buildReportItem(
                      context,
                      Icons.category,
                      'Category Entries',
                      'All category entries with titles, links, and descriptions',
                    ),
                    _buildReportItem(
                      context,
                      Icons.date_range,
                      'Timestamps & Dates',
                      'Creation and modification dates for all entries',
                    ),
                    _buildReportItem(
                      context,
                      Icons.style,
                      'Professional Format',
                      'Clean, organized layout with handwritten-style fonts',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),

            // Generate Button
            ElevatedButton(
              onPressed: _isGenerating ? null : _generateReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
              ),
              child: _isGenerating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingMedium),
                        Text(
                          'Generating PDF...',
                          style: AppTextStyles.bodyLarge(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.picture_as_pdf, color: Colors.white),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Text(
                          'Generate Report for ${_monthNames[_selectedMonth - 1]} $_selectedYear',
                          style: AppTextStyles.bodyLarge(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),

            if (_generatedPdf != null) ...[
              const SizedBox(height: AppDimensions.paddingMedium),
              OutlinedButton(
                onPressed: _shareReport,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share, color: AppColors.primary(context)),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Text(
                      'Share Generated Report',
                      style: AppTextStyles.bodyLarge(context).copyWith(
                        color: AppColors.primary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.paddingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary(context)),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: AppTextStyles.bodySmall(
                    context,
                  ).copyWith(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _generateReport() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      HapticFeedback.mediumImpact();

      // Generate the PDF
      final pdf = await PdfService.generateMonthlyReport(
        _selectedYear,
        _selectedMonth,
      );

      setState(() {
        _generatedPdf = pdf;
        _isGenerating = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: AppDimensions.paddingSmall),
              Expanded(
                child: Text(
                  'PDF report generated successfully!\nSaved to: ${pdf.path}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'SHARE',
            textColor: Colors.white,
            onPressed: _shareReport,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      _showError('Failed to generate PDF: $e');
    }
  }

  void _shareReport() async {
    if (_generatedPdf != null) {
      try {
        HapticFeedback.lightImpact();
        await PdfService.sharePdf(_generatedPdf!);
      } catch (e) {
        _showError('Failed to share PDF: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: AppDimensions.paddingSmall),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
