import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_package;
import '../providers/patient_data_provider.dart';
import '../models/patient_model.dart';
import '../theme/app_theme.dart';

class PatientManagementScreen extends StatefulWidget {
  const PatientManagementScreen({super.key});

  @override
  State<PatientManagementScreen> createState() => _PatientManagementScreenState();
}

class _PatientManagementScreenState extends State<PatientManagementScreen> {
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _providerFilter = 'All';
  bool _showOnlyActive = false;
  bool _showOnlyInactive = false;

  @override
  Widget build(BuildContext context) {
    return provider_package.Consumer<PatientDataProvider>(
      builder: (context, patientProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Header with Statistics
              _buildEnhancedHeader(context, patientProvider),
              const SizedBox(height: 24),
              
              // Statistics Overview Cards
              _buildStatisticsOverview(patientProvider),
              const SizedBox(height: 24),
              
              // Filters and Search
              _buildFiltersAndSearch(),
              const SizedBox(height: 24),
              
              // Patients List Header
              _buildPatientsListHeader(patientProvider),
              const SizedBox(height: 16),
              
              // Patients List
              _buildPatientsList(patientProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedHeader(BuildContext context, PatientDataProvider patientProvider) {
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
                  Icons.people,
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
                      'Patient Management',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage patient records and treatment information',
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
                    label: 'Add Patient',
                    onPressed: () => _showAddPatientDialog(context),
                    isPrimary: true,
                  ),
                  const SizedBox(width: 12),
                  _buildQuickActionButton(
                    icon: Icons.download,
                    label: 'Export',
                    onPressed: () => _exportPatients(patientProvider),
                    isPrimary: false,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildQuickStats(patientProvider),
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

  Widget _buildQuickStats(PatientDataProvider patientProvider) {
    return Row(
      children: [
        _buildStatItem(
          icon: Icons.people,
          value: patientProvider.totalPatients.toString(),
          label: 'Total Patients',
          color: Colors.white,
        ),
        const SizedBox(width: 32),
        _buildStatItem(
          icon: Icons.check_circle,
          value: patientProvider.activePatients.toString(),
          label: 'Active Patients',
          color: AppTheme.successColor,
        ),
        const SizedBox(width: 32),
        _buildStatItem(
          icon: Icons.trending_up,
          value: '${patientProvider.averageProgress.toStringAsFixed(1)}%',
          label: 'Avg Progress',
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

  Widget _buildStatisticsOverview(PatientDataProvider patientProvider) {
    final activePatients = patientProvider.activePatients;
    final inactivePatients = patientProvider.totalPatients - activePatients;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Active Patients',
            value: activePatients.toString(),
            icon: Icons.check_circle,
            color: AppTheme.successColor,
            subtitle: 'Currently receiving treatment',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Inactive Patients',
            value: inactivePatients.toString(),
            icon: Icons.person_off,
            color: AppTheme.warningColor,
            subtitle: 'Completed or discontinued',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Average Progress',
            value: '${patientProvider.averageProgress.toStringAsFixed(1)}%',
            icon: Icons.trending_up,
            color: AppTheme.primaryColor,
            subtitle: 'Overall treatment progress',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Treatment Types',
            value: '3',
            icon: Icons.medical_services,
            color: AppTheme.successColor,
            subtitle: 'Wound, Weight, Both',
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
                      hintText: 'Search patients by name, email, or provider...',
                      prefixIcon: Icon(Icons.search, color: AppTheme.secondaryColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _buildFilterChip('All Patients', _statusFilter == 'All', () {
                setState(() {
                  _statusFilter = 'All';
                  _showOnlyActive = false;
                  _showOnlyInactive = false;
                });
              }),
              const SizedBox(width: 8),
              _buildFilterChip('Active', _showOnlyActive, () {
                setState(() {
                  _statusFilter = 'Active';
                  _showOnlyActive = true;
                  _showOnlyInactive = false;
                });
              }),
              const SizedBox(width: 8),
              _buildFilterChip('Inactive', _showOnlyInactive, () {
                setState(() {
                  _statusFilter = 'Inactive';
                  _showOnlyActive = false;
                  _showOnlyInactive = true;
                });
              }),
            ],
          ),
          const SizedBox(height: 20),
          
          // Provider Filter
          Row(
            children: [
              Icon(Icons.medical_services, color: AppTheme.secondaryColor, size: 16),
              const SizedBox(width: 8),
              Text(
                'Provider Filter:',
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
                    _buildProviderFilterChip('All', _providerFilter == 'All'),
                    _buildProviderFilterChip('Dr. Johnson', _providerFilter == 'Dr. Johnson'),
                    _buildProviderFilterChip('Dr. Chen', _providerFilter == 'Dr. Chen'),
                    _buildProviderFilterChip('Dr. Rodriguez', _providerFilter == 'Dr. Rodriguez'),
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

  Widget _buildProviderFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _providerFilter = isSelected ? 'All' : label;
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

  Widget _buildPatientsListHeader(PatientDataProvider patientProvider) {
    final filteredPatients = _getFilteredPatients(patientProvider);
    
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
            'Patients',
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
              '${filteredPatients.length} ${filteredPatients.length == 1 ? 'patient' : 'patients'}',
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

  Widget _buildPatientsList(PatientDataProvider patientProvider) {
    final filteredPatients = _getFilteredPatients(patientProvider);

    if (patientProvider.isLoading) {
      return Container(
        height: 200,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (filteredPatients.isEmpty) {
      return Container(
        height: 300,
        child: Center(
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
      children: filteredPatients.map((patient) => 
        _buildPatientCard(patient, patientProvider)
      ).toList(),
    );
  }

  Widget _buildPatientCard(Patient patient, PatientDataProvider patientProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: InkWell(
        onTap: () => _navigateToPatientProfile(patient),
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
                    backgroundColor: patient.isActive 
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.warningColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: patient.isActive 
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
                        color: patient.isActive ? AppTheme.successColor : AppTheme.warningColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              
              // Patient Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                                         Row(
                       children: [
                         Expanded(
                           child: Text(
                             patient.name,
                             style: Theme.of(context).textTheme.titleMedium?.copyWith(
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         ),
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                           decoration: BoxDecoration(
                             color: patient.isActive 
                                 ? AppTheme.successColor.withOpacity(0.1)
                                 : AppTheme.warningColor.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: Text(
                             patient.isActive ? 'Active' : 'Inactive',
                             style: TextStyle(
                               color: patient.isActive 
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
                       'Provider ID: ${patient.providerId}',
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
                             patient.email,
                             style: Theme.of(context).textTheme.bodySmall?.copyWith(
                               color: AppTheme.secondaryColor,
                             ),
                             overflow: TextOverflow.ellipsis,
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
                     _getTreatmentTypeString(patient.treatmentType),
                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                       fontWeight: FontWeight.w600,
                     ),
                     textAlign: TextAlign.end,
                   ),
                   const SizedBox(height: 2),
                   Text(
                     _formatDate(patient.treatmentStartDate),
                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                       color: AppTheme.secondaryColor,
                     ),
                   ),
                 ],
               ),
              
              // Actions Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) => _handlePatientAction(value, patient, patientProvider),
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

  List<Patient> _getFilteredPatients(PatientDataProvider patientProvider) {
    List<Patient> patients = patientProvider.patients;

    // Apply status filter
    if (_showOnlyActive) {
      patients = patients.where((p) => p.isActive).toList();
    } else if (_showOnlyInactive) {
      patients = patients.where((p) => !p.isActive).toList();
    }

    // Apply provider filter
    if (_providerFilter != 'All') {
      patients = patients.where((p) => p.providerId.contains(_providerFilter)).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      patients = patientProvider.searchPatients(_searchQuery);
    }

    return patients;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handlePatientAction(String action, Patient patient, PatientDataProvider patientProvider) {
    switch (action) {
      case 'view':
        _navigateToPatientProfile(patient);
        break;
      case 'edit':
        _showEditPatientDialog(patient, patientProvider);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(patient, patientProvider);
        break;
    }
  }

  void _navigateToPatientProfile(Patient patient) {
    // TODO: Navigate to patient profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing profile for ${patient.name}'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _showAddPatientDialog(BuildContext context) {
    // TODO: Implement add patient dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Patient functionality coming soon!'),
      ),
    );
  }

  void _showEditPatientDialog(Patient patient, PatientDataProvider patientProvider) {
    // TODO: Implement edit patient dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit Patient functionality coming soon!'),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Patient patient, PatientDataProvider patientProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient'),
        content: Text('Are you sure you want to delete ${patient.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              patientProvider.deletePatient(patient.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${patient.name} has been deleted!'),
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

  void _exportPatients(PatientDataProvider patientProvider) {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon!'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

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
}
