import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_package;
import 'package:intl/intl.dart';
import '../providers/patient_data_provider.dart';
import '../providers/provider_data_provider.dart';
import '../models/patient_model.dart';
import '../models/generated_report_model.dart';
import '../services/report_generation_service.dart';
import '../theme/app_theme.dart';
import 'report_display_screen.dart';

class ComprehensiveReportingScreen extends StatefulWidget {
  const ComprehensiveReportingScreen({super.key});

  @override
  State<ComprehensiveReportingScreen> createState() => _ComprehensiveReportingScreenState();
}

class _ComprehensiveReportingScreenState extends State<ComprehensiveReportingScreen> {
  // Report Configuration
  String _reportTitle = 'Patient Progress Report';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  
  // Patient Filtering
  String _patientFilterType = 'all'; // all, specific, provider, country
  List<String> _selectedPatientIds = [];
  String? _selectedProviderId;
  String? _selectedCountry;
  
  // Session Filtering
  String _sessionFilterType = 'dateRange'; // dateRange, sessionCount, specificSessions
  int _minSessionCount = 1;
  int _maxSessionCount = 100;
  
  // Clinical Metrics
  bool _includeVasScores = true;
  bool _includeWeightChanges = true;
  bool _includeWoundHealing = true;
  bool _includeTreatmentProgress = true;
  
  // Wound Type Filtering
  String _woundTypeFilter = 'all'; // all, specific
  List<String> _selectedWoundTypes = [];
  
  // Image Selection
  String _imageSelection = 'firstAndLast'; // none, first, last, firstAndLast, specific
  
  // Report Generation
  bool _isGenerating = false;
  
