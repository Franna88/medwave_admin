# Medwave Admin Panel

A comprehensive Flutter-based admin panel for Medwave Group to manage healthcare providers, track patient progress, and generate marketing reports.

## Features

### 🔐 Authentication & Security
- Secure login system with role-based access
- Session management with persistent authentication
- Demo credentials: `admin` / `medwave2024`

### 👥 Provider Management
- **Provider Approval Workflow**: Review and approve new provider registrations
- **Provider Directory**: View all approved healthcare providers
- **Provider Analytics**: Track provider performance and patient outcomes
- **Technology Tracking**: Monitor which Medwave technologies each provider uses

### 📊 Patient Progress Tracking
- **Wound Healing Progress**: Track wound size, depth, and healing metrics
- **Weight Loss Monitoring**: Monitor patient weight loss progress
- **Combined Treatment Support**: Support for patients receiving both treatments
- **Progress Visualization**: Charts and graphs showing patient improvement over time

### 📈 Analytics & Reporting
- **Real-time Dashboard**: Key metrics and performance indicators
- **Patient Progress Charts**: Visual representation of treatment outcomes
- **Provider Performance Analytics**: Revenue and patient success metrics
- **Treatment Type Distribution**: Pie charts showing treatment type breakdown

### 📋 Report Builder (Coming Soon)
- **Drag & Drop Interface**: Build custom marketing reports
- **Predefined Metrics**: Ready-to-use analytics components
- **Template System**: Professional report templates
- **Export Functionality**: PDF and Excel export capabilities

## Technology Stack

- **Framework**: Flutter 3.8+
- **State Management**: Provider pattern
- **Charts**: fl_chart for data visualization
- **UI Components**: Material Design 3
- **Data Tables**: data_table_2 for advanced table functionality
- **Drag & Drop**: drag_and_drop_lists for report builder

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models
│   ├── provider_model.dart   # Healthcare provider model
│   ├── patient_model.dart    # Patient and progress tracking model
│   └── report_model.dart     # Report and analytics model
├── providers/                # State management
│   ├── auth_provider.dart    # Authentication state
│   ├── provider_data_provider.dart  # Provider data management
│   └── patient_data_provider.dart   # Patient data management
├── screens/                  # Main application screens
│   ├── login_screen.dart     # Authentication screen
│   └── dashboard_screen.dart # Main dashboard with navigation
├── widgets/                  # Reusable UI components
│   ├── dashboard_overview.dart    # Dashboard overview widget
│   └── sidebar_navigation.dart    # Navigation sidebar
└── theme/                    # Application theming
    └── app_theme.dart        # Medwave brand colors and styling
```

## Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Windows 10/11 for desktop development

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd medwave_admin
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run -d windows
   ```

### Demo Data

The application includes comprehensive mock data for demonstration:

- **3 Approved Providers**: Dr. Sarah Johnson, Dr. Michael Chen, Dr. Emily Rodriguez
- **2 Pending Approvals**: Dr. James Wilson, Dr. Lisa Thompson
- **4 Sample Patients**: John Smith, Maria Garcia, Robert Johnson, Lisa Chen
- **Progress Records**: Detailed treatment progress with realistic metrics

## Key Features in Detail

### Provider Approval System
- Review provider applications from the website form
- Approve or reject providers with detailed reasoning
- Track approval workflow and timeline
- Monitor provider onboarding process

### Patient Progress Tracking
- **Wound Healing Metrics**:
  - Wound size (cm²)
  - Wound depth (cm)
  - Pain level (0-10 scale)
  - Mobility score (0-100)
  - Progress photos and notes

- **Weight Loss Metrics**:
  - Weight tracking (kg)
  - Body composition changes
  - Progress milestones
  - Treatment adherence

### Analytics Dashboard
- **Real-time Metrics**:
  - Total providers and pending approvals
  - Active patients and average progress
  - Monthly revenue trends
  - Treatment success rates

- **Visual Analytics**:
  - Patient progress timeline charts
  - Treatment type distribution
  - Provider performance comparison
  - Revenue analysis

## Branding & Design

The admin panel uses Medwave's official brand colors:
- **Primary Blue**: #162694
- **Success Green**: #5CA301
- **Accent Red**: #F83D3D
- **Accent Pink**: #F4448E

The design follows Material Design 3 principles with a professional, medical-grade aesthetic suitable for healthcare administration.

## Future Enhancements

### Phase 2 Features
- **Advanced Report Builder**: Drag-and-drop interface for custom reports
- **Provider Portal**: Direct provider access for patient management
- **Patient Portal**: Patient-facing progress tracking
- **Integration APIs**: Connect with existing Medwave systems
- **Advanced Analytics**: Machine learning insights and predictions

### Phase 3 Features
- **Mobile App**: Provider and patient mobile applications
- **Real-time Notifications**: Instant updates on patient progress
- **Video Consultations**: Integrated telehealth features
- **Payment Processing**: Billing and payment management
- **Compliance Tools**: HIPAA and regulatory compliance features

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is proprietary software developed for Medwave Group. All rights reserved.

## Support

For technical support or questions about the admin panel, please contact the development team or refer to the Medwave Group documentation.

---

**Medwave Group** - Global Health Solutions Powered by Regenerative Technologies
