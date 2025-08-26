import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_package;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/patient_model.dart';
import '../models/provider_model.dart';
import '../providers/patient_data_provider.dart';
import '../providers/provider_data_provider.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeRange = '30d';
  String _selectedMetric = 'all';
  String? _selectedCountry; // Add country filter state

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
    return provider_package.Consumer2<PatientDataProvider, ProviderDataProvider>(
      builder: (context, patientProvider, providerProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Header
            _buildEnhancedHeader(patientProvider, providerProvider),
            
            // Enhanced Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.secondaryColor,
                indicatorColor: AppTheme.primaryColor,
                indicatorWeight: 3,
                labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Patients'),
                  Tab(text: 'Providers'),
                  Tab(text: 'Revenue'),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(patientProvider, providerProvider),
                  _buildPatientsTab(patientProvider),
                  _buildProvidersTab(providerProvider),
                  _buildRevenueTab(patientProvider, providerProvider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEnhancedHeader(PatientDataProvider patientProvider, ProviderDataProvider providerProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.headerGradientStart,
            AppTheme.headerGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analytics Dashboard',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Comprehensive insights into your healthcare platform performance',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              _buildQuickStats(patientProvider, providerProvider),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildEnhancedTimeRangeSelector(),
              const SizedBox(width: 16),
              _buildEnhancedMetricSelector(),
              const SizedBox(width: 16),
              _buildCountryFilterSelector(),
              const Spacer(),
              _buildExportButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(PatientDataProvider patientProvider, ProviderDataProvider providerProvider) {
    final patients = patientProvider.patients;
    final providers = providerProvider.providers;
    
    return Row(
      children: [
        _buildQuickStatCard(
          'Total Patients',
          patients.length.toString(),
          Icons.people,
          Colors.white.withOpacity(0.1),
        ),
        const SizedBox(width: 16),
        _buildQuickStatCard(
          'Total Providers',
          providers.length.toString(),
          Icons.medical_services,
          Colors.white.withOpacity(0.1),
        ),
        const SizedBox(width: 16),
        _buildQuickStatCard(
          'Success Rate',
          '${_calculateSuccessRate(patients).toStringAsFixed(1)}%',
          Icons.trending_up,
          Colors.white.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(String label, String value, IconData icon, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildEnhancedTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTimeRange,
              dropdownColor: AppTheme.headerGradientEnd,
              style: TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: '7d', child: Text('Last 7 days')),
                DropdownMenuItem(value: '30d', child: Text('Last 30 days')),
                DropdownMenuItem(value: '90d', child: Text('Last 90 days')),
                DropdownMenuItem(value: '1y', child: Text('Last year')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTimeRange = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMetricSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.analytics, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedMetric,
              dropdownColor: AppTheme.headerGradientEnd,
              style: TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Metrics')),
                DropdownMenuItem(value: 'patients', child: Text('Patient Metrics')),
                DropdownMenuItem(value: 'providers', child: Text('Provider Metrics')),
                DropdownMenuItem(value: 'revenue', child: Text('Revenue Metrics')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedMetric = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryFilterSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.public, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCountry,
              dropdownColor: AppTheme.headerGradientEnd,
              style: TextStyle(color: Colors.white),
              hint: Text('All Countries', style: TextStyle(color: Colors.white.withOpacity(0.8))),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Countries')),
                const DropdownMenuItem(value: 'USA', child: Text('🇺🇸 USA')),
                const DropdownMenuItem(value: 'RSA', child: Text('🇿🇦 RSA')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                });
                // Apply country filter to providers
                provider_package.Provider.of<ProviderDataProvider>(context, listen: false)
                    .setCountryFilter(_selectedCountry);
                provider_package.Provider.of<PatientDataProvider>(context, listen: false)
                    .setCountryFilter(_selectedCountry);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _exportAnalytics(),
        icon: const Icon(Icons.download, size: 18),
        label: const Text('Export'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(PatientDataProvider patientProvider, ProviderDataProvider providerProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics Cards
          _buildKeyMetricsRow(patientProvider, providerProvider),
          const SizedBox(height: 32),
          
          // Charts Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildPatientGrowthChart(patientProvider),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: _buildTreatmentTypeDistribution(patientProvider),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Additional Charts
          Row(
            children: [
              Expanded(
                child: _buildProviderPerformanceChart(providerProvider),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildRevenueTrendChart(patientProvider, providerProvider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsRow(PatientDataProvider patientProvider, ProviderDataProvider providerProvider) {
    final patients = patientProvider.patients;
    final providers = providerProvider.providers;
    
    final totalPatients = patients.length;
    final activePatients = patients.where((p) => p.isActive).length;
    final totalProviders = providers.length;
    final approvedProviders = providers.where((p) => p.isApproved).length;
    
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Patients',
            totalPatients.toString(),
            Icons.people,
            AppTheme.primaryColor,
            '${activePatients} active',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Total Providers',
            totalProviders.toString(),
            Icons.medical_services,
            AppTheme.successColor,
            '${approvedProviders} approved',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Avg Treatment Duration',
            '${_calculateAverageTreatmentDuration(patients).inDays} days',
            Icons.schedule,
            AppTheme.pinkColor,
            'Based on ${patients.length} patients',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Success Rate',
            '${_calculateSuccessRate(patients).toStringAsFixed(1)}%',
            Icons.trending_up,
            AppTheme.greenColor,
            'Treatment completion',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.1),
                        color.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.more_vert, color: AppTheme.secondaryColor, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder methods for charts
  Widget _buildPatientGrowthChart(PatientDataProvider patientProvider) {
    final patients = patientProvider.patients;
    final monthlyData = _getMonthlyPatientData(patients);
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                         Row(
               children: [
                 Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       colors: [
                         AppTheme.primaryColor.withOpacity(0.1),
                         AppTheme.primaryColor.withOpacity(0.2),
                       ],
                       begin: Alignment.topLeft,
                       end: Alignment.bottomRight,
                     ),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Icon(Icons.trending_up, color: AppTheme.primaryColor, size: 20),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: Text(
                     'Patient Growth',
                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
                       fontWeight: FontWeight.bold,
                       color: AppTheme.textColor,
                     ),
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
                 const SizedBox(width: 8),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                   decoration: BoxDecoration(
                     color: AppTheme.primaryColor.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Text(
                     'Monthly Trend',
                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                       color: AppTheme.primaryColor,
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                 ),
               ],
             ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < monthlyData.length) {
                            return Text(
                              monthlyData[value.toInt()]['month'],
                              style: TextStyle(
                                color: AppTheme.secondaryColor,
                                fontSize: 12,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: monthlyData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value['count'].toDouble());
                      }).toList(),
                      isCurved: true,
                      color: AppTheme.primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentTypeDistribution(PatientDataProvider patientProvider) {
    final patients = patientProvider.patients;
    final woundHealing = patients.where((p) => p.treatmentType == TreatmentType.woundHealing).length;
    final weightLoss = patients.where((p) => p.treatmentType == TreatmentType.weightLoss).length;
    final both = patients.where((p) => p.treatmentType == TreatmentType.both).length;
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                         Row(
               children: [
                 Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       colors: [
                         AppTheme.pinkColor.withOpacity(0.1),
                         AppTheme.pinkColor.withOpacity(0.2),
                       ],
                       begin: Alignment.topLeft,
                       end: Alignment.bottomRight,
                     ),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Icon(Icons.pie_chart, color: AppTheme.pinkColor, size: 20),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: Text(
                     'Treatment Types',
                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
                       fontWeight: FontWeight.bold,
                       color: AppTheme.textColor,
                     ),
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
                 const SizedBox(width: 8),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                   decoration: BoxDecoration(
                     color: AppTheme.pinkColor.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Text(
                     'Distribution',
                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                       color: AppTheme.pinkColor,
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                 ),
               ],
             ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: woundHealing.toDouble(),
                      title: 'Wound\n${woundHealing}',
                      color: AppTheme.primaryColor,
                      radius: 80,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    PieChartSectionData(
                      value: weightLoss.toDouble(),
                      title: 'Weight\n${weightLoss}',
                      color: AppTheme.successColor,
                      radius: 80,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    PieChartSectionData(
                      value: both.toDouble(),
                      title: 'Both\n${both}',
                      color: AppTheme.pinkColor,
                      radius: 80,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderPerformanceChart(ProviderDataProvider providerProvider) {
    final providers = providerProvider.providers;
    final approvedCount = providers.where((p) => p.isApproved).length;
    final pendingCount = providers.length - approvedCount;
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                         Row(
               children: [
                 Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       colors: [
                         AppTheme.successColor.withOpacity(0.1),
                         AppTheme.successColor.withOpacity(0.2),
                       ],
                       begin: Alignment.topLeft,
                       end: Alignment.bottomRight,
                     ),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Icon(Icons.medical_services, color: AppTheme.successColor, size: 20),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: Text(
                     'Provider Status',
                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
                       fontWeight: FontWeight.bold,
                       color: AppTheme.textColor,
                     ),
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
                 const SizedBox(width: 8),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                   decoration: BoxDecoration(
                     color: AppTheme.successColor.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Text(
                     'Approval Status',
                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                       color: AppTheme.successColor,
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                 ),
               ],
             ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: providers.length.toDouble(),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Approved');
                            case 1:
                              return const Text('Pending');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: approvedCount.toDouble(),
                          color: AppTheme.successColor,
                          width: 40,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: pendingCount.toDouble(),
                          color: AppTheme.warningColor,
                          width: 40,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueTrendChart(PatientDataProvider patientProvider, ProviderDataProvider providerProvider) {
    // Mock revenue data - in a real app, this would come from actual revenue data
    final revenueData = _getMockRevenueData();
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                         Row(
               children: [
                 Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       colors: [
                         AppTheme.greenColor.withOpacity(0.1),
                         AppTheme.greenColor.withOpacity(0.2),
                       ],
                       begin: Alignment.topLeft,
                       end: Alignment.bottomRight,
                     ),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Icon(Icons.attach_money, color: AppTheme.greenColor, size: 20),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: Text(
                     'Revenue Trend',
                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
                       fontWeight: FontWeight.bold,
                       color: AppTheme.textColor,
                     ),
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
                 const SizedBox(width: 8),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                   decoration: BoxDecoration(
                     color: AppTheme.greenColor.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Text(
                     'Monthly Growth',
                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                       color: AppTheme.greenColor,
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                 ),
               ],
             ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${(value / 1000).toStringAsFixed(0)}k',
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < revenueData.length) {
                            return Text(
                              revenueData[value.toInt()]['month'],
                              style: TextStyle(
                                color: AppTheme.secondaryColor,
                                fontSize: 12,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: revenueData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value['revenue'].toDouble());
                      }).toList(),
                      isCurved: true,
                      color: AppTheme.greenColor,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientsTab(PatientDataProvider patientProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Analytics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 24),
          
          // Patient metrics cards
          Row(
            children: [
              Expanded(
                child: _buildPatientMetricCard(
                  'Treatment Progress',
                  '${_calculateAverageProgress(patientProvider.patients).toStringAsFixed(1)}%',
                  Icons.trending_up,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPatientMetricCard(
                  'Active Treatments',
                  '${patientProvider.patients.where((p) => p.isActive).length}',
                  Icons.medical_services,
                  AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPatientMetricCard(
                  'Completed Treatments',
                  '${patientProvider.patients.where((p) => !p.isActive).length}',
                  Icons.check_circle,
                  AppTheme.greenColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Patient progress chart
          _buildPatientProgressChart(patientProvider),
        ],
      ),
    );
  }

  Widget _buildPatientMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.1),
                    color.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientProgressChart(PatientDataProvider patientProvider) {
    final patients = patientProvider.patients;
    final progressData = patients.map((p) => p.overallProgress).toList();
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                         Row(
               children: [
                 Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       colors: [
                         AppTheme.primaryColor.withOpacity(0.1),
                         AppTheme.primaryColor.withOpacity(0.2),
                       ],
                       begin: Alignment.topLeft,
                       end: Alignment.bottomRight,
                     ),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Icon(Icons.analytics, color: AppTheme.primaryColor, size: 20),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: Text(
                     'Patient Progress Distribution',
                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
                       fontWeight: FontWeight.bold,
                       color: AppTheme.textColor,
                     ),
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
                 const SizedBox(width: 8),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                   decoration: BoxDecoration(
                     color: AppTheme.primaryColor.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Text(
                     'Progress Ranges',
                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                       color: AppTheme.primaryColor,
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                 ),
               ],
             ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final ranges = ['0-20%', '21-40%', '41-60%', '61-80%', '81-100%'];
                          if (value.toInt() < ranges.length) {
                            return Text(
                              ranges[value.toInt()],
                              style: TextStyle(
                                color: AppTheme.secondaryColor,
                                fontSize: 12,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _getProgressBarGroups(progressData),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvidersTab(ProviderDataProvider providerProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Provider Analytics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 24),
          
          // Provider metrics
          Row(
            children: [
              Expanded(
                child: _buildProviderMetricCard(
                  'Approval Rate',
                  '${_calculateApprovalRate(providerProvider.providers).toStringAsFixed(1)}%',
                  Icons.approval,
                  AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProviderMetricCard(
                  'Avg Registration Time',
                  '${_calculateAvgRegistrationTime(providerProvider.providers).inDays} days',
                  Icons.schedule,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProviderMetricCard(
                  'Top Package',
                  _getTopPackage(providerProvider.providers),
                  Icons.inventory,
                  AppTheme.pinkColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Provider registration trend
          _buildProviderRegistrationChart(providerProvider),
        ],
      ),
    );
  }

  Widget _buildProviderMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.1),
                    color.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderRegistrationChart(ProviderDataProvider providerProvider) {
    final providers = providerProvider.providers;
    final monthlyData = _getMonthlyProviderData(providers);
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                         Row(
               children: [
                 Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       colors: [
                         AppTheme.primaryColor.withOpacity(0.1),
                         AppTheme.primaryColor.withOpacity(0.2),
                       ],
                       begin: Alignment.topLeft,
                       end: Alignment.bottomRight,
                     ),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Icon(Icons.person_add, color: AppTheme.primaryColor, size: 20),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: Text(
                     'Provider Registration Trend',
                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
                       fontWeight: FontWeight.bold,
                       color: AppTheme.textColor,
                     ),
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
                 const SizedBox(width: 8),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                   decoration: BoxDecoration(
                     color: AppTheme.primaryColor.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Text(
                     'Monthly Growth',
                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                       color: AppTheme.primaryColor,
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                 ),
               ],
             ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < monthlyData.length) {
                            return Text(
                              monthlyData[value.toInt()]['month'],
                              style: TextStyle(
                                color: AppTheme.secondaryColor,
                                fontSize: 12,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: monthlyData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value['count'].toDouble());
                      }).toList(),
                      isCurved: true,
                      color: AppTheme.primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueTab(PatientDataProvider patientProvider, ProviderDataProvider providerProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Analytics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 24),
          
          // Revenue metrics
          Row(
            children: [
              Expanded(
                child: _buildRevenueMetricCard(
                  'Total Revenue',
                  '\$${_calculateTotalRevenue().toStringAsFixed(0)}',
                  Icons.attach_money,
                  AppTheme.greenColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRevenueMetricCard(
                  'Monthly Growth',
                  '+${_calculateMonthlyGrowth().toStringAsFixed(1)}%',
                  Icons.trending_up,
                  AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRevenueMetricCard(
                  'Avg Revenue per Provider',
                  '\$${_calculateAvgRevenuePerProvider().toStringAsFixed(0)}',
                  Icons.person,
                  AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Revenue breakdown
          _buildRevenueBreakdownChart(),
        ],
      ),
    );
  }

  Widget _buildRevenueMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.1),
                    color.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueBreakdownChart() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                         Row(
               children: [
                 Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       colors: [
                         AppTheme.greenColor.withOpacity(0.1),
                         AppTheme.greenColor.withOpacity(0.2),
                       ],
                       begin: Alignment.topLeft,
                       end: Alignment.bottomRight,
                     ),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Icon(Icons.bar_chart, color: AppTheme.greenColor, size: 20),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: Text(
                     'Revenue by Treatment Type',
                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
                       fontWeight: FontWeight.bold,
                       color: AppTheme.textColor,
                     ),
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
                 const SizedBox(width: 8),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                   decoration: BoxDecoration(
                     color: AppTheme.greenColor.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Text(
                     'Revenue Breakdown',
                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                       color: AppTheme.greenColor,
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                 ),
               ],
             ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100000,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final types = ['Wound Healing', 'Weight Loss', 'Both'];
                          if (value.toInt() < types.length) {
                            return Text(
                              types[value.toInt()],
                              style: TextStyle(
                                color: AppTheme.secondaryColor,
                                fontSize: 12,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${(value / 1000).toStringAsFixed(0)}k',
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: 45000,
                          color: AppTheme.primaryColor,
                          width: 40,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: 35000,
                          color: AppTheme.successColor,
                          width: 40,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: 20000,
                          color: AppTheme.pinkColor,
                          width: 40,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Duration _calculateAverageTreatmentDuration(List<Patient> patients) {
    if (patients.isEmpty) return Duration.zero;
    
    final totalDuration = patients.fold<Duration>(
      Duration.zero,
      (total, patient) => total + patient.treatmentDuration,
    );
    
    return Duration(milliseconds: totalDuration.inMilliseconds ~/ patients.length);
  }

  double _calculateSuccessRate(List<Patient> patients) {
    if (patients.isEmpty) return 0.0;
    
    final completedPatients = patients.where((p) => !p.isActive && p.overallProgress >= 80.0).length;
    return (completedPatients / patients.length) * 100;
  }

  double _calculateAverageProgress(List<Patient> patients) {
    if (patients.isEmpty) return 0.0;
    
    final totalProgress = patients.fold<double>(
      0.0,
      (total, patient) => total + patient.overallProgress,
    );
    
    return totalProgress / patients.length;
  }

  double _calculateApprovalRate(List<Provider> providers) {
    if (providers.isEmpty) return 0.0;
    
    final approvedCount = providers.where((p) => p.isApproved).length;
    return (approvedCount / providers.length) * 100;
  }

  Duration _calculateAvgRegistrationTime(List<Provider> providers) {
    if (providers.isEmpty) return Duration.zero;
    
    final now = DateTime.now();
    final totalDuration = providers.fold<Duration>(
      Duration.zero,
      (total, provider) => total + now.difference(provider.registrationDate),
    );
    
    return Duration(milliseconds: totalDuration.inMilliseconds ~/ providers.length);
  }

  String _getTopPackage(List<Provider> providers) {
    if (providers.isEmpty) return 'N/A';
    
    final packageCounts = <String, int>{};
    for (final provider in providers) {
      packageCounts[provider.package] = (packageCounts[provider.package] ?? 0) + 1;
    }
    
    final topPackage = packageCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return topPackage;
  }

  double _calculateTotalRevenue() {
    // Mock calculation - in a real app, this would come from actual revenue data
    return 100000.0;
  }

  double _calculateMonthlyGrowth() {
    // Mock calculation
    return 15.5;
  }

  double _calculateAvgRevenuePerProvider() {
    // Mock calculation
    return 5555.56;
  }

  void _exportAnalytics() {
    // TODO: Implement analytics export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analytics export functionality coming soon!')),
    );
  }

  // Helper methods for charts
  List<Map<String, dynamic>> _getMonthlyPatientData(List<Patient> patients) {
    // Mock data - in a real app, this would be calculated from actual patient data
    return [
      {'month': 'Jan', 'count': 12},
      {'month': 'Feb', 'count': 18},
      {'month': 'Mar', 'count': 25},
      {'month': 'Apr', 'count': 22},
      {'month': 'May', 'count': 30},
      {'month': 'Jun', 'count': 35},
    ];
  }

  List<Map<String, dynamic>> _getMonthlyProviderData(List<Provider> providers) {
    // Mock data - in a real app, this would be calculated from actual provider data
    return [
      {'month': 'Jan', 'count': 5},
      {'month': 'Feb', 'count': 8},
      {'month': 'Mar', 'count': 12},
      {'month': 'Apr', 'count': 10},
      {'month': 'May', 'count': 15},
      {'month': 'Jun', 'count': 18},
    ];
  }

  List<Map<String, dynamic>> _getMockRevenueData() {
    return [
      {'month': 'Jan', 'revenue': 25000},
      {'month': 'Feb', 'revenue': 32000},
      {'month': 'Mar', 'revenue': 45000},
      {'month': 'Apr', 'revenue': 38000},
      {'month': 'May', 'revenue': 52000},
      {'month': 'Jun', 'revenue': 60000},
    ];
  }

  List<BarChartGroupData> _getProgressBarGroups(List<double> progressData) {
    final ranges = [0, 0, 0, 0, 0]; // 0-20%, 21-40%, 41-60%, 61-80%, 81-100%
    
    for (final progress in progressData) {
      if (progress <= 20) ranges[0]++;
      else if (progress <= 40) ranges[1]++;
      else if (progress <= 60) ranges[2]++;
      else if (progress <= 80) ranges[3]++;
      else ranges[4]++;
    }
    
    return ranges.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: _getProgressColor(entry.key),
            width: 40,
          ),
        ],
      );
    }).toList();
  }

  Color _getProgressColor(int rangeIndex) {
    switch (rangeIndex) {
      case 0:
        return AppTheme.errorColor;
      case 1:
        return AppTheme.warningColor;
      case 2:
        return AppTheme.pinkColor;
      case 3:
        return AppTheme.primaryColor;
      case 4:
        return AppTheme.successColor;
      default:
        return AppTheme.secondaryColor;
    }
  }
}