  @override
  Widget build(BuildContext context) {
    return provider_package.Consumer2<PatientDataProvider, ProviderDataProvider>(
      builder: (context, patientProvider, providerProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Comprehensive Reporting'),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () => _showHelpDialog(context),
              ),
            ],
          ),
          body: _buildReportConfiguration(context, patientProvider, providerProvider),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _isGenerating ? null : () => _generateReport(context, patientProvider, providerProvider),
            backgroundColor: AppTheme.primaryColor,
            icon: _isGenerating 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.file_download),
            label: Text(_isGenerating ? 'Generating...' : 'Generate Report'),
          ),
        );
      },
    );
  }

  Widget _buildReportConfiguration(BuildContext context, PatientDataProvider patientProvider, ProviderDataProvider providerProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Header
          _buildReportHeader(),
          const SizedBox(height: 32),
          
          // Filter Sections
          _buildPatientFilters(patientProvider, providerProvider),
          const SizedBox(height: 24),
          
          _buildSessionFilters(),
          const SizedBox(height: 24),
          
          _buildClinicalMetrics(),
          const SizedBox(height: 24),
          
          _buildWoundTypeFilters(),
          const SizedBox(height: 24),
          
          _buildImageSelection(),
          const SizedBox(height: 24),
          
          // Report Preview
          _buildReportPreview(patientProvider, providerProvider),
          
          // Bottom padding for FAB
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildReportHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Report Configuration',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Report Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              onChanged: (value) => setState(() => _reportTitle = value),
              controller: TextEditingController(text: _reportTitle),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(
                    'Start Date',
                    _startDate,
                    (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateSelector(
                    'End Date',
                    _endDate,
                    (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime selectedDate, Function(DateTime) onDateChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) onDateChanged(date);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientFilters(PatientDataProvider patientProvider, ProviderDataProvider providerProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: AppTheme.successColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Patient Selection',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Patient Filter Type
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All Patients'),
                  selected: _patientFilterType == 'all',
                  onSelected: (selected) {
                    if (selected) setState(() => _patientFilterType = 'all');
                  },
                ),
                ChoiceChip(
                  label: const Text('Specific Patients'),
                  selected: _patientFilterType == 'specific',
                  onSelected: (selected) {
                    if (selected) setState(() => _patientFilterType = 'specific');
                  },
                ),
                ChoiceChip(
                  label: const Text('By Provider'),
                  selected: _patientFilterType == 'provider',
                  onSelected: (selected) {
                    if (selected) setState(() => _patientFilterType = 'provider');
                  },
                ),
                ChoiceChip(
                  label: const Text('By Country'),
                  selected: _patientFilterType == 'country',
                  onSelected: (selected) {
                    if (selected) setState(() => _patientFilterType = 'country');
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Conditional filters based on selection
            if (_patientFilterType == 'specific') _buildSpecificPatientSelector(patientProvider),
            if (_patientFilterType == 'provider') _buildProviderSelector(providerProvider),
            if (_patientFilterType == 'country') _buildCountrySelector(providerProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificPatientSelector(PatientDataProvider patientProvider) {
    final patients = patientProvider.filteredPatients;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Patients (${_selectedPatientIds.length} selected)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return CheckboxListTile(
                title: Text(patient.name),
                subtitle: Text('${patient.email} • ${patient.country}'),
                value: _selectedPatientIds.contains(patient.id),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedPatientIds.add(patient.id);
                    } else {
                      _selectedPatientIds.remove(patient.id);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProviderSelector(ProviderDataProvider providerProvider) {
    final providers = providerProvider.filteredApprovedProviders;
    
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Select Provider',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.medical_services),
      ),
      value: _selectedProviderId,
      items: providers.map((provider) {
        return DropdownMenuItem(
          value: provider.id,
          child: Text('${provider.firstName} ${provider.lastName} (${provider.fullCompanyName})'),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedProviderId = value),
    );
  }

  Widget _buildCountrySelector(ProviderDataProvider providerProvider) {
    final countries = providerProvider.filteredApprovedProviders
        .map((p) => p.country)
        .toSet()
        .toList();
    
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Select Country',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.public),
      ),
      value: _selectedCountry,
      items: countries.map((country) {
        return DropdownMenuItem(
          value: country,
          child: Text(country),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedCountry = value),
    );
  }

  Widget _buildSessionFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_note, color: AppTheme.pinkColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Session Filtering',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.pinkColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Date Range'),
                  selected: _sessionFilterType == 'dateRange',
                  onSelected: (selected) {
                    if (selected) setState(() => _sessionFilterType = 'dateRange');
                  },
                ),
                ChoiceChip(
                  label: const Text('Session Count'),
                  selected: _sessionFilterType == 'sessionCount',
                  onSelected: (selected) {
                    if (selected) setState(() => _sessionFilterType = 'sessionCount');
                  },
                ),
                ChoiceChip(
                  label: const Text('Specific Sessions'),
                  selected: _sessionFilterType == 'specificSessions',
                  onSelected: (selected) {
                    if (selected) setState(() => _sessionFilterType = 'specificSessions');
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (_sessionFilterType == 'sessionCount') _buildSessionCountFilter(),
            if (_sessionFilterType == 'specificSessions') _buildSpecificSessionsFilter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCountFilter() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Min Sessions',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            initialValue: _minSessionCount.toString(),
            onChanged: (value) {
              final count = int.tryParse(value) ?? 1;
              setState(() => _minSessionCount = count);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Max Sessions',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            initialValue: _maxSessionCount.toString(),
            onChanged: (value) {
              final count = int.tryParse(value) ?? 100;
              setState(() => _maxSessionCount = count);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecificSessionsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Numbers (comma-separated, e.g., 1,3,5-8)',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            hintText: '1,3,5-8,10',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            // Parse session ranges like "1,3,5-8,10"
            // Note: Session number parsing will be implemented when needed
          },
        ),
      ],
    );
  }

  Widget _buildClinicalMetrics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppTheme.greenColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Clinical Metrics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.greenColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            CheckboxListTile(
              title: const Text('VAS Pain Scores'),
              subtitle: const Text('Visual Analog Scale for pain assessment'),
              value: _includeVasScores,
              onChanged: (value) => setState(() => _includeVasScores = value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Weight Changes'),
              subtitle: const Text('Track weight progression over time'),
              value: _includeWeightChanges,
              onChanged: (value) => setState(() => _includeWeightChanges = value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Wound Healing Progress'),
              subtitle: const Text('Wound dimensions and healing metrics'),
              value: _includeWoundHealing,
              onChanged: (value) => setState(() => _includeWoundHealing = value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Treatment Progress'),
              subtitle: const Text('Overall treatment effectiveness metrics'),
              value: _includeTreatmentProgress,
              onChanged: (value) => setState(() => _includeTreatmentProgress = value ?? false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWoundTypeFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.healing, color: AppTheme.warningColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Wound Type Filtering',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warningColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            RadioListTile<String>(
              title: const Text('All Wound Types'),
              value: 'all',
              groupValue: _woundTypeFilter,
              onChanged: (value) => setState(() => _woundTypeFilter = value!),
            ),
            RadioListTile<String>(
              title: const Text('Specific Wound Types'),
              value: 'specific',
              groupValue: _woundTypeFilter,
              onChanged: (value) => setState(() => _woundTypeFilter = value!),
            ),
            
            if (_woundTypeFilter == 'specific') _buildWoundTypeSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildWoundTypeSelector() {
    final woundTypes = [
      'Pressure Ulcer', 'Diabetic Ulcer', 'Venous Ulcer', 'Arterial Ulcer',
      'Surgical Wound', 'Traumatic Wound', 'Burn', 'Other'
    ];
    
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: woundTypes.map((type) {
          return FilterChip(
            label: Text(type),
            selected: _selectedWoundTypes.contains(type),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedWoundTypes.add(type);
                } else {
                  _selectedWoundTypes.remove(type);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImageSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.photo_library, color: AppTheme.pinkColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Image Selection',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.pinkColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('No Images'),
                  selected: _imageSelection == 'none',
                  onSelected: (selected) {
                    if (selected) setState(() => _imageSelection = 'none');
                  },
                ),
                ChoiceChip(
                  label: const Text('First Image'),
                  selected: _imageSelection == 'first',
                  onSelected: (selected) {
                    if (selected) setState(() => _imageSelection = 'first');
                  },
                ),
                ChoiceChip(
                  label: const Text('Last Image'),
                  selected: _imageSelection == 'last',
                  onSelected: (selected) {
                    if (selected) setState(() => _imageSelection = 'last');
                  },
                ),
                ChoiceChip(
                  label: const Text('First & Last'),
                  selected: _imageSelection == 'firstAndLast',
                  onSelected: (selected) {
                    if (selected) setState(() => _imageSelection = 'firstAndLast');
                  },
                ),
                ChoiceChip(
                  label: const Text('Specific Images'),
                  selected: _imageSelection == 'specific',
                  onSelected: (selected) {
                    if (selected) setState(() => _imageSelection = 'specific');
                  },
                ),
              ],
            ),
            
            if (_imageSelection == 'specific') _buildSpecificImageSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificImageSelector() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Specific Images',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Image selection will be available after patient selection.\nImages from sessions will be displayed here.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportPreview(PatientDataProvider patientProvider, ProviderDataProvider providerProvider) {
    final filteredPatients = _getFilteredPatients(patientProvider, providerProvider);
    final estimatedData = _getEstimatedReportData(filteredPatients, patientProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.preview, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Report Preview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildPreviewMetric('Report Title', _reportTitle),
            _buildPreviewMetric('Date Range', '${DateFormat('MMM dd, yyyy').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}'),
            _buildPreviewMetric('Patients Included', '${filteredPatients.length} patients'),
            _buildPreviewMetric('Estimated Sessions', '${estimatedData['totalSessions']} sessions'),
            _buildPreviewMetric('Clinical Metrics', _getSelectedMetrics()),
            _buildPreviewMetric('Image Selection', _getImageSelectionDescription()),
            
            const SizedBox(height: 16),
            
            if (filteredPatients.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade600),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'No patients match the current filter criteria. Please adjust your filters.',
                        style: TextStyle(color: Colors.orange),
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

  Widget _buildPreviewMetric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  List<Patient> _getFilteredPatients(PatientDataProvider patientProvider, ProviderDataProvider providerProvider) {
    List<Patient> patients = patientProvider.filteredPatients;
    
    switch (_patientFilterType) {
      case 'specific':
        patients = patients.where((p) => _selectedPatientIds.contains(p.id)).toList();
        break;
      case 'provider':
        if (_selectedProviderId != null) {
          patients = patients.where((p) => p.providerId == _selectedProviderId).toList();
        }
        break;
      case 'country':
        if (_selectedCountry != null) {
          patients = patients.where((p) => p.country == _selectedCountry).toList();
        }
        break;
      // 'all' case - no additional filtering
    }
    
    return patients;
  }

  Map<String, dynamic> _getEstimatedReportData(List<Patient> patients, PatientDataProvider patientProvider) {
    int totalSessions = 0;
    for (final patient in patients) {
      final sessions = patientProvider.getPatientSessions(patient.id);
      totalSessions += sessions.length;
    }
    
    return {
      'totalSessions': totalSessions,
      'patientsWithSessions': patients.where((p) => patientProvider.getPatientSessions(p.id).isNotEmpty).length,
    };
  }

  String _getSelectedMetrics() {
    List<String> metrics = [];
    if (_includeVasScores) metrics.add('VAS Scores');
    if (_includeWeightChanges) metrics.add('Weight Changes');
    if (_includeWoundHealing) metrics.add('Wound Healing');
    if (_includeTreatmentProgress) metrics.add('Treatment Progress');
    return metrics.isEmpty ? 'None selected' : metrics.join(', ');
  }

  String _getImageSelectionDescription() {
    switch (_imageSelection) {
      case 'none': return 'No images';
      case 'first': return 'First image only';
      case 'last': return 'Last image only';
      case 'firstAndLast': return 'First and last images';
      case 'specific': return 'Specific images selected';
      default: return 'Not configured';
    }
  }

  void _generateReport(BuildContext context, PatientDataProvider patientProvider, ProviderDataProvider providerProvider) async {
    setState(() => _isGenerating = true);
    
    try {
      final filteredPatients = _getFilteredPatients(patientProvider, providerProvider);
      
      if (filteredPatients.isEmpty) {
        _showErrorDialog(context, 'No patients match the current filter criteria. Please adjust your filters and try again.');
        return;
      }
      
      // Create report configuration
      final reportConfig = ReportConfiguration(
        patientFilterType: _patientFilterType,
        sessionFilterType: _sessionFilterType,
        includeVasScores: _includeVasScores,
        includeWeightChanges: _includeWeightChanges,
        includeWoundHealing: _includeWoundHealing,
        includeTreatmentProgress: _includeTreatmentProgress,
        imageSelection: _imageSelection,
        selectedWoundTypes: _selectedWoundTypes,
      );
      
      // Generate the report
      final report = await ReportGenerationService.generateReport(
        title: _reportTitle,
        startDate: _startDate,
        endDate: _endDate,
        patients: filteredPatients,
        patientProvider: patientProvider,
        providerProvider: providerProvider,
        configuration: reportConfig,
      );
      
      // Navigate to report display screen
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReportDisplayScreen(report: report),
          ),
        );
      }
      
    } catch (e) {
      _showErrorDialog(context, 'Error generating report: $e');
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comprehensive Reporting Help'),
        content: const SingleChildScrollView(
          child: Text(
            'This reporting system allows you to generate detailed patient progress reports with flexible filtering options:\n\n'
            '• Patient Selection: Choose all patients, specific patients, or filter by provider/country\n'
            '• Session Filtering: Filter by date range, session count, or specific session numbers\n'
            '• Clinical Metrics: Include VAS scores, weight changes, wound healing progress\n'
            '• Wound Types: Filter by specific wound types or include all types\n'
            '• Images: Select which session images to include in the report\n\n'
            'The system is designed to be flexible and extensible for future enhancements.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
