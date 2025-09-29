import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/provider_data_provider.dart';
import '../providers/patient_data_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../models/patient_model.dart';
import '../screens/admin_user_creation_screen.dart';

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('📊 DashboardOverview: build() called');
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildWelcomeSection(context),
          const SizedBox(height: 24),
          
          // Key Metrics Cards
          _buildMetricsCards(context),
          const SizedBox(height: 24),
          
          // Charts Section
          _buildChartsSection(context),
          const SizedBox(height: 24),
          
          // Recent Activity
          _buildRecentActivity(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Consumer<ProviderDataProvider>(
      builder: (context, providerProvider, child) {
        if (kDebugMode) {
          print('📊 DashboardOverview: _buildWelcomeSection Consumer called');
          print('📊 DashboardOverview: providerProvider.error = ${providerProvider.error}');
          print('📊 DashboardOverview: providerProvider.isLoading = ${providerProvider.isLoading}');
        }
        // Show error if there's one
        if (providerProvider.error != null) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Data',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  providerProvider.error!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => providerProvider.refresh(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

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
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Medwave Admin',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your healthcare providers and track patient progress with our advanced healing technologies.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildQuickStat(
                          context,
                          'Total Providers',
                          providerProvider.totalProviders.toString(),
                          Icons.medical_services,
                        ),
                        const SizedBox(width: 24),
                        _buildQuickStat(
                          context,
                          'Pending Approvals',
                          providerProvider.totalPendingApprovals.toString(),
                          Icons.pending,
                        ),
                        const Spacer(),
                        _buildAdminActionsSection(context),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Image.asset(
                'images/medwave_logo_white.png',
                height: 80,
                width: 200,
                fit: BoxFit.contain,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStat(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
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

  Widget _buildMetricsCards(BuildContext context) {
    return Consumer2<ProviderDataProvider, PatientDataProvider>(
      builder: (context, providerProvider, patientProvider, child) {
        return GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildMetricCard(
              context,
              'Total Providers',
              providerProvider.totalProviders.toString(),
              Icons.medical_services,
              AppTheme.primaryColor,
              '+12% from last month',
            ),
            _buildMetricCard(
              context,
              'Active Patients',
              patientProvider.activePatients.toString(),
              Icons.people,
              AppTheme.successColor,
              '+8% from last month',
            ),
            _buildMetricCard(
              context,
              'Avg. Patient Progress',
              '${patientProvider.averageProgress.toStringAsFixed(1)}%',
              Icons.trending_up,
              AppTheme.greenColor,
              '+5% from last month',
            ),
            _buildMetricCard(
              context,
              'Avg. Monthly Revenue',
              '\$${providerProvider.averageMonthlyRevenue.toStringAsFixed(0)}',
              Icons.attach_money,
              AppTheme.pinkColor,
              '+15% from last month',
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String trend,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const Spacer(),
                Icon(
                  Icons.trending_up,
                  color: AppTheme.successColor,
                  size: 12,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                trend,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildPatientProgressChart(context),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: _buildTreatmentTypeChart(context),
        ),
      ],
    );
  }

  Widget _buildPatientProgressChart(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Progress Over Time',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: Consumer<PatientDataProvider>(
                builder: (context, patientProvider, child) {
                  return LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 20,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _generateProgressSpots(patientProvider.patients),
                          isCurved: true,
                          color: AppTheme.primaryColor,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentTypeChart(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Treatment Types',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: Consumer<PatientDataProvider>(
                builder: (context, patientProvider, child) {
                  return PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: patientProvider.getPatientsByTreatmentTypeCount(TreatmentType.woundHealing).toDouble(),
                          title: 'Wound Healing',
                          color: AppTheme.primaryColor,
                          radius: 80,
                        ),
                        PieChartSectionData(
                          value: patientProvider.getPatientsByTreatmentTypeCount(TreatmentType.weightLoss).toDouble(),
                          title: 'Weight Loss',
                          color: AppTheme.greenColor,
                          radius: 80,
                        ),
                        PieChartSectionData(
                          value: patientProvider.getPatientsByTreatmentTypeCount(TreatmentType.both).toDouble(),
                          title: 'Both',
                          color: AppTheme.pinkColor,
                          radius: 80,
                        ),
                      ],
                      centerSpaceRadius: 40,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Consumer<PatientDataProvider>(
              builder: (context, patientProvider, child) {
                final recentPatients = patientProvider.getRecentPatients(7);
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentPatients.length,
                  itemBuilder: (context, index) {
                    final patient = recentPatients[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      title: Text(patient.name),
                      subtitle: Text('${patient.treatmentType.toString().split('.').last} - ${patient.overallProgress.toStringAsFixed(1)}% progress'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: patient.overallProgress > 50 
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${patient.overallProgress.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: patient.overallProgress > 50 
                                ? AppTheme.successColor
                                : AppTheme.warningColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActionsSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Only show admin actions if user is authenticated and is an admin
        // For now, we'll assume the logged in user is an admin
        // In the future, this will check the actual user role from Firebase
        if (!authProvider.isAuthenticated) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminUserCreationScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.admin_panel_settings, size: 18),
              label: const Text('Create Admin User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Admin Tools',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  List<FlSpot> _generateProgressSpots(List<Patient> patients) {
    // Generate sample data for the chart
    return List.generate(10, (index) {
      return FlSpot(index.toDouble(), 20 + (index * 8) + (index % 3 * 5));
    });
  }


}
