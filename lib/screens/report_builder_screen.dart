import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:intl/intl.dart';
import '../models/report_model.dart';
import '../providers/report_data_provider.dart';
import '../providers/provider_data_provider.dart';
import '../providers/patient_data_provider.dart';
import '../theme/app_theme.dart';

class ReportBuilderScreen extends StatefulWidget {
  const ReportBuilderScreen({super.key});

  @override
  State<ReportBuilderScreen> createState() => _ReportBuilderScreenState();
}

class _ReportBuilderScreenState extends State<ReportBuilderScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  ReportType _selectedReportType = ReportType.providerPerformance;
  String _selectedTemplate = 'default';
  String? _selectedCountry; // Add country filter state

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportDataProvider>(
      builder: (context, reportProvider, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(reportProvider),
              
              // Tab Bar
              Container(
                color: AppTheme.backgroundColor,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: AppTheme.secondaryColor,
                  indicatorColor: AppTheme.primaryColor,
                  tabs: const [
                    Tab(text: 'Report Builder'),
                    Tab(text: 'My Reports'),
                  ],
                ),
              ),
              
              // Tab Content
              SizedBox(
                height: MediaQuery.of(context).size.height - 300, // Adjust height for header and tab bar
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReportBuilderTab(reportProvider),
                    _buildMyReportsTab(reportProvider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ReportDataProvider reportProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.headerGradientStart,
            AppTheme.headerGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assessment,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Builder',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create professional reports with drag-and-drop metrics',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              if (reportProvider.currentReport != null) ...[
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _showExportDialog(reportProvider.currentReport!),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _showPreviewDialog(reportProvider.currentReport!),
                    icon: const Icon(Icons.preview, size: 18),
                    label: const Text('Preview'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          // Quick Stats Row
          Row(
            children: [
              _buildQuickStat(
                icon: Icons.assessment_outlined,
                label: 'Total Reports',
                value: '${reportProvider.reports.length}',
              ),
              const SizedBox(width: 32),
              _buildQuickStat(
                icon: Icons.published_with_changes,
                label: 'Published',
                value: '${reportProvider.reports.where((r) => r.isPublished).length}',
              ),
              const SizedBox(width: 32),
              _buildQuickStat(
                icon: Icons.edit_note,
                label: 'Drafts',
                value: '${reportProvider.reports.where((r) => !r.isPublished).length}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Placeholder methods for now
  Widget _buildReportBuilderTab(ReportDataProvider reportProvider) {
    if (reportProvider.currentReport == null) {
      return _buildNewReportForm(reportProvider);
    }

    return Row(
      children: [
        // Available Metrics Panel
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            border: Border(
              right: BorderSide(
                color: AppTheme.borderColor,
                width: 1,
              ),
            ),
          ),
          child: _buildAvailableMetricsPanel(reportProvider),
        ),
        
        // Report Canvas
        Expanded(
          child: _buildReportCanvas(reportProvider),
        ),
      ],
    );
  }

  Widget _buildNewReportForm(ReportDataProvider reportProvider) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(32),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Report',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Report Title',
                    hintText: 'Enter report title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter report description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Report Type
                DropdownButtonFormField<ReportType>(
                  value: _selectedReportType,
                  decoration: const InputDecoration(
                    labelText: 'Report Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ReportType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getReportTypeDisplayName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedReportType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Template
                DropdownButtonFormField<String>(
                  value: _selectedTemplate,
                  decoration: const InputDecoration(
                    labelText: 'Template',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'default', child: Text('Default')),
                    DropdownMenuItem(value: 'professional', child: Text('Professional')),
                    DropdownMenuItem(value: 'minimal', child: Text('Minimal')),
                    DropdownMenuItem(value: 'executive', child: Text('Executive')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedTemplate = value!;
                    });
                  },
                ),
                const SizedBox(height: 32),
                
                // Create Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _createNewReport(reportProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Create Report'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableMetricsPanel(ReportDataProvider reportProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.borderColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Available Metrics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
        ),
        
        // Country Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.borderColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.public, color: AppTheme.secondaryColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Country Filter:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                  ),
                ],
              ),
                             const SizedBox(height: 12),
               Wrap(
                 spacing: 8,
                 runSpacing: 8,
                 children: [
                   _buildCountryFilterChip('All Countries', _selectedCountry == null, reportProvider),
                   _buildCountryFilterChip('🇺🇸 USA', _selectedCountry == 'USA', reportProvider),
                   _buildCountryFilterChip('🇿🇦 RSA', _selectedCountry == 'RSA', reportProvider),
                 ],
               ),
            ],
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: PredefinedMetrics.availableMetrics.length,
            itemBuilder: (context, index) {
              final metric = PredefinedMetrics.availableMetrics[index];
              return _buildMetricCard(metric, reportProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(ReportMetric metric, ReportDataProvider reportProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => reportProvider.addMetricToReport(metric),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getMetricIcon(metric.displayType),
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      metric.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.drag_handle,
                    size: 16,
                    color: AppTheme.secondaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                metric.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      metric.displayType,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      metric.aggregationType,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.successColor,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCanvas(ReportDataProvider reportProvider) {
    final currentReport = reportProvider.currentReport!;
    
    return Column(
      children: [
        // Report Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.borderColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentReport.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentReport.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    // Show country filter if applied
                    if (_selectedCountry != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.public, size: 14, color: AppTheme.primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            'Filtered by: ${_getCountryFlag(_selectedCountry!)} $_selectedCountry',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _saveReport(reportProvider),
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _clearReport(reportProvider),
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Clear'),
              ),
            ],
          ),
        ),
        
        // Report Content
        Expanded(
          child: currentReport.metrics.isEmpty
              ? _buildEmptyCanvas()
              : _buildMetricsCanvas(reportProvider),
        ),
      ],
    );
  }

  Widget _buildEmptyCanvas() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment_outlined,
            size: 64,
            color: AppTheme.secondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Drag metrics from the left panel to build your report',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.secondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Or click on any metric to add it to your report',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCanvas(ReportDataProvider reportProvider) {
    final currentReport = reportProvider.currentReport!;
    
    return DragAndDropLists(
      children: [
        DragAndDropList(
          children: currentReport.metrics.map((metric) {
            return DragAndDropItem(
              child: _buildReportMetricCard(metric, reportProvider),
            );
          }).toList(),
        ),
      ],
      onItemReorder: (int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
        reportProvider.reorderMetrics(oldItemIndex, newItemIndex);
      },
      onListReorder: (int oldListIndex, int newListIndex) {
        // Not needed for single list
      },
      axis: Axis.vertical,
      listWidth: double.infinity,
      listPadding: const EdgeInsets.all(16),
      itemDivider: const SizedBox(height: 16),
    );
  }

  Widget _buildReportMetricCard(ReportMetric metric, ReportDataProvider reportProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getMetricIcon(metric.displayType),
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    metric.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => reportProvider.removeMetricFromReport(metric.id),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Remove metric',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMetricPreview(metric),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricPreview(ReportMetric metric) {
    // This would be replaced with actual data visualization
    switch (metric.displayType) {
      case 'number':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.trending_up, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Sample Data: 1,234',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        );
      case 'chart':
        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 48, color: AppTheme.secondaryColor),
                const SizedBox(height: 8),
                Text(
                  'Chart Preview',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondaryColor,
                  ),
                ),
                Text(
                  '${metric.name} - ${metric.aggregationType}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Text(
            'Preview for ${metric.name}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryColor,
            ),
          ),
        );
    }
  }

  Widget _buildMyReportsTab(ReportDataProvider reportProvider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'My Reports',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _showSortDialog(reportProvider),
                icon: const Icon(Icons.sort, size: 18),
                label: const Text('Sort'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showNewReportDialog(reportProvider),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Quick stats row
          Row(
            children: [
              _buildReportStat(
                icon: Icons.assessment_outlined,
                label: 'Total',
                value: '${reportProvider.reports.length}',
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 24),
              _buildReportStat(
                icon: Icons.published_with_changes,
                label: 'Published',
                value: '${reportProvider.getPublishedReports().length}',
                color: AppTheme.successColor,
              ),
              const SizedBox(width: 24),
              _buildReportStat(
                icon: Icons.edit_note,
                label: 'Drafts',
                value: '${reportProvider.reports.where((r) => !r.isPublished).length}',
                color: AppTheme.secondaryColor,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          if (reportProvider.reports.isEmpty)
            _buildEmptyReportsState()
          else
            SizedBox(
              height: MediaQuery.of(context).size.height - 480, // Adjust for header, tab bar, stats, and padding
              child: _buildReportsList(reportProvider),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyReportsState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 400, // Adjust for header, tab bar, and padding
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment_outlined,
              size: 64,
              color: AppTheme.secondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No reports created yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first report to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsList(ReportDataProvider reportProvider) {
    return ListView.builder(
      itemCount: reportProvider.reports.length,
      itemBuilder: (context, index) {
        final report = reportProvider.reports[index];
        return _buildReportCard(report, reportProvider);
      },
    );
  }

  Widget _buildReportCard(Report report, ReportDataProvider reportProvider) {
    final isCurrentReport = reportProvider.currentReport?.id == report.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isCurrentReport ? 4 : 2,
      color: isCurrentReport ? AppTheme.primaryColor.withOpacity(0.05) : null,
      child: InkWell(
        onTap: () => _loadReportAndSwitchTab(report, reportProvider),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isCurrentReport 
              ? AppTheme.primaryColor 
              : AppTheme.primaryColor.withOpacity(0.1),
          child: Icon(
            _getReportTypeIcon(report.type),
            color: isCurrentReport ? Colors.white : AppTheme.primaryColor,
          ),
        ),
        title: Text(
          report.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isCurrentReport ? AppTheme.primaryColor : AppTheme.textColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              report.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getReportTypeColor(report.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getReportTypeDisplayName(report.type),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getReportTypeColor(report.type),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (report.isPublished)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Published',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.successColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  '${report.metrics.length} metrics',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Created ${DateFormat('MMM dd, yyyy').format(report.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.secondaryColor,
              ),
            ),
            if (isCurrentReport) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Currently Editing',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCurrentReport)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Active',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) => _handleReportAction(value, report, reportProvider),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Duplicate'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.download_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Export'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'preview',
                  child: Row(
                    children: [
                      Icon(Icons.preview_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Preview'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: report.isPublished ? 'unpublish' : 'publish',
                  child: Row(
                    children: [
                      Icon(
                        report.isPublished ? Icons.visibility_off_outlined : Icons.publish_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(report.isPublished ? 'Unpublish' : 'Publish'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outlined, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }



  // Helper methods
  String _getReportTypeDisplayName(ReportType type) {
    switch (type) {
      case ReportType.providerPerformance:
        return 'Provider Performance';
      case ReportType.patientProgress:
        return 'Patient Progress';
      case ReportType.revenueAnalysis:
        return 'Revenue Analysis';
      case ReportType.treatmentEfficacy:
        return 'Treatment Efficacy';
    }
  }

  IconData _getReportTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.providerPerformance:
        return Icons.medical_services_outlined;
      case ReportType.patientProgress:
        return Icons.trending_up_outlined;
      case ReportType.revenueAnalysis:
        return Icons.attach_money_outlined;
      case ReportType.treatmentEfficacy:
        return Icons.science_outlined;
    }
  }

  Color _getReportTypeColor(ReportType type) {
    switch (type) {
      case ReportType.providerPerformance:
        return AppTheme.primaryColor;
      case ReportType.patientProgress:
        return AppTheme.successColor;
      case ReportType.revenueAnalysis:
        return AppTheme.pinkColor;
      case ReportType.treatmentEfficacy:
        return AppTheme.redColor;
    }
  }

  IconData _getMetricIcon(String displayType) {
    switch (displayType) {
      case 'number':
        return Icons.numbers;
      case 'chart':
        return Icons.bar_chart;
      case 'table':
        return Icons.table_chart;
      case 'gauge':
        return Icons.speed;
      default:
        return Icons.analytics_outlined;
    }
  }

  String _getCountryFlag(String country) {
    switch (country) {
      case 'USA':
        return '🇺🇸';
      case 'RSA':
        return '🇿🇦';
      default:
        return '🌍'; // Default flag for unknown countries
    }
  }

  Widget _buildCountryFilterChip(String label, bool isSelected, ReportDataProvider reportProvider) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (label == 'All Countries') {
            _selectedCountry = null;
          } else if (label == '🇺🇸 USA') {
            _selectedCountry = 'USA';
          } else if (label == '🇿🇦 RSA') {
            _selectedCountry = 'RSA';
          }
        });
        
        // Apply country filter to data providers
        Provider.of<ProviderDataProvider>(context, listen: false)
            .setCountryFilter(_selectedCountry);
        Provider.of<PatientDataProvider>(context, listen: false)
            .setCountryFilter(_selectedCountry);
            
        // Update report filters if there's a current report
        if (reportProvider.currentReport != null) {
          final updatedFilters = Map<String, dynamic>.from(reportProvider.currentReport!.filters);
          if (_selectedCountry != null) {
            updatedFilters['country'] = _selectedCountry;
          } else {
            updatedFilters.remove('country');
          }
          reportProvider.updateCurrentReport(filters: updatedFilters);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check, color: Colors.white, size: 14),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textColor,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action methods
  void _createNewReport(ReportDataProvider reportProvider) {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a report title')),
      );
      return;
    }

    final title = _titleController.text;
    final description = _descriptionController.text;

    // Create filters map with country filter if selected
    final Map<String, dynamic> filters = {};
    if (_selectedCountry != null) {
      filters['country'] = _selectedCountry;
    }

    reportProvider.createNewReport(
      title: title,
      description: description,
      type: _selectedReportType,
      template: _selectedTemplate,
      filters: filters,
    );

    // Apply country filter to data providers
    Provider.of<ProviderDataProvider>(context, listen: false)
        .setCountryFilter(_selectedCountry);
    Provider.of<PatientDataProvider>(context, listen: false)
        .setCountryFilter(_selectedCountry);

    // Update the current report with filters
    if (reportProvider.currentReport != null) {
      reportProvider.updateCurrentReport(filters: filters);
    }

    _titleController.clear();
    _descriptionController.clear();
    _tabController.animateTo(0); // Switch to Report Builder tab
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Created new report: $title'),
        duration: const Duration(seconds: 2),
      ),
    );
  }



  void _saveReport(ReportDataProvider reportProvider) {
    // The updateCurrentReport method automatically sets lastModified
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report saved successfully')),
    );
  }

  void _clearReport(ReportDataProvider reportProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Report'),
        content: const Text('Are you sure you want to clear the current report? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              reportProvider.clearCurrentReport();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _loadReportAndSwitchTab(Report report, ReportDataProvider reportProvider) {
    reportProvider.loadReport(report.id);
    
    // Load country filter from report filters
    setState(() {
      _selectedCountry = report.filters['country'] as String?;
    });
    
    // Apply country filter to data providers
    Provider.of<ProviderDataProvider>(context, listen: false)
        .setCountryFilter(_selectedCountry);
    Provider.of<PatientDataProvider>(context, listen: false)
        .setCountryFilter(_selectedCountry);
    
    _tabController.animateTo(0); // Switch to Report Builder tab
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loaded report: ${report.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleReportAction(String action, Report report, ReportDataProvider reportProvider) {
    switch (action) {
      case 'edit':
        _loadReportAndSwitchTab(report, reportProvider);
        break;
      case 'duplicate':
        reportProvider.duplicateReport(report.id);
        _tabController.animateTo(0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Duplicated report: ${report.title}'),
            duration: const Duration(seconds: 2),
          ),
        );
        break;
      case 'export':
        _showExportDialog(report);
        break;
      case 'preview':
        _showPreviewDialog(report);
        break;
      case 'publish':
      case 'unpublish':
        reportProvider.toggleReportPublish(report.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(report.isPublished ? 'Report unpublished' : 'Report published'),
            duration: const Duration(seconds: 2),
          ),
        );
        break;
      case 'delete':
        _showDeleteDialog(report, reportProvider);
        break;
    }
  }

  void _showExportDialog(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.of(context).pop();
                _exportAsPDF(report);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Export as Excel'),
              onTap: () {
                Navigator.of(context).pop();
                _exportAsExcel(report);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showPreviewDialog(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report.title),
        content: SizedBox(
          width: 600,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.secondaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Metrics (${report.metrics.length}):',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: report.metrics.length,
                  itemBuilder: (context, index) {
                    final metric = report.metrics[index];
                    return ListTile(
                      leading: Icon(_getMetricIcon(metric.displayType)),
                      title: Text(metric.name),
                      subtitle: Text(metric.description),
                      dense: true,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Report report, ReportDataProvider reportProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text('Are you sure you want to delete "${report.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              reportProvider.deleteReport(report.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _exportAsPDF(Report report) {
    // TODO: Implement PDF export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF export functionality coming soon!')),
    );
  }

  void _showNewReportDialog(ReportDataProvider reportProvider) {
    // Reset form controllers
    _titleController.clear();
    _descriptionController.clear();
    _selectedReportType = ReportType.providerPerformance;
    _selectedTemplate = 'default';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Report'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Report Title',
                  hintText: 'Enter report title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter report description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ReportType>(
                value: _selectedReportType,
                decoration: const InputDecoration(
                  labelText: 'Report Type',
                  border: OutlineInputBorder(),
                ),
                items: ReportType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getReportTypeDisplayName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedReportType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTemplate,
                decoration: const InputDecoration(
                  labelText: 'Template',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'default', child: Text('Default')),
                  DropdownMenuItem(value: 'professional', child: Text('Professional')),
                  DropdownMenuItem(value: 'minimal', child: Text('Minimal')),
                  DropdownMenuItem(value: 'executive', child: Text('Executive')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTemplate = value!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a report title')),
                );
                return;
              }
              
              Navigator.of(context).pop();
              _createNewReport(reportProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSortDialog(ReportDataProvider reportProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Reports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Date Created (Newest First)'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement sorting in ReportDataProvider
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sorting by date created')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Date Created (Oldest First)'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement sorting in ReportDataProvider
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sorting by date created')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Title (A-Z)'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement sorting in ReportDataProvider
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sorting by title')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Title (Z-A)'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement sorting in ReportDataProvider
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sorting by title')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _exportAsExcel(Report report) {
    // TODO: Implement Excel export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Excel export functionality coming soon!')),
    );
  }
}
