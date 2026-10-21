import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/currency_helper.dart';
import '../../utils/theme.dart';
import '../auth/login_screen.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProv = context.watch<SettingsProvider>();
    final expenseProv = context.watch<ExpenseProvider>();
    final authProv = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentUser = authProv.currentUser;
    final userName = currentUser?.name ?? settingsProv.userName;
    final userEmail = currentUser?.email ?? 'Offline Profile';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.18),
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userEmail,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit Name',
                      onPressed: () {
                        _showEditNameDialog(context, settingsProv);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Preferences Section
            const Text(
              'Preferences',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              child: Column(
                children: [
                  // Currency Setting
                  ListTile(
                    leading: const Icon(Icons.currency_exchange, color: AppTheme.primaryColor),
                    title: const Text('Default Currency'),
                    subtitle: Text('${settingsProv.currencyCode} (${settingsProv.currencySymbol})'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showCurrencyDialog(context, settingsProv);
                    },
                  ),
                  const Divider(height: 1, indent: 56),

                  // Theme Mode Setting
                  ListTile(
                    leading: Icon(
                      settingsProv.themeMode == ThemeMode.dark
                          ? Icons.dark_mode_outlined
                          : settingsProv.themeMode == ThemeMode.light
                              ? Icons.light_mode_outlined
                              : Icons.brightness_auto_outlined,
                      color: AppTheme.secondaryColor,
                    ),
                    title: const Text('Appearance Theme'),
                    subtitle: Text(
                      settingsProv.themeMode == ThemeMode.dark
                          ? 'Dark Mode'
                          : settingsProv.themeMode == ThemeMode.light
                              ? 'Light Mode'
                              : 'System Default',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showThemeDialog(context, settingsProv);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Database & Backend Section
            const Text(
              'On-Device Embedded Storage',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.storage_rounded, color: Color(0xFF10B981), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Embedded Hive Database',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                'Running 100% locally on phone • Encrypted storage',
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatPill('Balance', CurrencyHelper.format(expenseProv.totalBalance, symbol: settingsProv.currencySymbol)),
                        _buildStatPill('Records', '${expenseProv.transactions.length}'),
                        _buildStatPill('Budgets', '${expenseProv.budgets.length}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Data Management Section
            const Text(
              'Data Management',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.restart_alt_rounded, color: AppTheme.primaryColor),
                    title: const Text('Reset Everything to Zero'),
                    subtitle: const Text('Clear all expenses & start fresh at ₹ 0'),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Reset to Zero?'),
                          content: const Text(
                              'This will wipe all existing transactions and budgets so your balance starts fresh at zero.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Reset to Zero'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await expenseProv.resetToZero();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All data reset to 0 successfully!')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Log Out?'),
                      content: const Text('Are you sure you want to sign out of your account?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Log Out'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await authProv.logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.red, size: 20),
                label: const Text(
                  'Log Out of Account',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // App Version Footer
            Center(
              child: Column(
                children: [
                  const Text(
                    'Expense Manager v1.0.0',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fast • Private • Embedded Local Server',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  void _showEditNameDialog(BuildContext context, SettingsProvider prov) {
    final controller = TextEditingController(text: prov.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Your Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                prov.setUserName(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, SettingsProvider prov) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Currency'),
        children: CurrencyHelper.supportedCurrencies.entries.map((entry) {
          final isSelected = prov.currencyCode == entry.key;
          return SimpleDialogOption(
            onPressed: () {
              prov.setCurrency(entry.key, entry.value);
              Navigator.pop(ctx);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${entry.key} (${entry.value})', style: const TextStyle(fontSize: 15)),
                if (isSelected) const Icon(Icons.check, color: AppTheme.primaryColor),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsProvider prov) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Theme'),
        children: [
          _themeOption(context, prov, ThemeMode.system, 'System Default', Icons.brightness_auto),
          _themeOption(context, prov, ThemeMode.light, 'Light Theme', Icons.light_mode),
          _themeOption(context, prov, ThemeMode.dark, 'Dark Theme', Icons.dark_mode),
        ],
      ),
    );
  }

  Widget _themeOption(
    BuildContext context,
    SettingsProvider prov,
    ThemeMode mode,
    String title,
    IconData icon,
  ) {
    final isSelected = prov.themeMode == mode;
    return SimpleDialogOption(
      onPressed: () {
        prov.setThemeMode(mode);
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 12),
              Text(title),
            ],
          ),
          if (isSelected) const Icon(Icons.check, color: AppTheme.primaryColor),
        ],
      ),
    );
  }
}
