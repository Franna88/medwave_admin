import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_package;
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/firebase/firebase_admin_service.dart';
import '../services/firebase/firebase_config.dart';
import '../models/firebase_user_model.dart';
import '../theme/app_theme.dart';
import 'admin_user_creation_screen.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAdminService _adminService = FirebaseAdminService();
  
  List<FirebaseUser> _adminUsers = [];
  List<AdminActivity> _recentActivity = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _roleFilter = 'all';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAdminUsers();
    _loadRecentActivity();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return provider_package.Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Admin Management'),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(icon: Icon(Icons.people), text: 'Admin Users'),
                Tab(icon: Icon(Icons.analytics), text: 'Activity'),
                Tab(icon: Icon(Icons.settings), text: 'Settings'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshData,
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildAdminUsersTab(authProvider),
              _buildActivityTab(),
              _buildSettingsTab(authProvider),
            ],
          ),
          floatingActionButton: _tabController.index == 0
              ? FloatingActionButton.extended(
                  onPressed: () => _navigateToCreateAdmin(context),
                  backgroundColor: AppTheme.primaryColor,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Admin'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildAdminUsersTab(AuthProvider authProvider) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading admin users...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 64),
            const SizedBox(height: 16),
            Text(
              'Error Loading Admin Users',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshData,
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

    return Column(
      children: [
        // Filters and Search
        _buildFiltersSection(),
        
        // Admin Users List
        Expanded(
          child: _buildAdminUsersList(authProvider),
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search admin users...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          
          const SizedBox(height: 12),
          
          // Filter Chips
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All Roles'),
                      selected: _roleFilter == 'all',
                      onSelected: (selected) {
                        if (selected) setState(() => _roleFilter = 'all');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Super Admin'),
                      selected: _roleFilter == 'super_admin',
                      onSelected: (selected) {
                        if (selected) setState(() => _roleFilter = 'super_admin');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Country Admin'),
                      selected: _roleFilter == 'country_admin',
                      onSelected: (selected) {
                        if (selected) setState(() => _roleFilter = 'country_admin');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminUsersList(AuthProvider authProvider) {
    final filteredUsers = _getFilteredUsers();
    
    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No admin users found' : 'No users match your search',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => _searchQuery = ''),
                child: const Text('Clear search'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return _buildAdminUserCard(user, authProvider);
      },
    );
  }

  Widget _buildAdminUserCard(FirebaseUser user, AuthProvider authProvider) {
    final isCurrentUser = authProvider.adminUser?.id == user.id;
    final isSuperAdmin = user.role == FirebaseConfig.superAdminRole;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  backgroundColor: isSuperAdmin ? AppTheme.primaryColor : AppTheme.successColor,
                  child: Text(
                    '${user.firstName[0]}${user.lastName[0]}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${user.firstName} ${user.lastName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'You',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSuperAdmin ? AppTheme.primaryColor : AppTheme.successColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isSuperAdmin ? 'Super Admin' : 'Country Admin',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // Actions Menu
                PopupMenuButton<String>(
                  onSelected: (action) => _handleUserAction(action, user, authProvider),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 18),
                          SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    if (!isCurrentUser) ...[
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit User'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'disable',
                        child: Row(
                          children: [
                            Icon(Icons.block, size: 18, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Disable User'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete User'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Additional Info
            Row(
              children: [
                _buildInfoChip(Icons.public, user.countryName),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.phone, user.phoneNumber ?? 'No phone'),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.schedule,
                  'Created ${_formatDate(user.createdAt)}',
                ),
              ],
            ),
            
            if (user.lastLogin != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last login: ${_formatDateTime(user.lastLogin!)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Activity Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildActivitySummaryCard(
                'Total Admins',
                _adminUsers.length.toString(),
                Icons.people,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActivitySummaryCard(
                'Super Admins',
                _adminUsers.where((u) => u.role == FirebaseConfig.superAdminRole).length.toString(),
                Icons.admin_panel_settings,
                AppTheme.successColor,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildActivitySummaryCard(
                'Country Admins',
                _adminUsers.where((u) => u.role == FirebaseConfig.countryAdminRole).length.toString(),
                Icons.public,
                AppTheme.pinkColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActivitySummaryCard(
                'Recent Activity',
                _recentActivity.length.toString(),
                Icons.timeline,
                AppTheme.warningColor,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Recent Activity List
        Text(
          'Recent Admin Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        ..._recentActivity.map((activity) => _buildActivityItem(activity)),
      ],
    );
  }

  Widget _buildActivitySummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(AdminActivity activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getActivityColor(activity.type),
          child: Icon(
            _getActivityIcon(activity.type),
            color: Colors.white,
            size: 18,
          ),
        ),
        title: Text(activity.description),
        subtitle: Text(
          '${activity.userEmail} • ${_formatDateTime(activity.timestamp)}',
        ),
        trailing: _buildActivityStatus(activity.type),
      ),
    );
  }

  Widget _buildActivityStatus(String type) {
    Color color;
    String text;
    
    switch (type) {
      case 'user_created':
        color = AppTheme.successColor;
        text = 'Created';
        break;
      case 'user_edited':
        color = AppTheme.warningColor;
        text = 'Modified';
        break;
      case 'user_deleted':
        color = AppTheme.errorColor;
        text = 'Deleted';
        break;
      case 'login':
        color = AppTheme.primaryColor;
        text = 'Login';
        break;
      default:
        color = Colors.grey;
        text = 'Activity';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSettingsTab(AuthProvider authProvider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Role Management Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Role Management',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildSettingItem(
                  'Default Country for New Admins',
                  'United States',
                  Icons.public,
                  onTap: () => _showCountrySelector(),
                ),
                
                _buildSettingItem(
                  'Require Email Verification',
                  'Enabled',
                  Icons.email,
                  onTap: () => _toggleEmailVerification(),
                ),
                
                _buildSettingItem(
                  'Password Requirements',
                  'Strong passwords required',
                  Icons.password,
                  onTap: () => _showPasswordRequirements(),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // System Settings Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.settings, color: AppTheme.successColor),
                    const SizedBox(width: 8),
                    Text(
                      'System Settings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildSettingItem(
                  'Audit Logging',
                  'All admin actions logged',
                  Icons.history,
                  onTap: () => _showAuditSettings(),
                ),
                
                _buildSettingItem(
                  'Session Timeout',
                  '8 hours',
                  Icons.timer,
                  onTap: () => _showSessionSettings(),
                ),
                
                _buildSettingItem(
                  'Backup Configuration',
                  'Daily backups enabled',
                  Icons.backup,
                  onTap: () => _showBackupSettings(),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Danger Zone
        Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Danger Zone',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildDangerItem(
                  'Reset All Admin Passwords',
                  'Force password reset for all admin users',
                  Icons.lock_reset,
                  onTap: () => _showResetPasswordsDialog(),
                ),
                
                _buildDangerItem(
                  'Export Admin Data',
                  'Download admin user data for backup',
                  Icons.download,
                  onTap: () => _exportAdminData(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildDangerItem(String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.red.shade600),
      title: Text(
        title,
        style: TextStyle(color: Colors.red.shade800),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right, color: Colors.red.shade600),
      onTap: onTap,
    );
  }

  // Helper Methods
  List<FirebaseUser> _getFilteredUsers() {
    return _adminUsers.where((user) {
      final matchesSearch = _searchQuery.isEmpty ||
          user.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.lastName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesRole = _roleFilter == 'all' || user.role == _roleFilter;
      
      return matchesSearch && matchesRole;
    }).toList();
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'user_created': return AppTheme.successColor;
      case 'user_edited': return AppTheme.warningColor;
      case 'user_deleted': return AppTheme.errorColor;
      case 'login': return AppTheme.primaryColor;
      default: return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'user_created': return Icons.person_add;
      case 'user_edited': return Icons.edit;
      case 'user_deleted': return Icons.person_remove;
      case 'login': return Icons.login;
      default: return Icons.timeline;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  // Data Loading Methods
  Future<void> _loadAdminUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Implement actual admin user loading from Firebase
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _adminUsers = [
          // Mock admin users - replace with actual Firebase data
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load admin users: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecentActivity() async {
    try {
      // TODO: Implement actual activity loading from Firebase
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _recentActivity = [
          // Mock activity data - replace with actual Firebase data
        ];
      });
    } catch (e) {
      // Handle error silently for activity data
    }
  }

  void _refreshData() {
    _loadAdminUsers();
    _loadRecentActivity();
  }

  // Action Handlers
  void _handleUserAction(String action, FirebaseUser user, AuthProvider authProvider) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'edit':
        _editUser(user);
        break;
      case 'disable':
        _disableUser(user);
        break;
      case 'delete':
        _deleteUser(user);
        break;
    }
  }

  void _navigateToCreateAdmin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AdminUserCreationScreen(),
      ),
    ).then((_) => _refreshData());
  }

  void _showUserDetails(FirebaseUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.firstName} ${user.lastName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            Text('Role: ${user.role}'),
            Text('Country: ${user.countryName}'),
            if (user.phoneNumber?.isNotEmpty == true) Text('Phone: ${user.phoneNumber}'),
            Text('Created: ${_formatDateTime(user.createdAt)}'),
            if (user.lastLogin != null) Text('Last Login: ${_formatDateTime(user.lastLogin!)}'),
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

  void _editUser(FirebaseUser user) {
    // TODO: Implement user editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User editing will be implemented')),
    );
  }

  void _disableUser(FirebaseUser user) {
    // TODO: Implement user disabling
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User disabling will be implemented')),
    );
  }

  void _deleteUser(FirebaseUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Admin User'),
        content: Text('Are you sure you want to delete ${user.firstName} ${user.lastName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement user deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User deletion will be implemented')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Settings Handlers
  void _showCountrySelector() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Country selector will be implemented')),
    );
  }

  void _toggleEmailVerification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email verification toggle will be implemented')),
    );
  }

  void _showPasswordRequirements() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password requirements dialog will be implemented')),
    );
  }

  void _showAuditSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Audit settings will be implemented')),
    );
  }

  void _showSessionSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session settings will be implemented')),
    );
  }

  void _showBackupSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup settings will be implemented')),
    );
  }

  void _showResetPasswordsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Admin Passwords'),
        content: const Text('This will force all admin users to reset their passwords on next login. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset will be implemented')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset All'),
          ),
        ],
      ),
    );
  }

  void _exportAdminData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin data export will be implemented')),
    );
  }
}

// Models for admin activity tracking
class AdminActivity {
  final String id;
  final String type;
  final String description;
  final String userEmail;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  AdminActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.userEmail,
    required this.timestamp,
    this.metadata,
  });
}
