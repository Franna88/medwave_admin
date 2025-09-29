import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class AdvertPerformanceScreen extends StatefulWidget {
  const AdvertPerformanceScreen({super.key});

  @override
  State<AdvertPerformanceScreen> createState() => _AdvertPerformanceScreenState();
}

class _AdvertPerformanceScreenState extends State<AdvertPerformanceScreen> {
  String? _selectedAdvert;
  String _selectedMetric = 'Leads';
  DateTimeRange? _dateRange;
  String? _selectedCategory;
  String? _selectedRegion;
  String? _selectedChannel;

  final List<String> _adverts = [
    'Summer Dental Campaign',
    'Orthodontic Special',
    'Emergency Care Ads',
    'Preventive Care Promotion',
    'Teeth Whitening Offer',
    'Family Dental Package',
  ];

  final List<String> _metrics = ['Leads', 'Booked', 'No Show', 'Sales'];
  final List<String> _categories = ['Dental', 'Orthodontic', 'Cosmetic', 'Preventive'];
  final List<String> _regions = ['SA', 'USA', 'EU'];
  final List<String> _channels = ['Google Ads', 'Facebook', 'Instagram', 'TikTok', 'Email'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Filters
          _buildHeader(),

          const SizedBox(height: 24),

          // Advert Selection and Main Content
          if (_selectedAdvert != null) ...[
            // Performance Blocks
            _buildPerformanceBlocks(),

            const SizedBox(height: 32),

            // Comparative Graphs
            _buildComparativeGraphs(),
          ] else ...[
            // Advert Selection Prompt
            _buildAdvertSelectionPrompt(),
          ],
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insights,
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
                      'Advert Performance Analysis',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track and analyze the performance of your marketing campaigns',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters & Search Section
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
                      'Filters & Options',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Quick Filter Presets
                _buildQuickFilters(),

                const SizedBox(height: 20),

                // Main Filters
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    // Advert Selection
                    _buildSearchableAdvertSelector(),

                    // Date Range Filter
                    _buildDateRangeFilter(),

                    // Category Filter
                    _buildDropdownFilter(
                      label: 'Category',
                      value: _selectedCategory,
                      items: _categories,
                      onChanged: (value) => setState(() => _selectedCategory = value),
                      icon: Icons.category,
                    ),

                    // Region Filter
                    _buildDropdownFilter(
                      label: 'Region',
                      value: _selectedRegion,
                      items: _regions,
                      onChanged: (value) => setState(() => _selectedRegion = value),
                      icon: Icons.location_on,
                    ),

                    // Channel Filter
                    _buildDropdownFilter(
                      label: 'Channel',
                      value: _selectedChannel,
                      items: _channels,
                      onChanged: (value) => setState(() => _selectedChannel = value),
                      icon: Icons.web,
                    ),

                    // Export Button
                    _buildExportButton(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Text(
          'Quick Filters:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.secondaryColor,
          ),

        ),
        _buildQuickFilterChip('Last 7 Days', Icons.calendar_today, () => _applyQuickFilter('7days')),
        _buildQuickFilterChip('Last 30 Days', Icons.calendar_month, () => _applyQuickFilter('30days')),
        _buildQuickFilterChip('Last Quarter', Icons.calendar_view_month, () => _applyQuickFilter('quarter')),
        _buildQuickFilterChip('Clear All', Icons.clear_all, () => _clearAllFilters()),
      ],
    );
  }

  Widget _buildQuickFilterChip(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: AppTheme.borderColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowColor,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    return Container(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Data',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _showExportMenu(context),
            icon: Icon(Icons.download, size: 16),
            label: Text('Export Options'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
              side: BorderSide(color: AppTheme.borderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Export Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.table_chart, color: AppTheme.primaryColor),
              title: Text('Export as CSV'),
              onTap: () {
                Navigator.of(context).pop();
                _exportData('csv');
              },
            ),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: AppTheme.primaryColor),
              title: Text('Export as PDF'),
              onTap: () {
                Navigator.of(context).pop();
                _exportData('pdf');
              },
            ),
            ListTile(
              leading: Icon(Icons.grid_on, color: AppTheme.primaryColor),
              title: Text('Export as Excel'),
              onTap: () {
                Navigator.of(context).pop();
                _exportData('excel');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchableAdvertSelector() {
    return Container(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Advert',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: _showAdvertSelectionModal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderColor),
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.backgroundColor,
              ),
              child: Row(
                children: [
                  Icon(Icons.campaign, size: 16, color: AppTheme.secondaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedAdvert ?? 'Search and select advert...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _selectedAdvert != null ? AppTheme.textColor : AppTheme.secondaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: AppTheme.secondaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.primaryColor),
              ),
              filled: true,
              fillColor: AppTheme.backgroundColor,
            ),
            icon: Icon(icon, size: 16, color: AppTheme.secondaryColor),
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(
                  'All $label',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ),
              ...items.map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textColor,
                  ),
                ),
              )),
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return Container(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date Range',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: _selectDateRange,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderColor),
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.backgroundColor,
              ),
              child: Row(
                children: [
                  Icon(Icons.date_range, size: 16, color: AppTheme.secondaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _dateRange != null
                          ? '${_dateRange!.start.toString().split(' ')[0]} - ${_dateRange!.end.toString().split(' ')[0]}'
                          : 'Select Date Range',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _dateRange != null ? AppTheme.textColor : AppTheme.secondaryColor,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: AppTheme.secondaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvertSelectionPrompt() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 64,
              color: AppTheme.secondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Select an Advert to View Performance',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.secondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose an advert from the dropdown above to analyze its performance metrics',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceBlocks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Overview for $_selectedAdvert',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 16),

        // Four Performance Blocks
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.8,
          children: [
            _buildPerformanceBlock(
              title: 'Leads',
              icon: Icons.people_outline,
              color: AppTheme.primaryColor,
              metrics: _getLeadsMetrics(),
            ),
            _buildPerformanceBlock(
              title: 'Booked',
              icon: Icons.calendar_today,
              color: AppTheme.successColor,
              metrics: _getBookedMetrics(),
            ),
            _buildPerformanceBlock(
              title: 'No Show',
              icon: Icons.cancel_outlined,
              color: AppTheme.errorColor,
              metrics: _getNoShowMetrics(),
            ),
            _buildPerformanceBlock(
              title: 'Sales',
              icon: Icons.attach_money,
              color: AppTheme.warningColor,
              metrics: _getSalesMetrics(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceBlock({
    required String title,
    required IconData icon,
    required Color color,
    required Map<String, dynamic> metrics,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Main Metric
          Text(
            metrics['mainValue'].toString(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 8),

          // Secondary Metrics
          ...metrics['secondaryMetrics'].entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  Text(
                    entry.value.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 12),

          // Trend Indicator
          Row(
            children: [
              Icon(
                metrics['trend'] >= 0 ? Icons.trending_up : Icons.trending_down,
                color: metrics['trend'] >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${metrics['trend'] >= 0 ? '+' : ''}${metrics['trend']}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: metrics['trend'] >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ' vs last period',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparativeGraphs() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comparative Analysis',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),

              // Metric Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderColor),
                  borderRadius: BorderRadius.circular(8),
                  color: AppTheme.backgroundColor,
                ),
                child: DropdownButton<String>(
                  value: _selectedMetric,
                  items: _metrics.map((metric) => DropdownMenuItem(
                    value: metric,
                    child: Text(metric),
                  )).toList(),
                  onChanged: (value) => setState(() => _selectedMetric = value!),
                  underline: const SizedBox(),
                  icon: Icon(Icons.arrow_drop_down, color: AppTheme.secondaryColor),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Interactive Bar Chart
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxYValue(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppTheme.cardColor,
                    tooltipBorder: BorderSide(color: AppTheme.borderColor),
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${_adverts[groupIndex]}\n',
                        TextStyle(
                          color: AppTheme.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '${rod.toY.round()} $_selectedMetric',
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < _adverts.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _adverts[value.toInt()].split(' ').first,
                              style: TextStyle(
                                color: AppTheme.secondaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60, // Increased from 40 to accommodate larger numbers
                      interval: _getYAxisInterval(), // Add proper interval calculation
                      getTitlesWidget: (value, meta) {
                        // Format large numbers better
                        String formattedValue;
                        if (value >= 1000) {
                          formattedValue = '${(value / 1000).toStringAsFixed(1)}k';
                        } else {
                          formattedValue = value.toInt().toString();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0), // Add right padding
                          child: Text(
                            formattedValue,
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontSize: 11, // Slightly increased font size
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right, // Right-align the text
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getYAxisInterval(),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.borderColor.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: AppTheme.borderColor.withOpacity(0.5)),
                    bottom: BorderSide(color: AppTheme.borderColor.withOpacity(0.5)),
                  ),
                ),
                barGroups: _getBarGroups(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Graph Controls
          Row(
            children: [
              Expanded(
                child: _buildGraphControlButton('Daily', Icons.calendar_view_day),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildGraphControlButton('Weekly', Icons.calendar_view_week),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildGraphControlButton('Monthly', Icons.calendar_view_month),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGraphControlButton(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: Implement graph view switching
      },
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: AppTheme.borderColor),
        ),
      ),
    );
  }

  // Mock data methods - replace with actual data fetching
  Map<String, dynamic> _getLeadsMetrics() {
    return {
      'mainValue': '1,247',
      'secondaryMetrics': {
        'Conversion Rate': '3.2%',
        'Sources': 'Google (45%), Facebook (30%)',
        'Avg. Demographics': '25-45 years',
        'Recent Leads': '156 this week',
      },
      'trend': 12.5,
    };
  }

  Map<String, dynamic> _getBookedMetrics() {
    return {
      'mainValue': '892',
      'secondaryMetrics': {
        'Success Rate': '71.5%',
        'Avg. per Day': '23',
        'Peak Hours': '9-11 AM',
        'Cancellation Rate': '8.3%',
      },
      'trend': 8.7,
    };
  }

  Map<String, dynamic> _getNoShowMetrics() {
    return {
      'mainValue': '124',
      'secondaryMetrics': {
        'Percentage': '9.9%',
        'Reasons': 'Forgot (40%), Traffic (25%)',
        'Cost Impact': '\$2,480',
        'Recovery Rate': '15%',
      },
      'trend': -5.2,
    };
  }

  Map<String, dynamic> _getSalesMetrics() {
    return {
      'mainValue': '\$89,450',
      'secondaryMetrics': {
        'Avg. Value': '\$287',
        'ROI': '324%',
        'Conversion': 'Lead → Sale: 18.5%',
        'Profit Margin': '42%',
      },
      'trend': 15.3,
    };
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.cardColor,
              onSurface: AppTheme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  // Chart data methods
  double _getMaxYValue() {
    final data = _getChartData();
    return data.reduce((a, b) => a > b ? a : b) * 1.2; // Add 20% padding
  }

  double _getYAxisInterval() {
    final maxValue = _getMaxYValue();
    // Calculate appropriate interval based on max value for better readability
    if (maxValue < 100) {
      return 20;
    } else if (maxValue < 500) {
      return 50;
    } else if (maxValue < 1000) {
      return 100;
    } else if (maxValue < 5000) {
      return 500;
    } else if (maxValue < 10000) {
      return 1000;
    } else if (maxValue < 50000) {
      return 5000;
    } else if (maxValue < 100000) {
      return 10000;
    } else {
      return 50000;
    }
  }

  List<BarChartGroupData> _getBarGroups() {
    final data = _getChartData();
    final colors = [
      AppTheme.primaryColor,
      AppTheme.successColor,
      AppTheme.warningColor,
      AppTheme.errorColor,
      Colors.purple,
      Colors.teal,
    ];

    return List.generate(_adverts.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index],
            color: colors[index % colors.length],
            width: 24,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxYValue(),
              color: AppTheme.borderColor.withOpacity(0.1),
            ),
          ),
        ],
      );
    });
  }

  List<double> _getChartData() {
    // Mock data for different metrics - replace with actual data
    final Map<String, List<double>> mockData = {
      'Leads': [1247, 892, 1156, 734, 1456, 987],
      'Booked': [892, 654, 823, 445, 1023, 678],
      'No Show': [124, 89, 145, 67, 178, 112],
      'Sales': [89450, 67200, 78900, 45200, 112300, 68300],
    };

    return mockData[_selectedMetric] ?? [0, 0, 0, 0, 0, 0];
  }

  // Filter helper methods
  void _applyQuickFilter(String filterType) {
    setState(() {
      switch (filterType) {
        case '7days':
          _dateRange = DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
            end: DateTime.now(),
          );
          break;
        case '30days':
          _dateRange = DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          );
          break;
        case 'quarter':
          final now = DateTime.now();
          final quarterStart = DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1);
          _dateRange = DateTimeRange(start: quarterStart, end: now);
          break;
      }
    });
    _refreshData();
  }

  void _clearAllFilters() {
    setState(() {
      _selectedAdvert = null;
      _dateRange = null;
      _selectedCategory = null;
      _selectedRegion = null;
      _selectedChannel = null;
    });
    _refreshData();
  }

  void _refreshData() {
    // TODO: Implement data refresh based on current filters
    // This would typically call an API or update the data provider
    // For now, just trigger a rebuild to update the UI
    setState(() {});
  }

  void _exportData(String format) {
    // TODO: Implement actual export functionality
    // This would typically generate and download the file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting data as $format...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAdvertSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AdvertSelectionModal(
        adverts: _adverts,
        selectedAdvert: _selectedAdvert,
        onAdvertSelected: (advert) {
          setState(() => _selectedAdvert = advert);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class AdvertSelectionModal extends StatefulWidget {
  final List<String> adverts;
  final String? selectedAdvert;
  final Function(String?) onAdvertSelected;

  const AdvertSelectionModal({
    super.key,
    required this.adverts,
    required this.selectedAdvert,
    required this.onAdvertSelected,
  });

  @override
  State<AdvertSelectionModal> createState() => _AdvertSelectionModalState();
}

class _AdvertSelectionModalState extends State<AdvertSelectionModal> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<String> get _filteredAdverts {
    if (_searchQuery.isEmpty) {
      return widget.adverts;
    }
    return widget.adverts
        .where((advert) => advert.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Select Advert',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: AppTheme.secondaryColor),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Search Field
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search adverts...',
              prefixIcon: Icon(Icons.search, color: AppTheme.secondaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.primaryColor),
              ),
              filled: true,
              fillColor: AppTheme.backgroundColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),

          const SizedBox(height: 16),

          // Results count
          Text(
            '${_filteredAdverts.length} advert${_filteredAdverts.length != 1 ? 's' : ''} found',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.secondaryColor,
            ),
          ),

          const SizedBox(height: 12),

          // Advert List
          Expanded(
            child: ListView.builder(
              itemCount: _filteredAdverts.length,
              itemBuilder: (context, index) {
                final advert = _filteredAdverts[index];
                final isSelected = advert == widget.selectedAdvert;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.campaign,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    advert,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: AppTheme.primaryColor)
                      : null,
                  onTap: () => widget.onAdvertSelected(advert),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tileColor: isSelected ? AppTheme.primaryColor.withOpacity(0.05) : null,
                );
              },
            ),
          ),

          // Clear Selection Button
          if (widget.selectedAdvert != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => widget.onAdvertSelected(null),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Selection'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppTheme.borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

