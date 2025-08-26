import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_package;
import '../providers/provider_data_provider.dart';
import '../models/provider_model.dart';
import '../theme/app_theme.dart';
import 'provider_profile_screen.dart';

class ProviderManagementScreen extends StatefulWidget {
  const ProviderManagementScreen({super.key});

  @override
  State<ProviderManagementScreen> createState() => _ProviderManagementScreenState();
}

class _ProviderManagementScreenState extends State<ProviderManagementScreen> {
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _packageFilter = 'All';
  bool _showOnlyApproved = false;
  bool _showOnlyPending = false;
  String? _selectedCountry; // Add country filter state

  @override
  Widget build(BuildContext context) {
    return provider_package.Consumer<ProviderDataProvider>(
      builder: (context, providerProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Header with Statistics
              _buildEnhancedHeader(context, providerProvider),
              const SizedBox(height: 24),
              
              // Statistics Overview Cards
              _buildStatisticsOverview(providerProvider),
              const SizedBox(height: 24),
              
              // Filters and Search
              _buildFiltersAndSearch(),
              const SizedBox(height: 24),
              
              // Providers List Header
              _buildProvidersListHeader(providerProvider),
              const SizedBox(height: 16),
              
              // Providers List
              _buildProvidersList(providerProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedHeader(BuildContext context, ProviderDataProvider providerProvider) {
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
                  Icons.medical_services,
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
                      'Provider Management',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage healthcare providers and their account information',
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
                    icon: Icons.add,
                    label: 'Add Provider',
                    onPressed: () => _showAddProviderDialog(context),
                    isPrimary: true,
                  ),
                  const SizedBox(width: 12),
                  _buildQuickActionButton(
                    icon: Icons.download,
                    label: 'Export',
                    onPressed: () => _exportProviders(providerProvider),
                    isPrimary: false,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildQuickStats(providerProvider),
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

  Widget _buildQuickStats(ProviderDataProvider providerProvider) {
    return Row(
      children: [
        _buildStatItem(
          icon: Icons.people,
          value: providerProvider.totalProviders.toString(),
          label: 'Total Providers',
          color: Colors.white,
        ),
        const SizedBox(width: 32),
        _buildStatItem(
          icon: Icons.pending_actions,
          value: providerProvider.totalPendingApprovals.toString(),
          label: 'Pending Approval',
          color: AppTheme.warningColor,
        ),
        const SizedBox(width: 32),
        _buildStatItem(
          icon: Icons.trending_up,
          value: '\$${providerProvider.averageMonthlyRevenue.toStringAsFixed(0)}',
          label: 'Avg Monthly Revenue',
          color: AppTheme.successColor,
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

  Widget _buildStatisticsOverview(ProviderDataProvider providerProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Active Providers',
            value: providerProvider.totalProviders.toString(),
            icon: Icons.check_circle,
            color: AppTheme.successColor,
            subtitle: 'Approved and active',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Pending Approval',
            value: providerProvider.totalPendingApprovals.toString(),
            icon: Icons.pending,
            color: AppTheme.warningColor,
            subtitle: 'Awaiting review',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Monthly Revenue',
            value: '\$${providerProvider.averageMonthlyRevenue.toStringAsFixed(0)}',
            icon: Icons.attach_money,
            color: AppTheme.primaryColor,
            subtitle: 'Average per month',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Growth Rate',
            value: '+12.5%',
            icon: Icons.trending_up,
            color: AppTheme.successColor,
            subtitle: 'This month',
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

  Widget _buildFiltersAndSearch() {
    return Container(
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Icon(Icons.filter_list, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Filters & Search',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Search Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search providers by name, company, or email...',
                      prefixIcon: Icon(Icons.search, color: AppTheme.secondaryColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _buildFilterChip('All Providers', _statusFilter == 'All', () {
                setState(() {
                  _statusFilter = 'All';
                  _showOnlyApproved = false;
                  _showOnlyPending = false;
                });
              }),
              const SizedBox(width: 8),
              _buildFilterChip('Approved', _showOnlyApproved, () {
                setState(() {
                  _statusFilter = 'Approved';
                  _showOnlyApproved = true;
                  _showOnlyPending = false;
                });
              }),
              const SizedBox(width: 8),
              _buildFilterChip('Pending', _showOnlyPending, () {
                setState(() {
                  _statusFilter = 'Pending';
                  _showOnlyApproved = false;
                  _showOnlyPending = true;
                });
              }),
            ],
          ),
          const SizedBox(height: 20),
          
          // Country Filter
          Row(
            children: [
              Icon(Icons.public, color: AppTheme.secondaryColor, size: 16),
              const SizedBox(width: 8),
              Text(
                'Country Filter:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(width: 12),
              _buildCountryFilterChip('All Countries', _selectedCountry == null),
              const SizedBox(width: 8),
              _buildCountryFilterChip('🇺🇸 USA', _selectedCountry == 'USA'),
              const SizedBox(width: 8),
              _buildCountryFilterChip('🇿🇦 RSA', _selectedCountry == 'RSA'),
            ],
          ),
          const SizedBox(height: 20),
          
          // Package Filter
          Row(
            children: [
              Icon(Icons.category, color: AppTheme.secondaryColor, size: 16),
              const SizedBox(width: 8),
              Text(
                'Package Filter:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPackageFilterChip('All', _packageFilter == 'All'),
                    _buildPackageFilterChip('Neuro-100S', _packageFilter == 'Neuro-100S'),
                    _buildPackageFilterChip('Contour-100S', _packageFilter == 'Contour-100S'),
                    _buildPackageFilterChip('SoftWave', _packageFilter == 'SoftWave'),
                    _buildPackageFilterChip('Endo-100S', _packageFilter == 'Endo-100S'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check, color: Colors.white, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryFilterChip(String label, bool isSelected) {
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

  Widget _buildPackageFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _packageFilter = isSelected ? 'All' : label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.successColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.successColor : AppTheme.borderColor,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.successColor.withOpacity(0.3),
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

  Widget _buildProvidersListHeader(ProviderDataProvider providerProvider) {
    final filteredProviders = _getFilteredProviders(providerProvider);
    
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
      child: Row(
        children: [
          Icon(Icons.people, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            'Providers',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
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
              '${filteredProviders.length} ${filteredProviders.length == 1 ? 'provider' : 'providers'}',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvidersList(ProviderDataProvider providerProvider) {
    final filteredProviders = _getFilteredProviders(providerProvider);

    if (providerProvider.isLoading) {
      return Container(
        height: 200,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (filteredProviders.isEmpty) {
      return Container(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: 64,
                color: AppTheme.secondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No providers found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.secondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search or filters',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: filteredProviders.map((provider) => 
        _buildProviderCard(provider, providerProvider)
      ).toList(),
    );
  }

  Widget _buildProviderCard(Provider provider, ProviderDataProvider providerProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: InkWell(
        onTap: () => _navigateToProviderProfile(provider),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar and Status
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: provider.isApproved 
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.warningColor.withOpacity(0.1),
                    child: Icon(
                      Icons.medical_services,
                      color: provider.isApproved 
                          ? AppTheme.successColor
                          : AppTheme.warningColor,
                      size: 20,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: provider.isApproved ? AppTheme.successColor : AppTheme.warningColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              
              // Country Flag
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: Text(
                  _getCountryFlag(provider.country),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              
              // Provider Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            provider.fullName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: provider.isApproved 
                                ? AppTheme.successColor.withOpacity(0.1)
                                : AppTheme.warningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            provider.isApproved ? 'Approved' : 'Pending',
                            style: TextStyle(
                              color: provider.isApproved 
                                  ? AppTheme.successColor
                                  : AppTheme.warningColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      provider.fullCompanyName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.email_outlined, size: 12, color: AppTheme.secondaryColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            provider.email,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.secondaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.public, size: 12, color: AppTheme.secondaryColor),
                        const SizedBox(width: 4),
                        Text(
                          provider.country,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Quick Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    provider.package,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(provider.registrationDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
              
              // Actions Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) => _handleProviderAction(value, provider, providerProvider),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('View Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  if (!provider.isApproved)
                    const PopupMenuItem(
                      value: 'approve',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 16),
                          SizedBox(width: 8),
                          Text('Approve'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red, size: 16),
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

  List<Provider> _getFilteredProviders(ProviderDataProvider providerProvider) {
    List<Provider> providers = providerProvider.providers;

    // Apply status filter
    if (_showOnlyApproved) {
      providers = providers.where((p) => p.isApproved).toList();
    } else if (_showOnlyPending) {
      providers = providers.where((p) => !p.isApproved).toList();
    }

    // Apply package filter
    if (_packageFilter != 'All') {
      providers = providers.where((p) => p.package.contains(_packageFilter)).toList();
    }

    // Apply country filter
    if (_selectedCountry != null) {
      providers = providers.where((p) => p.country == _selectedCountry).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      providers = providerProvider.searchProviders(_searchQuery);
    }

    return providers;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleProviderAction(String action, Provider provider, ProviderDataProvider providerProvider) {
    switch (action) {
      case 'view':
        _navigateToProviderProfile(provider);
        break;
      case 'edit':
        _showEditProviderDialog(provider, providerProvider);
        break;
      case 'approve':
        _approveProvider(provider, providerProvider);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(provider, providerProvider);
        break;
    }
  }

  void _navigateToProviderProfile(Provider provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProviderProfileScreen(provider: provider),
      ),
    );
  }

  void _showProviderDetailsDialog(Provider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Provider Details - ${provider.fullName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Full Name', provider.fullName),
              _buildDetailRow('Company', provider.fullCompanyName),
              _buildDetailRow('Email', provider.email),
              _buildDetailRow('Phone', provider.directPhoneNumber),
              _buildDetailRow('Business Address', provider.businessAddress),
              _buildDetailRow('Shipping Address', provider.shippingAddress),
              _buildDetailRow('Package', provider.package),
              _buildDetailRow('Purchase Plan', provider.purchasePlan),
              _buildDetailRow('Sales Person', provider.salesPerson),
              _buildDetailRow('Status', provider.isApproved ? 'Approved' : 'Pending'),
              _buildDetailRow('Registration Date', _formatDate(provider.registrationDate)),
              if (provider.approvalDate != null)
                _buildDetailRow('Approval Date', _formatDate(provider.approvalDate!)),
              if (provider.additionalNotes != null && provider.additionalNotes!.isNotEmpty)
                _buildDetailRow('Notes', provider.additionalNotes!),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showAddProviderDialog(BuildContext context) {
    // TODO: Implement add provider dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Provider functionality coming soon!'),
      ),
    );
  }

  void _showEditProviderDialog(Provider provider, ProviderDataProvider providerProvider) {
    // TODO: Implement edit provider dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit Provider functionality coming soon!'),
      ),
    );
  }

  void _approveProvider(Provider provider, ProviderDataProvider providerProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Provider'),
        content: Text('Are you sure you want to approve ${provider.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              providerProvider.approveProvider(provider.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${provider.fullName} has been approved!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(Provider provider, ProviderDataProvider providerProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Provider'),
        content: Text('Are you sure you want to delete ${provider.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              providerProvider.deleteProvider(provider.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${provider.fullName} has been deleted!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _exportProviders(ProviderDataProvider providerProvider) {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon!'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }
}
