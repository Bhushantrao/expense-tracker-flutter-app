# 💰 Expense Tracker & Manager

A modern, fast, and feature-rich personal finance and expense tracking application built with **Flutter**, **Provider**, and **Hive**. Designed with an offline-first architecture, beautiful Material 3 aesthetics, dark mode support, and interactive analytics.

---

## ✨ Features

- 📊 **Interactive Dashboard**: Real-time overview of total balance, income, and expenses with recent transaction quick-views.
- 💸 **Income & Expense Tracking**: Effortlessly log, edit, and categorize daily income and expense transactions.
- 🎯 **Smart Budget Management**: Set category-wise monthly spending limits with progress indicators and automatic over-budget alert badges.
- 📈 **Visual Analytics & Insights**: Category-level expense breakdowns and spending trends powered by `fl_chart`.
- 🗂️ **Predefined & Custom Categories**: Curated icons and vibrant color coding for Food, Shopping, Transport, Bills, Entertainment, Health, Salary, Investments, and more.
- 💱 **Multi-Currency Support**: Easily switch between currencies including **INR (₹)**, **USD ($)**, **EUR (€)**, **GBP (£)**, **JPY (¥)**, **CAD**, **AUD**, and **AED**.
- 🌓 **Dark & Light Themes**: Seamless Material 3 theming with support for Light, Dark, and System default modes.
- ⚡ **Offline-First & Fast**: Fully persistent local storage using lightweight embedded **Hive** database (no cloud setup required).
- 👤 **User Profile & State**: User authentication and session management handled cleanly using **Provider**.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev/) (SDK ^3.12.2)
- **Language**: [Dart](https://dart.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Database**: [Hive](https://pub.dev/packages/hive) & [hive_flutter](https://pub.dev/packages/hive_flutter)
- **Charts & Visualization**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Formatting & Localization**: [intl](https://pub.dev/packages/intl)
- **Icons**: Cupertino Icons & Material Icons

---

## 📂 Project Structure

```text
lib/
├── main.dart                  # Application entry point & theme initialization
├── models/                    # Data models
│   ├── budget_model.dart      # Budget tracking model
│   ├── category_model.dart    # Categories, icons, and colors
│   ├── transaction_model.dart # Expense and Income transactions
│   └── user_model.dart        # User profile model
├── providers/                 # State management (ChangeNotifiers)
│   ├── auth_provider.dart     # Authentication & user profile state
│   ├── expense_provider.dart  # Transactions, totals, and budget alerts
│   └── settings_provider.dart # Currency and Theme configuration
├── screens/                   # UI Screens & Tabs
│   ├── analytics/             # Expense charts & category breakdown
│   ├── auth/                  # Login and onboarding screens
│   ├── budgets/               # Budget overview & target setting dialog
│   ├── dashboard/             # Main dashboard with balance & quick actions
│   ├── settings/              # App settings, currency, and theme switches
│   ├── transactions/          # Transaction history, search & add/edit dialogs
│   ├── main_navigation_screen.dart # Bottom navigation bar wrapper
│   └── splash_screen.dart     # Animated launch screen
├── services/                  # Persistent data layer
│   └── database_service.dart  # Hive box management & data helpers
├── utils/                     # Helpers & theme definitions
│   ├── currency_helper.dart   # Currency formatters & symbols
│   └── theme.dart             # Light and Dark color schemes
└── widgets/                   # Reusable UI components
    ├── budget_progress_card.dart
    ├── category_icon.dart
    ├── empty_state.dart
    ├── summary_card.dart
    └── transaction_tile.dart
```

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.12.0 or higher)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / Xcode / VS Code with Flutter extension
- An emulator or physical device for testing

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Bhushantrao/expense-tracker-flutter-app.git
   cd expense-tracker-flutter-app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   # Run on connected device or emulator
   flutter run

   # Or specify target platform
   flutter run -d chrome      # Web
   flutter run -d windows     # Windows Desktop
   flutter run -d android     # Android
   ```

---

## 🧪 Testing & Linting

Run automated widget and unit tests:
```bash
flutter test
```

Check code formatting and static analysis:
```bash
flutter analyze
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/Bhushantrao/expense-tracker-flutter-app.git).

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) - feel free to use and adapt it for personal or commercial projects.
