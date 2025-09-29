import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medwave_admin/theme/app_theme.dart';
import 'package:medwave_admin/providers/auth_provider.dart';
import 'package:medwave_admin/providers/provider_data_provider.dart';
import 'package:medwave_admin/providers/patient_data_provider.dart';
import 'package:medwave_admin/providers/report_data_provider.dart';
import 'package:medwave_admin/screens/login_screen.dart';
import 'package:medwave_admin/screens/dashboard_screen.dart';
import 'package:medwave_admin/services/firebase/firebase_config.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase before running the app
  await FirebaseConfig.initializeFirebase();
  
  runApp(const MedwaveAdminApp());
}

class MedwaveAdminApp extends StatelessWidget {
  const MedwaveAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProviderDataProvider()),
        ChangeNotifierProvider(create: (_) => PatientDataProvider()),
        ChangeNotifierProvider(create: (_) => ReportDataProvider()),
      ],
      child: MaterialApp(
        title: 'Medwave Admin Panel',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return authProvider.isAuthenticated 
                ? const DashboardScreen() 
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}

