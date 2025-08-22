import 'package:flutter/material.dart';
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
      child: Row(
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
    );
  }

  List<Provider> _getFilteredProviders(List<Provider> providers) {
    switch (_filterStatus) {
      case 'pending':
        return providers.where((p) => !p.isApproved).toList();
      case 'approved':
        return providers.where((p) => p.isApproved).toList();
      case 'rejected':
        return providers.where((p) => p.isApproved == false && p.approvalDate != null).toList();
      default:
        return providers;
    }
  }

  Widget _buildProviderCard(Provider provider, ProviderDataProvider providerProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ExpansionTile(
        title: Row(
          children: [
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
          child: Text(
            'Submitted: ${_formatDate(provider.registrationDate)}',
            style: const TextStyle(fontSize: 12),
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
            onPressed: () {
              Navigator.of(context).pop();
              providerProvider.approveProvider(provider.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${provider.fullName} has been approved'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _rejectProvider(Provider provider, ProviderDataProvider providerProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Provider'),
        content: Text('Are you sure you want to reject ${provider.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              providerProvider.rejectProvider(provider.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${provider.fullName} has been rejected'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
