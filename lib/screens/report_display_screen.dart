import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/generated_report_model.dart';
import '../theme/app_theme.dart';

class ReportDisplayScreen extends StatefulWidget {
  final GeneratedReport report;

  const ReportDisplayScreen({
    super.key,
    required this.report,
  });

  @override
  State<ReportDisplayScreen> createState() => _ReportDisplayScreenState();
}

class _ReportDisplayScreenState extends State<ReportDisplayScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report.title),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _isExporting ? null : _exportToPDF,
            tooltip: 'Export to PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReport,
            tooltip: 'Share Report',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppTheme.primaryColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Analytics'),
                Tab(text: 'Patients'),
                Tab(text: 'Details'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildAnalyticsTab(),
          _buildPatientsTab(),
          _buildDetailsTab(),
        ],
      ),
      floatingActionButton: _isExporting
          ? const FloatingActionButton(
              onPressed: null,
              backgroundColor: Colors.grey,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : FloatingActionButton.extended(
              onPressed: _exportToPDF,
              backgroundColor: AppTheme.primaryColor,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Export PDF'),
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportHeader(),
          const SizedBox(height: 24),
          _buildSummaryCards(),
          const SizedBox(height: 24),
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildKeyInsights(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.report.configuration.includeVasScores && widget.report.metrics.painMetrics != null)
            _buildPainAnalytics(),
          if (widget.report.configuration.includeWoundHealing && widget.report.metrics.woundMetrics != null)
            _buildWoundAnalytics(),
          if (widget.report.configuration.includeWeightChanges && widget.report.metrics.weightMetrics != null)
            _buildWeightAnalytics(),
          if (widget.report.configuration.includeTreatmentProgress && widget.report.metrics.treatmentMetrics != null)
            _buildTreatmentAnalytics(),
        ],
      ),
    );
  }

  Widget _buildPatientsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.report.patientData.length,
      itemBuilder: (context, index) {
        final patientData = widget.report.patientData[index];
        return _buildPatientCard(patientData);
      },
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportConfiguration(),
          const SizedBox(height: 24),
          _buildDataSources(),
          const SizedBox(height: 24),
          _buildMethodology(),
        ],
      ),
    );
  }

  Widget _buildReportHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: AppTheme.primaryColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.report.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Generated on ${DateFormat('MMMM dd, yyyy \'at\' HH:mm').format(widget.report.generatedAt)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.date_range, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Report Period: ${DateFormat('MMM dd, yyyy').format(widget.report.startDate)} - ${DateFormat('MMM dd, yyyy').format(widget.report.endDate)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
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

  Widget _buildSummaryCards() {
    final summary = widget.report.summary;
    
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildSummaryCard(
          'Total Patients',
          summary.totalPatients.toString(),
          Icons.people,
          AppTheme.primaryColor,
        ),
        _buildSummaryCard(
          'Total Sessions',
          summary.totalSessions.toString(),
          Icons.event_note,
          AppTheme.successColor,
        ),
        _buildSummaryCard(
          'Avg Progress',
          '${summary.averageProgress.toStringAsFixed(1)}%',
          Icons.trending_up,
          AppTheme.greenColor,
        ),
        _buildSummaryCard(
          'Success Rate',
          '${summary.treatmentSuccessRate.toStringAsFixed(1)}%',
          Icons.check_circle,
          AppTheme.pinkColor,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Providers Involved', widget.report.summary.totalProviders.toString()),
            _buildStatRow('Countries Represented', widget.report.summary.totalCountries.toString()),
            _buildStatRow('Average Treatment Duration', '${widget.report.summary.averageTreatmentDuration.inDays} days'),
            if (widget.report.metrics.treatmentMetrics != null) ...[
              _buildStatRow('Patients Improved', widget.report.metrics.treatmentMetrics!.patientsImproved.toString()),
              _buildStatRow('Patients Stable', widget.report.metrics.treatmentMetrics!.patientsStable.toString()),
              _buildStatRow('Patients Declined', widget.report.metrics.treatmentMetrics!.patientsDeclined.toString()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyInsights() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: AppTheme.warningColor),
                const SizedBox(width: 8),
                Text(
                  'Key Insights',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._generateKeyInsights().map((insight) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8, right: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      insight,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPainAnalytics() {
    final painMetrics = widget.report.metrics.painMetrics!;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sentiment_dissatisfied, color: AppTheme.warningColor),
                const SizedBox(width: 8),
                Text(
                  'Pain Score Analysis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Initial Pain',
                    painMetrics.averageInitialPain.toStringAsFixed(1),
                    'Average VAS score',
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Current Pain',
                    painMetrics.averageCurrentPain.toStringAsFixed(1),
                    'Average VAS score',
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Pain Reduction',
                    '${painMetrics.painReductionPercentage.toStringAsFixed(1)}%',
                    'Improvement',
                    AppTheme.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (painMetrics.painTrend.isNotEmpty)
              SizedBox(
                height: 200,
                child: _buildPainTrendChart(painMetrics.painTrend),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWoundAnalytics() {
    final woundMetrics = widget.report.metrics.woundMetrics!;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.healing, color: AppTheme.pinkColor),
                const SizedBox(width: 8),
                Text(
                  'Wound Healing Analysis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Initial Area',
                    '${woundMetrics.totalInitialWoundArea.toStringAsFixed(1)} cm²',
                    'Total wound area',
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Current Area',
                    '${woundMetrics.totalCurrentWoundArea.toStringAsFixed(1)} cm²',
                    'Total wound area',
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Healing Rate',
                    '${woundMetrics.woundHealingPercentage.toStringAsFixed(1)}%',
                    'Improvement',
                    AppTheme.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (woundMetrics.woundTypeDistribution.isNotEmpty)
              _buildWoundTypeChart(woundMetrics.woundTypeDistribution),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightAnalytics() {
    final weightMetrics = widget.report.metrics.weightMetrics!;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_weight, color: AppTheme.greenColor),
                const SizedBox(width: 8),
                Text(
                  'Weight Change Analysis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Initial Weight',
                    '${weightMetrics.averageInitialWeight.toStringAsFixed(1)} kg',
                    'Average weight',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Current Weight',
                    '${weightMetrics.averageCurrentWeight.toStringAsFixed(1)} kg',
                    'Average weight',
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Weight Change',
                    '${weightMetrics.weightChangePercentage >= 0 ? '+' : ''}${weightMetrics.weightChangePercentage.toStringAsFixed(1)}%',
                    'Change',
                    weightMetrics.weightChangePercentage >= 0 ? AppTheme.successColor : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentAnalytics() {
    final treatmentMetrics = widget.report.metrics.treatmentMetrics!;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Treatment Effectiveness',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _buildProgressChart(treatmentMetrics),
            ),
            const SizedBox(height: 20),
            if (treatmentMetrics.progressByTreatmentType.isNotEmpty)
              _buildTreatmentTypeBreakdown(treatmentMetrics.progressByTreatmentType),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(PatientReportData patientData) {
    final patient = patientData.patient;
    final progress = patientData.progress;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getProgressColor(progress.overallProgress),
                  child: Text(
                    progress.overallProgress.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Provider: ${patientData.providerName} • ${patient.country}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getProgressStatusColor(progress.progressStatus),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    progress.progressStatus.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPatientMetric('Sessions', patientData.sessions.length.toString()),
                ),
                Expanded(
                  child: _buildPatientMetric('Progress', '${progress.overallProgress.toStringAsFixed(1)}%'),
                ),
                if (widget.report.configuration.includeVasScores)
                  Expanded(
                    child: _buildPatientMetric('Pain', '${progress.currentPainScore.toStringAsFixed(1)}/10'),
                  ),
                if (widget.report.configuration.includeWeightChanges && progress.weightChange != 0)
                  Expanded(
                    child: _buildPatientMetric('Weight', '${progress.weightChange >= 0 ? '+' : ''}${progress.weightChange.toStringAsFixed(1)} kg'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildReportConfiguration() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Configuration',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildConfigRow('Patient Filter', widget.report.configuration.patientFilterType),
            _buildConfigRow('Session Filter', widget.report.configuration.sessionFilterType),
            _buildConfigRow('VAS Scores', widget.report.configuration.includeVasScores ? 'Included' : 'Excluded'),
            _buildConfigRow('Weight Changes', widget.report.configuration.includeWeightChanges ? 'Included' : 'Excluded'),
            _buildConfigRow('Wound Healing', widget.report.configuration.includeWoundHealing ? 'Included' : 'Excluded'),
            _buildConfigRow('Treatment Progress', widget.report.configuration.includeTreatmentProgress ? 'Included' : 'Excluded'),
            _buildConfigRow('Image Selection', widget.report.configuration.imageSelection),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSources() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Sources',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This report is generated from the following data sources:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ...[
              'Patient demographic and treatment information',
              'Session data including measurements and assessments',
              'Provider information and clinical notes',
              'Wound progress photos and documentation',
              'VAS pain scores and subjective assessments',
            ].map((source) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8, right: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      source,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodology() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Methodology',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This report uses standardized clinical assessment methods to evaluate patient progress:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ...[
              'Visual Analog Scale (VAS) for pain assessment (0-10 scale)',
              'Wound area calculation using length × width measurements',
              'Progress scoring based on multiple clinical indicators',
              'Treatment effectiveness measured by improvement percentages',
              'Statistical analysis includes only patients with minimum 2 sessions',
            ].map((method) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8, right: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      method,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  // Chart widgets
  Widget _buildPainTrendChart(List<PainDataPoint> data) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString());
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < data.length) {
                  return Text(DateFormat('MM/dd').format(data[value.toInt()].date));
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.painScore);
            }).toList(),
            isCurved: true,
            color: AppTheme.warningColor,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildWoundTypeChart(Map<String, int> woundTypes) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: woundTypes.entries.map((entry) {
            return PieChartSectionData(
              value: entry.value.toDouble(),
              title: entry.key,
              color: _getWoundTypeColor(entry.key),
              radius: 80,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProgressChart(TreatmentMetrics metrics) {
    final data = [
      {'label': 'Improved', 'value': metrics.patientsImproved.toDouble(), 'color': AppTheme.successColor},
      {'label': 'Stable', 'value': metrics.patientsStable.toDouble(), 'color': AppTheme.warningColor},
      {'label': 'Declined', 'value': metrics.patientsDeclined.toDouble(), 'color': Colors.red},
    ];

    return PieChart(
      PieChartData(
        sections: data.map((item) {
          return PieChartSectionData(
            value: item['value'] as double,
            title: item['label'] as String,
            color: item['color'] as Color,
            radius: 80,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTreatmentTypeBreakdown(Map<String, double> progressByType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress by Treatment Type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...progressByType.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(entry.key),
                ),
                Expanded(
                  flex: 7,
                  child: LinearProgressIndicator(
                    value: entry.value / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${entry.value.toStringAsFixed(1)}%'),
              ],
            ),
          );
        }),
      ],
    );
  }

  // Helper methods
  Color _getProgressColor(double progress) {
    if (progress >= 75) return AppTheme.successColor;
    if (progress >= 50) return AppTheme.warningColor;
    if (progress >= 25) return Colors.orange;
    return Colors.red;
  }

  Color _getProgressStatusColor(String status) {
    switch (status) {
      case 'improved':
        return AppTheme.successColor;
      case 'stable':
        return AppTheme.warningColor;
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getWoundTypeColor(String woundType) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.successColor,
      AppTheme.warningColor,
      AppTheme.pinkColor,
      AppTheme.greenColor,
      Colors.purple,
      Colors.indigo,
      Colors.teal,
    ];
    return colors[woundType.hashCode % colors.length];
  }

  List<String> _generateKeyInsights() {
    final insights = <String>[];
    final summary = widget.report.summary;
    final metrics = widget.report.metrics;

    // Success rate insights
    if (summary.treatmentSuccessRate >= 80) {
      insights.add('Excellent treatment success rate of ${summary.treatmentSuccessRate.toStringAsFixed(1)}% demonstrates effective clinical protocols.');
    } else if (summary.treatmentSuccessRate >= 60) {
      insights.add('Good treatment success rate of ${summary.treatmentSuccessRate.toStringAsFixed(1)}% with room for improvement in patient outcomes.');
    } else {
      insights.add('Treatment success rate of ${summary.treatmentSuccessRate.toStringAsFixed(1)}% indicates need for protocol review and optimization.');
    }

    // Pain reduction insights
    if (metrics.painMetrics != null && metrics.painMetrics!.painReductionPercentage > 30) {
      insights.add('Significant pain reduction of ${metrics.painMetrics!.painReductionPercentage.toStringAsFixed(1)}% achieved across patient population.');
    }

    // Wound healing insights
    if (metrics.woundMetrics != null && metrics.woundMetrics!.woundHealingPercentage > 40) {
      insights.add('Strong wound healing progress with ${metrics.woundMetrics!.woundHealingPercentage.toStringAsFixed(1)}% average area reduction.');
    }

    // Session consistency insights
    final avgSessionsPerPatient = summary.totalPatients > 0 ? summary.totalSessions / summary.totalPatients : 0;
    if (avgSessionsPerPatient >= 8) {
      insights.add('High patient engagement with average of ${avgSessionsPerPatient.toStringAsFixed(1)} sessions per patient.');
    }

    // Provider distribution insights
    if (summary.totalProviders > 1) {
      insights.add('Multi-provider collaboration across ${summary.totalProviders} healthcare professionals enhances treatment coordination.');
    }

    if (insights.isEmpty) {
      insights.add('Report generated successfully. Continue monitoring patient progress for trend analysis.');
    }

    return insights;
  }

  Future<void> _exportToPDF() async {
    setState(() => _isExporting = true);

    try {
      // Simulate PDF generation process
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF export feature will be implemented in the next update'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _shareReport() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality will be implemented in the next update'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

