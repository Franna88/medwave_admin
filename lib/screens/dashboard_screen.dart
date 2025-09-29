import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/patient_data_provider.dart';
import '../providers/provider_data_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/dashboard_overview.dart';
import '../widgets/sidebar_navigation.dart';
import 'provider_approvals_screen.dart';
import 'provider_management_screen.dart';
import 'report_builder_screen.dart';
import 'analytics_screen.dart';
import 'patient_management_screen.dart';
import 'admin_management_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;
  
  const DashboardScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _selectedIndex;
  String? _selectedCountry; // Add country filter state
  
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    
    // Initialize data providers after authentication
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDataProviders();
    });
  }

  void _initializeDataProviders() {
    if (kDebugMode) {
      print('🎯 DashboardScreen: _initializeDataProviders() called');
    }
    final providerDataProvider = context.read<ProviderDataProvider>();
    final patientDataProvider = context.read<PatientDataProvider>();
    
    if (kDebugMode) {
      print('🎯 DashboardScreen: Initializing ProviderDataProvider...');
    }
    // Initialize Firebase streams for both providers
    providerDataProvider.initializeAfterAuth();
    
    if (kDebugMode) {
      print('🎯 DashboardScreen: Refreshing PatientDataProvider...');
    }
    patientDataProvider.refresh(); // This should initialize its Firebase streams
    
    if (kDebugMode) {
      print('🎯 DashboardScreen: Data providers initialization complete');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.desktopBackgroundColor,
      body: Row(
        children: [
          // Sidebar Navigation
          SidebarNavigation(
            selectedIndex: _selectedIndex,
            onNavigationChanged: _onNavigationChanged,
          ),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Content Area
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Page Title
          Text(
            _getPageTitle(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(width: 24),
          
          // Country Filters (only show on dashboard) - Flexible to prevent overflow
          if (_selectedIndex == 0) 
            Flexible(
              child: _buildCountryFilters(),
            ),
          
          const Spacer(),
          
          // User Menu
          _buildUserMenu(),
        ],
      ),
    );
  }

  Widget _buildCountryFilters() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Filter by Country:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.secondaryColor,
          ),
        ),
        const SizedBox(width: 8),
        
        // Filter chips in a compact row
        Flexible(
          child: Wrap(
            spacing: 6, // Reduced spacing
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // USA Filter
              _buildFilterChip('USA', '🇺🇸'),
              
              // RSA Filter
              _buildFilterChip('RSA', '🇿🇦'),
              
              // Clear Filter - will stay in same row if possible
              if (_selectedCountry != null)
                _buildClearFilterChip(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String country, String flag) {
    final isSelected = _selectedCountry == country;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag),
          const SizedBox(width: 3), // Reduced spacing
          Text(country),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCountry = selected ? country : null;
        });
        // Notify providers about the filter change
        _applyCountryFilter();
      },
      backgroundColor: AppTheme.cardColor,
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 12, // Even smaller font size
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // More compact padding
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // More compact
    );
  }

  Widget _buildClearFilterChip() {
    return FilterChip(
      label: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.clear, size: 12), // Smaller icon
          SizedBox(width: 3), // Reduced spacing
          Text('Clear'),
        ],
      ),
      selected: false,
      onSelected: (selected) {
        setState(() {
          _selectedCountry = null;
        });
        // Notify providers about the filter change
        _applyCountryFilter();
      },
      backgroundColor: AppTheme.cardColor,
      side: BorderSide(color: AppTheme.borderColor),
      labelStyle: TextStyle(
        color: AppTheme.textColor,
        fontWeight: FontWeight.normal,
        fontSize: 12, // Even smaller font size
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // More compact padding
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // More compact
    );
  }

  void _applyCountryFilter() {
    // Notify providers about the country filter change
    // This will allow the providers to filter their data accordingly
    if (_selectedIndex == 0) {
      // Refresh dashboard data with country filter
      Provider.of<ProviderDataProvider>(context, listen: false)
          .setCountryFilter(_selectedCountry);
      Provider.of<PatientDataProvider>(context, listen: false)
          .setCountryFilter(_selectedCountry);
    }
  }

  Widget _buildUserMenu() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return PopupMenuButton<String>(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryColor,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  authProvider.currentUser ?? 'Admin',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 20),
                  SizedBox(width: 8),
                  Text('Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'logout':
                _showLogoutDialog();
                break;
              case 'profile':
                // TODO: Navigate to profile page
                break;
              case 'settings':
                // TODO: Navigate to settings page
                break;
            }
          },
        );
      },
    );
  }

  Widget _buildContent() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: _getCurrentPage(),
    );
  }

  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardOverview();
      case 1:
        return const ProviderApprovalsScreen();
      case 2:
        return const ProviderManagementScreen();
      case 3:
        return const ReportBuilderScreen();
      case 4:
        return const AnalyticsScreen();
      case 5:
        return const PatientManagementScreen();
      case 6:
        return const AdminManagementScreen();
      default:
        return const DashboardOverview();
    }
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Provider Approvals';
      case 2:
        return 'Provider Management';
      case 3:
        return 'Report Builder';
      case 4:
        return 'Analytics';
      case 5:
        return 'Patient Management';
      case 6:
        return 'Admin Management';
      default:
        return 'Dashboard';
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _onNavigationChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}