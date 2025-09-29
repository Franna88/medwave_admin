import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart' hide Provider;
import 'package:medwave_admin/models/provider_model.dart';
import 'package:medwave_admin/providers/provider_data_provider.dart';
import 'package:medwave_admin/theme/app_theme.dart';

class ProviderApprovalsScreen extends StatefulWidget {
  const ProviderApprovalsScreen({super.key});

  @override
  State<ProviderApprovalsScreen> createState() => _ProviderApprovalsScreenState();
}

class _ProviderApprovalsScreenState extends State<ProviderApprovalsScreen> {
  String _filterStatus = 'all'; // all, pending, approved, rejected
  String? _selectedCountry; // Add country filter state

  @override
  void initState() {
    super.initState();
    // Load provider data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderDataProvider>().loadProviders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Provider Approvals', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: Consumer<ProviderDataProvider>(
              builder: (context, providerProvider, child) {
                if (kDebugMode) {
                  print('🏥 ProviderApprovalsScreen: Consumer builder called');
                  print('🏥 ProviderApprovalsScreen: providerProvider.error = ${providerProvider.error}');
                  print('🏥 ProviderApprovalsScreen: providerProvider.isLoading = ${providerProvider.isLoading}');
                  print('🏥 ProviderApprovalsScreen: pendingApprovals count = ${providerProvider.pendingApprovals.length}');
                }
                // Show error if there's one
                if (providerProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.withOpacity(0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error Loading Applications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          providerProvider.error!,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            providerProvider.clearError();
                            providerProvider.refresh();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (providerProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (providerProvider.providers.isEmpty) {
                  return const Center(
                    child: Text(
                      'No provider applications found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final filteredProviders = _getFilteredProviders(providerProvider.providers);

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredProviders.length,
                  itemBuilder: (context, index) {
                    final provider = filteredProviders[index];
                    return _buildProviderCard(provider, providerProvider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Filter
          Row(
            children: [
              const Text(
                'Filter by status:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterStatus,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Applications')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'approved', child: Text('Approved')),
                    DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Country Filter
          Row(
            children: [
              const Text(
                'Filter by country:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 16),
              _buildCountryFilterChip('USA', '🇺🇸'),
              const SizedBox(width: 8),
              _buildCountryFilterChip('RSA', '🇿🇦'),
              const SizedBox(width: 8),
              if (_selectedCountry != null)
                _buildClearCountryFilterChip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountryFilterChip(String country, String flag) {
    final isSelected = _selectedCountry == country;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag),
          const SizedBox(width: 3),
          Text(country),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCountry = selected ? country : null;
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildClearCountryFilterChip() {
    return FilterChip(
      label: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.clear, size: 12),
          SizedBox(width: 3),
          Text('Clear'),
        ],
      ),
      selected: false,
      onSelected: (selected) {
        setState(() {
          _selectedCountry = null;
        });
      },
      backgroundColor: Colors.grey[100],
      side: BorderSide(color: Colors.grey[300]!),
      labelStyle: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  List<Provider> _getFilteredProviders(List<Provider> providers) {
    List<Provider> filteredProviders = providers;
    
    // Apply status filter
    switch (_filterStatus) {
      case 'pending':
        filteredProviders = filteredProviders.where((p) => !p.isApproved).toList();
        break;
      case 'approved':
        filteredProviders = filteredProviders.where((p) => p.isApproved).toList();
        break;
      case 'rejected':
        filteredProviders = filteredProviders.where((p) => p.isApproved == false && p.approvalDate != null).toList();
        break;
      default:
        // 'all' - no status filtering
        break;
    }
    
    // Apply country filter
    if (_selectedCountry != null) {
      filteredProviders = filteredProviders.where((p) => p.country == _selectedCountry).toList();
    }
    
    return filteredProviders;
  }

  Widget _buildProviderCard(Provider provider, ProviderDataProvider providerProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ExpansionTile(
        title: Row(
          children: [
            // Country Flag
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: Text(
                _getCountryFlag(provider.country),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    provider.fullCompanyName,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusChip(provider),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Text(
                'Submitted: ${_formatDate(provider.registrationDate)}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 16),
              Text(
                'Country: ${provider.country}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Email', provider.email),
                _buildInfoRow('Phone', provider.directPhoneNumber),
                _buildInfoRow('Business Address', provider.businessAddress),
                _buildInfoRow('Sales Person', provider.salesPerson),
                _buildInfoRow('Purchase Plan', provider.purchasePlan),
                _buildInfoRow('Shipping Address', provider.shippingAddress),
                _buildInfoRow('Package', provider.package),
                if (provider.additionalNotes != null && provider.additionalNotes!.isNotEmpty)
                  _buildInfoRow('Additional Notes', provider.additionalNotes!),
                if (provider.approvalDate != null)
                  _buildInfoRow('Processed Date', _formatDate(provider.approvalDate!)),
                const SizedBox(height: 16),
                if (!provider.isApproved && provider.approvalDate == null)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _approveProvider(provider, providerProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Approve'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _rejectProvider(provider, providerProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
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

  Widget _buildStatusChip(Provider provider) {
    Color color;
    String text;

    if (provider.isApproved) {
      color = Colors.green;
      text = 'Approved';
    } else if (provider.approvalDate != null) {
      color = Colors.red;
      text = 'Rejected';
    } else {
      color = Colors.orange;
      text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Use the new Firebase-powered approval method
              final success = await providerProvider.approveProvider(
                provider.id,
                reviewNotes: 'Approved via admin panel',
              );
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${provider.fullName} has been approved successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to approve ${provider.fullName}. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _rejectProvider(Provider provider, ProviderDataProvider providerProvider) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Provider'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to reject ${provider.fullName}?'),
            const SizedBox(height: 16),
            const Text(
              'Please provide a reason for rejection:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter rejection reason...',
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a rejection reason'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              
              Navigator.of(context).pop();
              
              // Use the new Firebase-powered rejection method
              final success = await providerProvider.rejectProvider(
                provider.id,
                reason,
                reviewNotes: 'Rejected via admin panel',
              );
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${provider.fullName} has been rejected'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to reject ${provider.fullName}. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
