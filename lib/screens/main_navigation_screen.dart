import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../utils/theme.dart';
import 'dashboard/dashboard_tab.dart';
import 'analytics/analytics_tab.dart';
import 'budgets/budgets_tab.dart';
import 'transactions/transactions_tab.dart';
import 'settings/settings_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasAlert = context.watch<ExpenseProvider>().hasOverBudgetAlert;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      DashboardTab(onNavigateTab: _onNavigate),
      const AnalyticsTab(),
      const BudgetsTab(),
      const TransactionsTab(),
      const SettingsTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavigate,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        indicatorColor: AppTheme.primaryColor.withOpacity(0.18),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppTheme.primaryColor),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: AppTheme.primaryColor),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: hasAlert,
              backgroundColor: AppTheme.expenseColor,
              smallSize: 8,
              child: const Icon(Icons.track_changes_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: hasAlert,
              backgroundColor: AppTheme.expenseColor,
              smallSize: 8,
              child: const Icon(Icons.track_changes, color: AppTheme.primaryColor),
            ),
            label: 'Budgets',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: AppTheme.primaryColor),
            label: 'History',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: AppTheme.primaryColor),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
