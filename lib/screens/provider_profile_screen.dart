import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_package;
import 'package:fl_chart/fl_chart.dart';
import '../models/provider_model.dart';
import '../models/patient_model.dart';
import '../providers/patient_data_provider.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class ProviderProfileScreen extends StatefulWidget {
  final Provider provider;

  const ProviderProfileScreen({
    super.key,
    required this.provider,
  });

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.desktopBackgroundColor,
      body: Row(
        children: [
          // Sidebar Navigation
          _buildSidebar(),
          
          // Main Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  
                  // Content Area
                  _buildContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppTheme.sidebarColor,
        border: Border(
          right: BorderSide(
            color: AppTheme.sidebarBorderColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo Section
          _buildLogoSection(),
          
          // Navigation Items
          Expanded(
            child: _buildNavigationItems(),
          ),
          
          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.sidebarBorderColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            'images/medwave_logo_black.png',
            height: 40,
            width: 120,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'ADMIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItems() {
    final navigationItems = [
      _NavigationItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Dashboard',
        isSelected: false,
      ),
      _NavigationItem(
        icon: Icons.approval_outlined,
        activeIcon: Icons.approval,
        label: 'Provider Approvals',
        isSelected: false,
      ),
      _NavigationItem(
        icon: Icons.medical_services_outlined,
        activeIcon: Icons.medical_services,
        label: 'Provider Management',
        isSelected: true,
      ),
      _NavigationItem(
        icon: Icons.assessment_outlined,
        activeIcon: Icons.assessment,
        label: 'Report Builder',
        isSelected: false,
      ),
      _NavigationItem(
        icon: Icons.analytics_outlined,
        activeIcon: Icons.analytics,
        label: 'Analytics',
        isSelected: false,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: navigationItems.length,
      itemBuilder: (context, index) {
        final item = navigationItems[index];
        return _buildNavigationItem(item);
      },
    );
  }

  Widget _buildNavigationItem(_NavigationItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            _handleNavigation(item.label);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: item.isSelected ? AppTheme.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  item.isSelected ? item.activeIcon : item.icon,
                  color: item.isSelected ? Colors.white : AppTheme.secondaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: item.isSelected ? Colors.white : AppTheme.textColor,
                    fontWeight: item.isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(String label) {
    // Navigate to the appropriate screen based on the label
    switch (label) {
      case 'Dashboard':
        // Navigate to main dashboard
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen(initialIndex: 0)),
          (route) => false,
        );
        break;
      case 'Provider Approvals':
        // Navigate to provider approvals with index 1
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen(initialIndex: 1)),
          (route) => false,
        );
        break;
      case 'Provider Management':
        // Navigate to provider management with index 2
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen(initialIndex: 2)),
          (route) => false,
        );
        break;
      case 'Report Builder':
        // Navigate to report builder with index 3
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen(initialIndex: 3)),
          (route) => false,
        );
        break;
      case 'Analytics':
        // Navigate to analytics with index 4
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen(initialIndex: 4)),
          (route) => false,
        );
        break;
    }
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          top: BorderSide(
            color: AppTheme.sidebarBorderColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Quick Stats
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: AppTheme.successColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'System Status',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.successColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'All systems operational',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Version Info
          Text(
            'Medwave Admin v1.0.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Back Button
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              
              // Page Title and Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Provider Profile',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.provider.fullName} - ${widget.provider.fullCompanyName}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Quick Action Buttons
              Row(
                children: [
                  _buildQuickActionButton(
                    icon: Icons.edit,
                    label: 'Edit Profile',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit functionality coming soon!')),
                      );
                    },
                    isPrimary: true,
                  ),
                  const SizedBox(width: 12),
                  _buildQuickActionButton(
                    icon: Icons.download,
                    label: 'Export Data',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export functionality coming soon!')),
                      );
                    },
                    isPrimary: false,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.white : Colors.white.withOpacity(0.2),
        foregroundColor: isPrimary ? AppTheme.primaryColor : Colors.white,
        elevation: isPrimary ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatItem(
          icon: Icons.medical_services,
          value: widget.provider.package,
          label: 'Package',
          color: Colors.white,
        ),
        const SizedBox(width: 32),
        _buildStatItem(
          icon: Icons.calendar_today,
          value: _formatDate(widget.provider.registrationDate),
          label: 'Registered',
          color: AppTheme.warningColor,
        ),
        const SizedBox(width: 32),
        _buildStatItem(
          icon: widget.provider.isApproved ? Icons.check_circle : Icons.pending,
          value: widget.provider.isApproved ? 'Approved' : 'Pending',
          label: 'Status',
          color: widget.provider.isApproved ? AppTheme.successColor : AppTheme.warningColor,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
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
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Provider Header
        _buildProviderHeader(),
        const SizedBox(height: 24),
        
        // Tab Bar
        Container(
          color: AppTheme.backgroundColor,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.secondaryColor,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'Dashboard'),
              Tab(text: 'Patients'),
            ],
          ),
        ),
        
        // Tab Content
        SizedBox(
          height: 600, // Fixed height for tab content
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDashboardTab(),
              _buildPatientsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProviderHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Icon(Icons.person, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Provider Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              // Provider Avatar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.provider.isApproved 
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.medical_services,
                  color: widget.provider.isApproved 
                      ? AppTheme.successColor
                      : AppTheme.warningColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              
              // Provider Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.provider.fullName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Country Flag
                        Text(
                          _getCountryFlag(widget.provider.country),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.provider.isApproved 
                                ? AppTheme.successColor.withOpacity(0.1)
                                : AppTheme.warningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.provider.isApproved ? 'Approved' : 'Pending',
                            style: TextStyle(
                              color: widget.provider.isApproved 
                                  ? AppTheme.successColor
                                  : AppTheme.warningColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.provider.fullCompanyName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildInfoItem(Icons.email_outlined, widget.provider.email),
                        const SizedBox(width: 24),
                        _buildInfoItem(Icons.phone_outlined, widget.provider.directPhoneNumber),
                        const SizedBox(width: 24),
                        _buildInfoItem(Icons.public, widget.provider.country),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Additional Info Cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  title: 'Package',
                  value: widget.provider.package,
                  icon: Icons.medical_services,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  title: 'Registration Date',
                  value: _formatDate(widget.provider.registrationDate),
                  icon: Icons.calendar_today,
                  color: AppTheme.warningColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  title: 'Sales Person',
                  value: widget.provider.salesPerson,
                  icon: Icons.person_outline,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.secondaryColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.secondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return provider_package.Consumer<PatientDataProvider>(
      builder: (context, patientProvider, child) {
        final providerPatients = _getProviderPatients(patientProvider);
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Metrics Overview
              _buildMetricsOverview(providerPatients),
              const SizedBox(height: 32),
              
              // Charts Section
              _buildChartsSection(providerPatients),
              const SizedBox(height: 32),
              
              // Recent Activity
              _buildRecentActivity(providerPatients),
              const SizedBox(height: 24), // Add bottom padding for better scrolling
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricsOverview(List<Patient> patients) {
    final totalPatients = patients.length;
    final activePatients = patients.where((p) => p.overallProgress < 100).length;
    
    // Calculate average pain reduction (from progress records)
    final patientsWithPainData = patients.where((p) => p.progressRecords.isNotEmpty).toList();
    final avgPainReduction = patientsWithPainData.isNotEmpty 
        ? patientsWithPainData.map((p) => p.progressRecords.last.painLevel).reduce((a, b) => a + b) / patientsWithPainData.length 
        : 0.0;
    
    // Calculate average wound healing progress
    final woundHealingPatients = patients.where((p) => 
        p.treatmentType == TreatmentType.woundHealing || p.treatmentType == TreatmentType.both).toList();
    final avgWoundHealing = woundHealingPatients.isNotEmpty 
        ? woundHealingPatients.map((p) => p.overallProgress).reduce((a, b) => a + b) / woundHealingPatients.length
        : 0.0;
    
    // Calculate average weight loss progress
    final weightLossPatients = patients.where((p) => 
        p.treatmentType == TreatmentType.weightLoss || p.treatmentType == TreatmentType.both).toList();
    final avgWeightLoss = weightLossPatients.isNotEmpty 
        ? weightLossPatients.map((p) => p.overallProgress).reduce((a, b) => a + b) / weightLossPatients.length
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive grid based on available width
            int crossAxisCount = 4;
            if (constraints.maxWidth < 800) crossAxisCount = 2;
            if (constraints.maxWidth < 600) crossAxisCount = 1;
            
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2, // Much smaller aspect ratio for more height
              children: [
                _buildMetricCard(
                  'Total Patients',
                  totalPatients.toString(),
                  Icons.people,
                  AppTheme.primaryColor,
                  'Active: $activePatients',
                ),
                _buildMetricCard(
                  'Avg. Pain Reduction',
                  '${avgPainReduction.toStringAsFixed(1)}%',
                  Icons.trending_down,
                  AppTheme.successColor,
                  'Across all patients',
                ),
                _buildMetricCard(
                  'Avg. Wound Healing',
                  '${avgWoundHealing.toStringAsFixed(1)}%',
                  Icons.healing,
                  AppTheme.greenColor,
                  'Recovery rate',
                ),
                _buildMetricCard(
                  'Avg. Weight Loss',
                  '${avgWeightLoss.toStringAsFixed(1)}%',
                  Icons.monitor_weight,
                  AppTheme.pinkColor,
                  'Progress rate',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(
                  Icons.trending_up,
                  color: AppTheme.successColor,
                  size: 16,
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.successColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(List<Patient> patients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patient Progress Trends',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive layout based on available width
            if (constraints.maxWidth < 1200) {
              // Stack vertically on smaller screens
              return Column(
                children: [
                  _buildPainRatingChart(patients),
                  const SizedBox(height: 24),
                  _buildWoundRecoveryChart(patients),
                  const SizedBox(height: 24),
                  _buildWeightLossChart(patients),
                ],
              );
            } else {
              // Side by side on larger screens
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildPainRatingChart(patients),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildWoundRecoveryChart(patients),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildWeightLossChart(patients),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildTreatmentTypeChart(patients),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildPainRatingChart(List<Patient> patients) {
    // Calculate average pain ratings for the last 6 months
    final now = DateTime.now();
    final painData = <FlSpot>[];
    
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final patientsWithPainData = patients.where((p) => 
        p.progressRecords.isNotEmpty && 
        p.progressRecords.any((record) => 
          record.date.year == month.year && record.date.month == month.month
        )
      ).toList();
      
      if (patientsWithPainData.isNotEmpty) {
        final avgPain = patientsWithPainData.map((p) {
          final monthRecords = p.progressRecords.where((record) => 
            record.date.year == month.year && record.date.month == month.month
          ).toList();
          return monthRecords.isNotEmpty ? monthRecords.last.painLevel : 0.0;
        }).reduce((a, b) => a + b) / patientsWithPainData.length;
        
        painData.add(FlSpot(i.toDouble(), avgPain));
      } else {
        painData.add(FlSpot(i.toDouble(), 0));
      }
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_down, color: AppTheme.successColor),
                const SizedBox(width: 8),
                Text(
                  'Average Pain Rating',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 2,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppTheme.borderColor,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: AppTheme.borderColor,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const months = ['6m ago', '5m ago', '4m ago', '3m ago', '2m ago', '1m ago'];
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              months[value.toInt()],
                              style: TextStyle(
                                color: AppTheme.secondaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  minX: 0,
                  maxX: 5,
                  minY: 0,
                  maxY: 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: painData,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.8),
                          AppTheme.primaryColor.withOpacity(0.3),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppTheme.primaryColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.3),
                            AppTheme.primaryColor.withOpacity(0.1),
                          ],
                        ),
                      ),
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

  Widget _buildWoundRecoveryChart(List<Patient> patients) {
    if (patients.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.healing, color: AppTheme.greenColor),
                  const SizedBox(width: 8),
                  Text(
                    'Wound Recovery Rate',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 48,
                        color: AppTheme.secondaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No data available',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.secondaryColor,
                        ),
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

         final patientsWithData = patients.where((p) => p.progressRecords.isNotEmpty).toList();
     final woundData = patientsWithData.asMap().entries.map((entry) {
       final patient = entry.value;
       final latestRecord = patient.progressRecords.last;
       return FlSpot(
         entry.key.toDouble(),
         _calculateWoundRecovery(latestRecord),
       );
     }).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.healing, color: AppTheme.greenColor),
                const SizedBox(width: 8),
                Text(
                  'Wound Recovery Rate',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 20,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppTheme.borderColor,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: AppTheme.borderColor,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < patients.length) {
                            final date = patients[index].progressRecords.last.date;
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                '${date.day}/${date.month}',
                                style: TextStyle(
                                  color: AppTheme.secondaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  minX: 0,
                  maxX: woundData.isNotEmpty ? (woundData.length - 1).toDouble() : 1,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: woundData,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.greenColor.withOpacity(0.8),
                          AppTheme.greenColor.withOpacity(0.3),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppTheme.greenColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.greenColor.withOpacity(0.3),
                            AppTheme.greenColor.withOpacity(0.1),
                          ],
                        ),
                      ),
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

  Widget _buildWeightLossChart(List<Patient> patients) {
    // Filter patients with weight loss treatment
    final weightLossPatients = patients.where((p) => 
      p.treatmentType == TreatmentType.weightLoss || p.treatmentType == TreatmentType.both
    ).toList();
    
    // Calculate weight loss progress over time
    final now = DateTime.now();
    final weightLossData = <FlSpot>[];
    
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final patientsWithData = weightLossPatients.where((p) => 
        p.progressRecords.isNotEmpty && 
        p.progressRecords.any((record) => 
          record.date.year == month.year && record.date.month == month.month
        )
      ).toList();
      
      if (patientsWithData.isNotEmpty) {
        final avgProgress = patientsWithData.map((p) {
          final monthRecords = p.progressRecords.where((record) => 
            record.date.year == month.year && record.date.month == month.month
          ).toList();
          if (monthRecords.isNotEmpty) {
            final record = monthRecords.last;
            // Calculate weight loss progress based on weight reduction
            // For demo purposes, we'll use a simple calculation
            // In a real app, you'd compare with initial weight
            return (record.weight > 0) ? 50.0 : 0.0; // Simplified weight loss progress
          }
          return 0.0;
        }).reduce((a, b) => a + b) / patientsWithData.length;
        
        weightLossData.add(FlSpot(i.toDouble(), avgProgress));
      } else {
        weightLossData.add(FlSpot(i.toDouble(), 0));
      }
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_weight, color: AppTheme.pinkColor),
                const SizedBox(width: 8),
                Text(
                  'Weight Loss Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 20,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppTheme.borderColor,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: AppTheme.borderColor,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const months = ['6m ago', '5m ago', '4m ago', '3m ago', '2m ago', '1m ago'];
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              months[value.toInt()],
                              style: TextStyle(
                                color: AppTheme.secondaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  minX: 0,
                  maxX: 5,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: weightLossData,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.pinkColor.withOpacity(0.8),
                          AppTheme.pinkColor.withOpacity(0.3),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppTheme.pinkColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.pinkColor.withOpacity(0.3),
                            AppTheme.pinkColor.withOpacity(0.1),
                          ],
                        ),
                      ),
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

  Widget _buildTreatmentTypeChart(List<Patient> patients) {
    final woundHealingCount = patients.where((p) => p.treatmentType == TreatmentType.woundHealing).length;
    final weightLossCount = patients.where((p) => p.treatmentType == TreatmentType.weightLoss).length;
    final bothCount = patients.where((p) => p.treatmentType == TreatmentType.both).length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Treatment Types',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTreatmentTypeItem('Wound Healing', woundHealingCount, AppTheme.primaryColor),
                const SizedBox(height: 12),
                _buildTreatmentTypeItem('Weight Loss', weightLossCount, AppTheme.greenColor),
                const SizedBox(height: 12),
                _buildTreatmentTypeItem('Both', bothCount, AppTheme.pinkColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentTypeItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(List<Patient> patients) {
    final recentPatients = patients.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Patient Activity',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 2,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentPatients.length,
            itemBuilder: (context, index) {
              final patient = recentPatients[index];
              final latestRecord = patient.progressRecords.isNotEmpty 
                  ? patient.progressRecords.last 
                  : null;
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: index < recentPatients.length - 1 
                        ? BorderSide(color: AppTheme.borderColor.withOpacity(0.3))
                        : BorderSide.none,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient Header
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            color: AppTheme.primaryColor,
                            size: 20,
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
                                patient.treatmentType.toString().split('.').last,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
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
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    if (latestRecord != null) ...[
                      const SizedBox(height: 16),
                      
                      // Metrics Grid
                      Row(
                        children: [
                          // Pain Scale
                          Expanded(
                            child: _buildMetricItem(
                              'Pain Scale',
                              '${latestRecord.painLevel.toInt()}/10',
                              Icons.trending_down,
                              _getPainColor(latestRecord.painLevel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Wound Recovery Rate
                          if (patient.treatmentType == TreatmentType.woundHealing || 
                              patient.treatmentType == TreatmentType.both)
                            Expanded(
                              child: _buildMetricItem(
                                'Wound Recovery',
                                '${_calculateWoundRecovery(latestRecord).toStringAsFixed(1)}%',
                                Icons.healing,
                                AppTheme.greenColor,
                              ),
                            ),
                          
                          // Weight Loss/Gain
                          if (patient.treatmentType == TreatmentType.weightLoss || 
                              patient.treatmentType == TreatmentType.both)
                            Expanded(
                              child: _buildMetricItem(
                                'Weight',
                                '${latestRecord.weight.toStringAsFixed(1)}kg',
                                Icons.monitor_weight,
                                AppTheme.pinkColor,
                              ),
                            ),
                        ],
                      ),
                      
                      // Last Updated
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppTheme.secondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Updated ${_formatRelativeDate(latestRecord.date)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      Text(
                        'No progress data available',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.secondaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPatientsTab() {
    return provider_package.Consumer<PatientDataProvider>(
      builder: (context, patientProvider, child) {
        final providerPatients = _getProviderPatients(patientProvider);
        final filteredPatients = _getFilteredPatients(providerPatients);

        return Column(
          children: [
            // Search and Filters
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                border: Border(
                  bottom: BorderSide(color: AppTheme.borderColor),
                ),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search patients...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            
            // Patients List
            Expanded(
              child: filteredPatients.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppTheme.secondaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No patients found',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredPatients.length,
                      itemBuilder: (context, index) {
                        final patient = filteredPatients[index];
                        return _buildPatientCard(patient);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPatientCard(Patient patient) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      child: InkWell(
        onTap: () {
          _showPatientDashboard(patient);
        },
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.person,
              color: AppTheme.primaryColor,
            ),
          ),
          title: Text(
            patient.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${patient.treatmentType.toString().split('.').last}'),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: patient.overallProgress / 100,
                      backgroundColor: AppTheme.borderColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        patient.overallProgress > 50 
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${patient.overallProgress.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: patient.overallProgress > 50 
                          ? AppTheme.successColor
                          : AppTheme.warningColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.secondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Patient> _getProviderPatients(PatientDataProvider patientProvider) {
    // In a real app, you would filter patients by provider ID
    // For now, we'll return all patients as mock data
    return patientProvider.patients;
  }

  List<Patient> _getFilteredPatients(List<Patient> patients) {
    if (_searchQuery.isEmpty) {
      return patients;
    }
    
    return patients.where((patient) {
      return patient.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             patient.treatmentType.toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  Color _getPainColor(double painLevel) {
    if (painLevel <= 3) return AppTheme.successColor;
    if (painLevel <= 6) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  double _calculateWoundRecovery(ProgressRecord record) {
    // Calculate wound recovery based on wound size reduction
    // Smaller wound size = better recovery
    return (1.0 - (record.woundSize / 100.0)) * 100.0;
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showPatientDashboard(Patient patient) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PatientDashboardScreen(patient: patient),
      ),
    );
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
}

class _NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;

  _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
  });
}

class PatientDashboardScreen extends StatefulWidget {
  final Patient patient;

  const PatientDashboardScreen({
    super.key,
    required this.patient,
  });

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Chart filters and state
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showWoundChart = true;
  bool _showPainChart = true;
  bool _showWeightChart = true;
  String _selectedTimeRange = 'All Time';
  
  final List<String> _timeRangeOptions = [
    'All Time',
    'Last 7 Days',
    'Last 30 Days',
    'Last 3 Months',
    'Last 6 Months',
    'This Year',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeDateRange();
  }
  
  void _initializeDateRange() {
    if (widget.patient.progressRecords.isNotEmpty) {
      _startDate = widget.patient.progressRecords.first.date;
      _endDate = widget.patient.progressRecords.last.date;
    }
  }
  
  List<ProgressRecord> _getFilteredRecords() {
    if (widget.patient.progressRecords.isEmpty) return [];
    
    DateTime? filterStartDate;
    DateTime? filterEndDate;
    
    switch (_selectedTimeRange) {
      case 'Last 7 Days':
        filterEndDate = DateTime.now();
        filterStartDate = filterEndDate.subtract(const Duration(days: 7));
        break;
      case 'Last 30 Days':
        filterEndDate = DateTime.now();
        filterStartDate = filterEndDate.subtract(const Duration(days: 30));
        break;
      case 'Last 3 Months':
        filterEndDate = DateTime.now();
        filterStartDate = DateTime(filterEndDate.year, filterEndDate.month - 3, filterEndDate.day);
        break;
      case 'Last 6 Months':
        filterEndDate = DateTime.now();
        filterStartDate = DateTime(filterEndDate.year, filterEndDate.month - 6, filterEndDate.day);
        break;
      case 'This Year':
        filterStartDate = DateTime(DateTime.now().year, 1, 1);
        filterEndDate = DateTime.now();
        break;
      default: // All Time
        return widget.patient.progressRecords;
    }
    
    return widget.patient.progressRecords.where((record) {
      return record.date.isAfter(filterStartDate!) && 
             record.date.isBefore(filterEndDate!.add(const Duration(days: 1)));
    }).toList();
  }
  
  Map<String, dynamic> _calculateWoundStatistics() {
    final records = _getFilteredRecords();
    if (records.isEmpty) return {};
    
    final recoveryRates = records.map((r) => _calculateWoundRecovery(r)).toList();
    final avgRecovery = recoveryRates.reduce((a, b) => a + b) / recoveryRates.length;
    final maxRecovery = recoveryRates.reduce((a, b) => a > b ? a : b);
    final minRecovery = recoveryRates.reduce((a, b) => a < b ? a : b);
    
    // Calculate trend (positive if improving)
    double trend = 0;
    if (recoveryRates.length > 1) {
      trend = recoveryRates.last - recoveryRates.first;
    }
    
    return {
      'average': avgRecovery,
      'maximum': maxRecovery,
      'minimum': minRecovery,
      'trend': trend,
      'totalSessions': records.length,
    };
  }
  
  Map<String, dynamic> _calculatePainStatistics() {
    final records = _getFilteredRecords();
    if (records.isEmpty) return {};
    
    final painLevels = records.map((r) => r.painLevel).toList();
    final avgPain = painLevels.reduce((a, b) => a + b) / painLevels.length;
    final maxPain = painLevels.reduce((a, b) => a > b ? a : b);
    final minPain = painLevels.reduce((a, b) => a < b ? a : b);
    
    // Calculate trend (negative if improving - pain decreasing)
    double trend = 0;
    if (painLevels.length > 1) {
      trend = painLevels.last - painLevels.first;
    }
    
    return {
      'average': avgPain,
      'maximum': maxPain,
      'minimum': minPain,
      'trend': trend,
      'totalSessions': records.length,
    };
  }
  
  Map<String, dynamic> _calculateWeightStatistics() {
    final records = _getFilteredRecords();
    if (records.isEmpty) return {};
    
    final weights = records.map((r) => r.weight).toList();
    final avgWeight = weights.reduce((a, b) => a + b) / weights.length;
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    
    // Calculate trend (negative if losing weight)
    double trend = 0;
    if (weights.length > 1) {
      trend = weights.last - weights.first;
    }
    
    return {
      'average': avgWeight,
      'maximum': maxWeight,
      'minimum': minWeight,
      'trend': trend,
      'totalSessions': records.length,
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.desktopBackgroundColor,
      body: Row(
        children: [
          // Sidebar Navigation
          _buildSidebar(),
          
          // Main Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Enhanced Header
                  _buildEnhancedHeader(),
                  const SizedBox(height: 24),
                  
                  // Statistics Overview
                  _buildStatisticsOverview(),
                  const SizedBox(height: 24),
                  
                  // Content Area
                  _buildContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: AppTheme.borderColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Back Button
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Back',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Patient Quick Info
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Patient Avatar
                Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        color: AppTheme.primaryColor,
                        size: 40,
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: widget.patient.isActive ? AppTheme.successColor : AppTheme.warningColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          widget.patient.isActive ? Icons.check : Icons.schedule,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Patient Name
                Text(
                  widget.patient.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                
                // Treatment Type
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTreatmentTypeColor(widget.patient.treatmentType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getTreatmentTypeColor(widget.patient.treatmentType).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getTreatmentTypeString(widget.patient.treatmentType),
                    style: TextStyle(
                      color: _getTreatmentTypeColor(widget.patient.treatmentType),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Quick Stats
                _buildSidebarQuickStats(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarQuickStats() {
    final latestRecord = widget.patient.progressRecords.isNotEmpty 
        ? widget.patient.progressRecords.last 
        : null;
    
    return Column(
      children: [
        _buildSidebarStatItem(
          'Overall Progress',
          '${widget.patient.overallProgress.toStringAsFixed(1)}%',
          Icons.trending_up,
          widget.patient.overallProgress > 50 ? AppTheme.successColor : AppTheme.warningColor,
        ),
        const SizedBox(height: 12),
        _buildSidebarStatItem(
          'Total Sessions',
          widget.patient.progressRecords.length.toString(),
          Icons.event_note,
          AppTheme.primaryColor,
        ),
        const SizedBox(height: 12),
        _buildSidebarStatItem(
          'Current Pain',
          latestRecord != null ? '${latestRecord.painLevel.toInt()}/10' : 'N/A',
          Icons.trending_down,
          latestRecord != null ? _getPainColor(latestRecord.painLevel) : AppTheme.secondaryColor,
        ),
      ],
    );
  }

  Widget _buildSidebarStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedHeader() {
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
                  Icons.person,
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
                      'Patient Dashboard',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.patient.name} - ${_getTreatmentTypeString(widget.patient.treatmentType)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  _buildQuickActionButton(
                    icon: Icons.edit,
                    label: 'Edit Patient',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit functionality coming soon!')),
                      );
                    },
                    isPrimary: true,
                  ),
                  const SizedBox(width: 12),
                  _buildQuickActionButton(
                    icon: Icons.download,
                    label: 'Export Data',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export functionality coming soon!')),
                      );
                    },
                    isPrimary: false,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.white : Colors.white.withOpacity(0.2),
        foregroundColor: isPrimary ? AppTheme.primaryColor : Colors.white,
        elevation: isPrimary ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final latestRecord = widget.patient.progressRecords.isNotEmpty 
        ? widget.patient.progressRecords.last 
        : null;
    
    return Row(
      children: [
        _buildStatItem(
          icon: Icons.trending_up,
          value: '${widget.patient.overallProgress.toStringAsFixed(1)}%',
          label: 'Overall Progress',
          color: Colors.white,
        ),
        const SizedBox(width: 32),
        _buildStatItem(
          icon: Icons.event_note,
          value: widget.patient.progressRecords.length.toString(),
          label: 'Total Sessions',
          color: AppTheme.successColor,
        ),
        const SizedBox(width: 32),
        _buildStatItem(
          icon: Icons.trending_down,
          value: latestRecord != null ? '${latestRecord.painLevel.toInt()}/10' : 'N/A',
          label: 'Current Pain',
          color: latestRecord != null ? _getPainColor(latestRecord.painLevel) : Colors.white.withOpacity(0.7),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
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
    );
  }

  Widget _buildStatisticsOverview() {
    final latestRecord = widget.patient.progressRecords.isNotEmpty 
        ? widget.patient.progressRecords.last 
        : null;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Overall Progress',
            value: '${widget.patient.overallProgress.toStringAsFixed(1)}%',
            icon: Icons.trending_up,
            color: widget.patient.overallProgress > 50 ? AppTheme.successColor : AppTheme.warningColor,
            subtitle: 'Treatment completion',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Total Sessions',
            value: widget.patient.progressRecords.length.toString(),
            icon: Icons.event_note,
            color: AppTheme.primaryColor,
            subtitle: 'Completed sessions',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Current Pain',
            value: latestRecord != null ? '${latestRecord.painLevel.toInt()}/10' : 'N/A',
            icon: Icons.trending_down,
            color: latestRecord != null ? _getPainColor(latestRecord.painLevel) : AppTheme.secondaryColor,
            subtitle: 'Latest pain level',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Treatment Duration',
            value: '${_calculateTreatmentDuration()} days',
            icon: Icons.calendar_today,
            color: AppTheme.infoColor,
            subtitle: 'Days since start',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(
                Icons.more_vert,
                color: AppTheme.secondaryColor.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Tab Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.secondaryColor,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Charts'),
              Tab(text: 'Sessions'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Tab Content
        SizedBox(
          height: 600, // Fixed height for tab content
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildChartsTab(),
              _buildSessionsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.gradientBackgroundStart,
            AppTheme.gradientBackgroundCenter,
            AppTheme.gradientBackgroundEnd,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
        child: Column(
          children: [
            // Main Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern Avatar with Status
                Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        color: AppTheme.primaryColor,
                        size: 36,
                      ),
                    ),
                    // Status Indicator
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: widget.patient.overallProgress > 50 
                              ? AppTheme.successColor
                              : AppTheme.warningColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.backgroundColor,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          widget.patient.overallProgress > 50 
                              ? Icons.check
                              : Icons.schedule,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                
                // Patient Info Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                             // Name and Treatment Type
                       Row(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Expanded(
                             child: Text(
                               widget.patient.name,
                               style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                 fontWeight: FontWeight.bold,
                                 color: AppTheme.textColor,
                                 fontSize: 26,
                                 height: 1.2,
                               ),
                             ),
                           ),
                           const SizedBox(width: 16),
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                             decoration: BoxDecoration(
                               color: _getTreatmentTypeColor(widget.patient.treatmentType).withOpacity(0.12),
                               borderRadius: BorderRadius.circular(18),
                               border: Border.all(
                                 color: _getTreatmentTypeColor(widget.patient.treatmentType).withOpacity(0.25),
                                 width: 1,
                               ),
                             ),
                             child: Text(
                               widget.patient.treatmentType.toString().split('.').last,
                               style: TextStyle(
                                 color: _getTreatmentTypeColor(widget.patient.treatmentType),
                                 fontWeight: FontWeight.w600,
                                 fontSize: 12,
                               ),
                             ),
                           ),
                         ],
                       ),
                                             const SizedBox(height: 20),
                       
                       // Patient Details Grid
                       Wrap(
                         spacing: 12,
                         runSpacing: 8,
                         children: [
                           _buildDetailChip(
                             Icons.calendar_today,
                             'Started ${_formatDate(widget.patient.treatmentStartDate)}',
                             AppTheme.secondaryColor,
                           ),
                           _buildDetailChip(
                             Icons.event_note,
                             '${widget.patient.progressRecords.length} Sessions',
                             AppTheme.primaryColor,
                           ),
                           _buildDetailChip(
                             Icons.access_time,
                             'Last: ${widget.patient.progressRecords.isNotEmpty 
                                 ? _formatRelativeDate(widget.patient.progressRecords.last.date)
                                 : 'No sessions'}',
                             AppTheme.greenColor,
                           ),
                         ],
                       ),
                    ],
                  ),
                ),
                
                                 // Progress Section
                 Container(
                   padding: const EdgeInsets.all(20),
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(16),
                     border: Border.all(
                       color: AppTheme.borderColor.withOpacity(0.3),
                       width: 1,
                     ),
                     boxShadow: [
                       BoxShadow(
                         color: AppTheme.shadowColor.withOpacity(0.08),
                         blurRadius: 12,
                         offset: const Offset(0, 4),
                       ),
                     ],
                   ),
                  child: Column(
                    children: [
                      Text(
                        'Overall Progress',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${widget.patient.overallProgress.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.patient.overallProgress > 50 
                              ? AppTheme.successColor
                              : AppTheme.warningColor,
                          fontSize: 28,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: widget.patient.overallProgress / 100,
                            backgroundColor: AppTheme.borderColor.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.patient.overallProgress > 50 
                                  ? AppTheme.successColor
                                  : AppTheme.warningColor,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Quick Stats Row
            if (widget.patient.progressRecords.isNotEmpty) ...[
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.borderColor.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowColor.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickStat(
                        'Current Pain',
                        '${widget.patient.progressRecords.last.painLevel.toInt()}/10',
                        Icons.trending_down,
                        _getPainColor(widget.patient.progressRecords.last.painLevel),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: AppTheme.borderColor.withOpacity(0.25),
                    ),
                    if (widget.patient.treatmentType == TreatmentType.woundHealing || 
                        widget.patient.treatmentType == TreatmentType.both) ...[
                      Expanded(
                        child: _buildQuickStat(
                          'Wound Recovery',
                          '${_calculateWoundRecovery(widget.patient.progressRecords.last).toStringAsFixed(1)}%',
                          Icons.healing,
                          AppTheme.greenColor,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: AppTheme.borderColor.withOpacity(0.25),
                      ),
                    ],
                    if (widget.patient.treatmentType == TreatmentType.weightLoss || 
                        widget.patient.treatmentType == TreatmentType.both)
                      Expanded(
                        child: _buildQuickStat(
                          'Current Weight',
                          '${widget.patient.progressRecords.last.weight.toStringAsFixed(1)}kg',
                          Icons.monitor_weight,
                          AppTheme.pinkColor,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // General Client Info
          _buildGeneralInfo(),
          const SizedBox(height: 32),
          
          // Quick Stats
          _buildOverviewQuickStats(),
          const SizedBox(height: 32),
          
          // Recent Sessions Summary
          _buildRecentSessionsSummary(),
        ],
      ),
    );
  }

  Widget _buildGeneralInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General Client Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Name', widget.patient.name),
                ),
                                 Expanded(
                   child: _buildInfoItem('Age', '${_calculateAge(widget.patient.dateOfBirth)} years'),
                 ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Treatment Type', widget.patient.treatmentType.toString().split('.').last),
                ),
                                 Expanded(
                   child: _buildInfoItem('Start Date', _formatDate(widget.patient.treatmentStartDate)),
                 ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Total Sessions', widget.patient.progressRecords.length.toString()),
                ),
                Expanded(
                  child: _buildInfoItem('Last Session', widget.patient.progressRecords.isNotEmpty 
                      ? _formatDate(widget.patient.progressRecords.last.date)
                      : 'No sessions yet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewQuickStats() {
    final latestRecord = widget.patient.progressRecords.isNotEmpty 
        ? widget.patient.progressRecords.last 
        : null;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildQuickStatItem(
                    'Pain Level',
                    latestRecord != null ? '${latestRecord.painLevel.toInt()}/10' : 'N/A',
                    Icons.trending_down,
                    latestRecord != null ? _getPainColor(latestRecord.painLevel) : AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                if (widget.patient.treatmentType == TreatmentType.woundHealing || 
                    widget.patient.treatmentType == TreatmentType.both)
                  Expanded(
                    child: _buildQuickStatItem(
                      'Wound Recovery',
                      latestRecord != null ? '${_calculateWoundRecovery(latestRecord).toStringAsFixed(1)}%' : 'N/A',
                      Icons.healing,
                      AppTheme.greenColor,
                    ),
                  ),
                if (widget.patient.treatmentType == TreatmentType.weightLoss || 
                    widget.patient.treatmentType == TreatmentType.both)
                  Expanded(
                    child: _buildQuickStatItem(
                      'Weight',
                      latestRecord != null ? '${latestRecord.weight.toStringAsFixed(1)}kg' : 'N/A',
                      Icons.monitor_weight,
                      AppTheme.pinkColor,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessionsSummary() {
    final recentSessions = widget.patient.progressRecords.take(3).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Sessions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (recentSessions.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_note_outlined,
                      size: 48,
                      color: AppTheme.secondaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No sessions recorded yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: recentSessions.map((session) => _buildSessionSummaryItem(session)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionSummaryItem(ProgressRecord session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.event, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(session.date),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Pain: ${session.painLevel.toInt()}/10',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppTheme.secondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildChartsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filters Section
          _buildChartFilters(),
          const SizedBox(height: 24),
          
          // Summary Statistics
          _buildSummaryStatistics(),
          const SizedBox(height: 24),
          
          // Quick Insights
          _buildQuickInsights(),
          const SizedBox(height: 24),
          
          // Wound Recovery Chart
          if ((widget.patient.treatmentType == TreatmentType.woundHealing || 
               widget.patient.treatmentType == TreatmentType.both) && _showWoundChart)
            _buildWoundRecoveryChart(),
          
          if ((widget.patient.treatmentType == TreatmentType.woundHealing || 
               widget.patient.treatmentType == TreatmentType.both) && _showWoundChart)
            const SizedBox(height: 24),
          
          // Pain Scale Chart
          if (_showPainChart) _buildPainScaleChart(),
          if (_showPainChart) const SizedBox(height: 24),
          
          // Weight Loss/Gain Chart
          if ((widget.patient.treatmentType == TreatmentType.weightLoss || 
               widget.patient.treatmentType == TreatmentType.both) && _showWeightChart)
            _buildWeightChart(),
        ],
      ),
    );
  }
  
  Widget _buildChartFilters() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Chart Filters',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _exportChartData,
                  icon: const Icon(Icons.download),
                  label: const Text('Export Data'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Time Range Filter
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time Range',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedTimeRange,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _timeRangeOptions.map((range) {
                          return DropdownMenuItem(
                            value: range,
                            child: Text(range),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTimeRange = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                
                // Chart Visibility Filters
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chart Visibility',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        children: [
                          if (widget.patient.treatmentType == TreatmentType.woundHealing || 
                              widget.patient.treatmentType == TreatmentType.both)
                            FilterChip(
                              label: const Text('Wound Recovery'),
                              selected: _showWoundChart,
                              onSelected: (selected) {
                                setState(() {
                                  _showWoundChart = selected;
                                });
                              },
                              selectedColor: AppTheme.greenColor.withOpacity(0.2),
                              checkmarkColor: AppTheme.greenColor,
                            ),
                          FilterChip(
                            label: const Text('Pain Scale'),
                            selected: _showPainChart,
                            onSelected: (selected) {
                              setState(() {
                                _showPainChart = selected;
                              });
                            },
                            selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                            checkmarkColor: AppTheme.primaryColor,
                          ),
                          if (widget.patient.treatmentType == TreatmentType.weightLoss || 
                              widget.patient.treatmentType == TreatmentType.both)
                            FilterChip(
                              label: const Text('Weight'),
                              selected: _showWeightChart,
                              onSelected: (selected) {
                                setState(() {
                                  _showWeightChart = selected;
                                });
                              },
                              selectedColor: AppTheme.pinkColor.withOpacity(0.2),
                              checkmarkColor: AppTheme.pinkColor,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryStatistics() {
    final filteredRecords = _getFilteredRecords();
    if (filteredRecords.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 48,
                  color: AppTheme.secondaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No data available for selected time range',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Summary Statistics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${filteredRecords.length} sessions',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                if ((widget.patient.treatmentType == TreatmentType.woundHealing || 
                     widget.patient.treatmentType == TreatmentType.both) && _showWoundChart)
                  _buildStatisticCard(
                    'Wound Recovery',
                    _calculateWoundStatistics(),
                    AppTheme.greenColor,
                    Icons.healing,
                  ),
                if (_showPainChart)
                  _buildStatisticCard(
                    'Pain Level',
                    _calculatePainStatistics(),
                    AppTheme.primaryColor,
                    Icons.trending_down,
                  ),
                if ((widget.patient.treatmentType == TreatmentType.weightLoss || 
                     widget.patient.treatmentType == TreatmentType.both) && _showWeightChart)
                  _buildStatisticCard(
                    'Weight',
                    _calculateWeightStatistics(),
                    AppTheme.pinkColor,
                    Icons.monitor_weight,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatisticCard(String title, Map<String, dynamic> stats, Color color, IconData icon) {
    if (stats.isEmpty) return const SizedBox.shrink();
    
    final trend = stats['trend'] as double;
    final isPositive = (title == 'Wound Recovery' && trend > 0) ||
                      (title == 'Pain Level' && trend < 0) ||
                      (title == 'Weight' && trend < 0);
    
    return GestureDetector(
      onTap: () => _showChartDetails(title, stats),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 16,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${trend.abs().toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatisticItem(
                    'Avg',
                    '${stats['average'].toStringAsFixed(1)}',
                    color,
                  ),
                ),
                Expanded(
                  child: _buildStatisticItem(
                    'Max',
                    '${stats['maximum'].toStringAsFixed(1)}',
                    color,
                  ),
                ),
                Expanded(
                  child: _buildStatisticItem(
                    'Min',
                    '${stats['minimum'].toStringAsFixed(1)}',
                    color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: color.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  'Tap for details',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatisticItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  
  void _exportChartData() {
    final filteredRecords = _getFilteredRecords();
    if (filteredRecords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export')),
      );
      return;
    }
    
    // TODO: Implement actual export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting ${filteredRecords.length} records...'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // TODO: Show export preview
          },
        ),
      ),
    );
  }
  
  Widget _buildQuickInsights() {
    final filteredRecords = _getFilteredRecords();
    if (filteredRecords.isEmpty) return const SizedBox.shrink();
    
    final insights = <String>[];
    
    // Wound healing insights
    if (widget.patient.treatmentType == TreatmentType.woundHealing || 
        widget.patient.treatmentType == TreatmentType.both) {
      final woundStats = _calculateWoundStatistics();
      if (woundStats.isNotEmpty) {
        final trend = woundStats['trend'] as double;
        if (trend > 0) {
          insights.add('Wound recovery is improving by ${trend.abs().toStringAsFixed(1)}%');
        } else if (trend < 0) {
          insights.add('Wound recovery needs attention - declined by ${trend.abs().toStringAsFixed(1)}%');
        }
      }
    }
    
    // Pain level insights
    final painStats = _calculatePainStatistics();
    if (painStats.isNotEmpty) {
      final trend = painStats['trend'] as double;
      if (trend < 0) {
        insights.add('Pain levels decreasing - good progress in pain management');
      } else if (trend > 0) {
        insights.add('Pain levels increasing - review pain management strategy');
      }
    }
    
    // Weight insights
    if (widget.patient.treatmentType == TreatmentType.weightLoss || 
        widget.patient.treatmentType == TreatmentType.both) {
      final weightStats = _calculateWeightStatistics();
      if (weightStats.isNotEmpty) {
        final trend = weightStats['trend'] as double;
        if (trend < 0) {
          insights.add('Weight loss progress - ${weightStats['totalSessions']} sessions completed');
        } else if (trend > 0) {
          insights.add('Weight gain detected - review dietary recommendations');
        }
      }
    }
    
    if (insights.isEmpty) return const SizedBox.shrink();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppTheme.warningColor),
                const SizedBox(width: 8),
                Text(
                  'Quick Insights',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...insights.map((insight) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppTheme.greenColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
  
  void _showChartDetails(String chartType, Map<String, dynamic> stats) {
    final color = chartType == 'Wound Recovery' ? AppTheme.greenColor :
                  chartType == 'Pain Level' ? AppTheme.primaryColor : AppTheme.pinkColor;
    
    final trend = stats['trend'] as double;
    final isPositive = (chartType == 'Wound Recovery' && trend > 0) ||
                      (chartType == 'Pain Level' && trend < 0) ||
                      (chartType == 'Weight' && trend < 0);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        chartType == 'Wound Recovery' ? Icons.healing :
                        chartType == 'Pain Level' ? Icons.trending_down : Icons.monitor_weight,
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$chartType Analysis',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${stats['totalSessions']} sessions analyzed',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Trend Indicator
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPositive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPositive ? Icons.trending_up : Icons.trending_down,
                            color: isPositive ? Colors.green : Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isPositive ? 'Positive Trend' : 'Needs Attention',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isPositive ? Colors.green : Colors.red,
                                  ),
                                ),
                                Text(
                                  'Change: ${trend.abs().toStringAsFixed(1)} ${_getUnit(chartType)}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                                         // Statistics Grid
                     Row(
                       children: [
                         Expanded(
                           child: _buildDetailStatisticCard(
                             'Average',
                             '${stats['average'].toStringAsFixed(1)}',
                             _getUnit(chartType),
                             color,
                             Icons.analytics,
                           ),
                         ),
                         const SizedBox(width: 12),
                         Expanded(
                           child: _buildDetailStatisticCard(
                             'Maximum',
                             '${stats['maximum'].toStringAsFixed(1)}',
                             _getUnit(chartType),
                             color,
                             Icons.trending_up,
                           ),
                         ),
                       ],
                     ),
                     
                     const SizedBox(height: 12),
                     
                     Row(
                       children: [
                         Expanded(
                           child: _buildDetailStatisticCard(
                             'Minimum',
                             '${stats['minimum'].toStringAsFixed(1)}',
                             _getUnit(chartType),
                             color,
                             Icons.trending_down,
                           ),
                         ),
                         const SizedBox(width: 12),
                         Expanded(
                           child: _buildDetailStatisticCard(
                             'Sessions',
                             '${stats['totalSessions']}',
                             '',
                             color,
                             Icons.calendar_today,
                           ),
                         ),
                       ],
                     ),
                    
                    const SizedBox(height: 24),
                    
                    // Interpretation
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: color,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Professional Insight',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getChartInterpretation(chartType, stats),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getUnit(String chartType) {
    switch (chartType) {
      case 'Wound Recovery':
        return '%';
      case 'Pain Level':
        return '/10';
      case 'Weight':
        return 'kg';
      default:
        return '';
    }
  }
  
  Widget _buildDetailStatisticCard(String label, String value, String unit, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value$unit',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getChartInterpretation(String chartType, Map<String, dynamic> stats) {
    final trend = stats['trend'] as double;
    
    switch (chartType) {
      case 'Wound Recovery':
        if (trend > 0) {
          return 'Wound recovery is improving over time. The patient is showing positive progress in healing.';
        } else if (trend < 0) {
          return 'Wound recovery has declined. Consider reviewing treatment approach.';
        } else {
          return 'Wound recovery is stable. Monitor for any changes in condition.';
        }
      case 'Pain Level':
        if (trend < 0) {
          return 'Pain levels are decreasing, indicating effective pain management.';
        } else if (trend > 0) {
          return 'Pain levels are increasing. Review pain management strategy.';
        } else {
          return 'Pain levels are stable. Continue current pain management approach.';
        }
      case 'Weight':
        if (trend < 0) {
          return 'Weight is decreasing, which may be positive for weight loss goals.';
        } else if (trend > 0) {
          return 'Weight is increasing. Review dietary and exercise recommendations.';
        } else {
          return 'Weight is stable. Maintain current lifestyle habits.';
        }
      default:
        return 'Data analysis complete.';
    }
  }
  
  void _showSessionDetails(ProgressRecord record, String chartType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              chartType == 'Wound Recovery' ? Icons.healing :
              chartType == 'Pain Level' ? Icons.trending_down : Icons.monitor_weight,
              color: chartType == 'Wound Recovery' ? AppTheme.greenColor :
                     chartType == 'Pain Level' ? AppTheme.primaryColor : AppTheme.pinkColor,
            ),
            const SizedBox(width: 8),
            Text('Session Details'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Date', _formatDate(record.date)),
            _buildDetailRow('Wound Size', '${record.woundSize} cm²'),
            _buildDetailRow('Wound Depth', '${record.woundDepth} cm'),
            _buildDetailRow('Pain Level', '${record.painLevel}/10'),
            _buildDetailRow('Weight', '${record.weight} kg'),
            _buildDetailRow('Mobility Score', '${record.mobilityScore}/100'),
            if (record.woundDescription.isNotEmpty)
              _buildDetailRow('Description', record.woundDescription),
            if (record.images.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    record.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.backgroundColor.withOpacity(0.1),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
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

  Widget _buildWoundRecoveryChart() {
    final filteredRecords = _getFilteredRecords();
    if (filteredRecords.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.healing, color: AppTheme.greenColor),
                  const SizedBox(width: 8),
                  Text(
                    'Wound Recovery Rate',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 48,
                        color: AppTheme.secondaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No data available',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.secondaryColor,
                        ),
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

    final woundData = filteredRecords.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        _calculateWoundRecovery(entry.value),
      );
    }).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.healing, color: AppTheme.greenColor),
                const SizedBox(width: 8),
                Text(
                  'Wound Recovery Rate',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 20,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppTheme.borderColor,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: AppTheme.borderColor,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < widget.patient.progressRecords.length) {
                            final date = widget.patient.progressRecords[index].date;
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                '${date.day}/${date.month}',
                                style: TextStyle(
                                  color: AppTheme.secondaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  minX: 0,
                  maxX: woundData.isNotEmpty ? (woundData.length - 1).toDouble() : 1,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: woundData,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.greenColor.withOpacity(0.8),
                          AppTheme.greenColor.withOpacity(0.3),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppTheme.greenColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.greenColor.withOpacity(0.3),
                            AppTheme.greenColor.withOpacity(0.1),
                          ],
                        ),
                      ),
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

  Widget _buildPainScaleChart() {
    final filteredRecords = _getFilteredRecords();
    if (filteredRecords.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_down, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Pain Scale After Each Session',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 48,
                        color: AppTheme.secondaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No data available',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.secondaryColor,
                        ),
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

    final painData = filteredRecords.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.painLevel,
      );
    }).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_down, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Pain Scale After Each Session',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 2,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppTheme.borderColor,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: AppTheme.borderColor,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < widget.patient.progressRecords.length) {
                            final date = widget.patient.progressRecords[index].date;
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                '${date.day}/${date.month}',
                                style: TextStyle(
                                  color: AppTheme.secondaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  minX: 0,
                  maxX: painData.isNotEmpty ? (painData.length - 1).toDouble() : 1,
                  minY: 0,
                  maxY: 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: painData,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.8),
                          AppTheme.primaryColor.withOpacity(0.3),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppTheme.primaryColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.3),
                            AppTheme.primaryColor.withOpacity(0.1),
                          ],
                        ),
                      ),
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

  Widget _buildWeightChart() {
    final filteredRecords = _getFilteredRecords();
    if (filteredRecords.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.monitor_weight, color: AppTheme.pinkColor),
                  const SizedBox(width: 8),
                  Text(
                    'Weight Loss/Gain After Each Session',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 48,
                        color: AppTheme.secondaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No data available',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.secondaryColor,
                        ),
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

    final weightData = filteredRecords.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.weight,
      );
    }).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_weight, color: AppTheme.pinkColor),
                const SizedBox(width: 8),
                Text(
                  'Weight Loss/Gain After Each Session',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 10,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppTheme.borderColor,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: AppTheme.borderColor,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < widget.patient.progressRecords.length) {
                            final date = widget.patient.progressRecords[index].date;
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                '${date.day}/${date.month}',
                                style: TextStyle(
                                  color: AppTheme.secondaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            '${value.toInt()}kg',
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  minX: 0,
                  maxX: weightData.isNotEmpty ? (weightData.length - 1).toDouble() : 1,
                  minY: weightData.isNotEmpty ? (weightData.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 5) : 0,
                  maxY: weightData.isNotEmpty ? (weightData.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 5) : 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: weightData,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.pinkColor.withOpacity(0.8),
                          AppTheme.pinkColor.withOpacity(0.3),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppTheme.pinkColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.pinkColor.withOpacity(0.3),
                            AppTheme.pinkColor.withOpacity(0.1),
                          ],
                        ),
                      ),
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

  Widget _buildSessionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Treatment Sessions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 20),
          if (widget.patient.progressRecords.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    size: 64,
                    color: AppTheme.secondaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No sessions recorded yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
            )
          else
            ...widget.patient.progressRecords.map((session) => _buildSessionCard(session)).toList(),
        ],
      ),
    );
  }

  Widget _buildSessionCard(ProgressRecord session) {
    return _SessionCard(
      session: session,
      patient: widget.patient,
      onPainColor: _getPainColor,
      onWoundRecovery: _calculateWoundRecovery,
      onFormatDate: _formatDate,
    );
  }

  Widget _buildSessionDetailItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWoundDetails(ProgressRecord session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wound Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildWoundDetailItem('Wound Type', 'Pressure Ulcer'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildWoundDetailItem('Wound Stage', 'Stage II'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildWoundDetailItem('Location', 'Sacral Area'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildWoundDetailItem('Recovery Rate', '${_calculateWoundRecovery(session).toStringAsFixed(1)}%'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWoundDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWoundImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: AppTheme.secondaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            'Wound Image',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Image would be displayed here',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(ProgressRecord session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Notes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Text(
            session.notes.isNotEmpty ? session.notes : 'No notes recorded for this session.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: session.notes.isNotEmpty ? AppTheme.textColor : AppTheme.secondaryColor,
              fontStyle: session.notes.isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }

  Color _getPainColor(double painLevel) {
    if (painLevel <= 3) return AppTheme.successColor;
    if (painLevel <= 6) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  double _calculateWoundRecovery(ProgressRecord record) {
    return (1.0 - (record.woundSize / 100.0)) * 100.0;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  Color _getTreatmentTypeColor(TreatmentType treatmentType) {
    switch (treatmentType) {
      case TreatmentType.woundHealing:
        return AppTheme.greenColor;
      case TreatmentType.weightLoss:
        return AppTheme.pinkColor;
      case TreatmentType.both:
        return AppTheme.primaryColor;
    }
  }

  Widget _buildDetailChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Helper methods for the enhanced header
  String _getTreatmentTypeString(TreatmentType type) {
    switch (type) {
      case TreatmentType.woundHealing:
        return 'Wound Healing';
      case TreatmentType.weightLoss:
        return 'Weight Loss';
      case TreatmentType.both:
        return 'Both';
    }
  }

  int _calculateTreatmentDuration() {
    final now = DateTime.now();
    return now.difference(widget.patient.treatmentStartDate).inDays;
  }
}

class _SessionCard extends StatefulWidget {
  final ProgressRecord session;
  final Patient patient;
  final Color Function(double) onPainColor;
  final double Function(ProgressRecord) onWoundRecovery;
  final String Function(DateTime) onFormatDate;

  const _SessionCard({
    required this.session,
    required this.patient,
    required this.onPainColor,
    required this.onWoundRecovery,
    required this.onFormatDate,
  });

  @override
  State<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<_SessionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.event, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Session - ${widget.onFormatDate(widget.session.date)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Pain Level: ${widget.session.painLevel.toInt()}/10',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.secondaryColor,
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded Content
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Session Details Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildSessionDetailItem(
                          'Pain Rating',
                          '${widget.session.painLevel.toInt()}/10',
                          Icons.trending_down,
                          widget.onPainColor(widget.session.painLevel),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (widget.patient.treatmentType == TreatmentType.woundHealing || 
                          widget.patient.treatmentType == TreatmentType.both)
                        Expanded(
                          child: _buildSessionDetailItem(
                            'Wound Size',
                            '${widget.session.woundSize.toStringAsFixed(1)}cm²',
                            Icons.healing,
                            AppTheme.greenColor,
                          ),
                        ),
                      if (widget.patient.treatmentType == TreatmentType.weightLoss || 
                          widget.patient.treatmentType == TreatmentType.both)
                        Expanded(
                          child: _buildSessionDetailItem(
                            'Weight',
                            '${widget.session.weight.toStringAsFixed(1)}kg',
                            Icons.monitor_weight,
                            AppTheme.pinkColor,
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Wound Details (if applicable)
                  if (widget.patient.treatmentType == TreatmentType.woundHealing || 
                      widget.patient.treatmentType == TreatmentType.both) ...[
                    _buildWoundDetails(),
                    const SizedBox(height: 20),
                  ],
                  
                  // Wound Image Placeholder
                  if (widget.patient.treatmentType == TreatmentType.woundHealing || 
                      widget.patient.treatmentType == TreatmentType.both)
                    _buildWoundImagePlaceholder(),
                  
                  const SizedBox(height: 20),
                  
                  // Notes Section
                  _buildNotesSection(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionDetailItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWoundDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wound Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildWoundDetailItem('Wound Type', 'Pressure Ulcer'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildWoundDetailItem('Wound Stage', 'Stage II'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildWoundDetailItem('Location', 'Sacral Area'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildWoundDetailItem('Recovery Rate', '${widget.onWoundRecovery(widget.session).toStringAsFixed(1)}%'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWoundDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWoundImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: AppTheme.secondaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            'Wound Image',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Image would be displayed here',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Notes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Text(
            widget.session.notes.isNotEmpty ? widget.session.notes : 'No notes recorded for this session.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: widget.session.notes.isNotEmpty ? AppTheme.textColor : AppTheme.secondaryColor,
              fontStyle: widget.session.notes.isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods for the enhanced header
  String _getTreatmentTypeString(TreatmentType type) {
    switch (type) {
      case TreatmentType.woundHealing:
        return 'Wound Healing';
      case TreatmentType.weightLoss:
        return 'Weight Loss';
      case TreatmentType.both:
        return 'Both';
    }
  }

  int _calculateTreatmentDuration() {
    final now = DateTime.now();
    return now.difference(widget.patient.treatmentStartDate).inDays;
  }
}

