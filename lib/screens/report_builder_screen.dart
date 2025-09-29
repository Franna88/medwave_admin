// COMMENTED OUT - OLD REPORT BUILDER
// This complex report builder has been replaced with a simpler, more focused reporting system
// The new reporting screen is: comprehensive_reporting_screen.dart

import 'package:flutter/material.dart';
import 'comprehensive_reporting_screen.dart';

class ReportBuilderScreen extends StatelessWidget {
  const ReportBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to new comprehensive reporting screen
    return const ComprehensiveReportingScreen();
  }
}
