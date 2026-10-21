import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/empty_state.dart';
import '../transactions/add_edit_transaction_dialog.dart';

class DashboardTab extends StatelessWidget {
  final Function(int) onNavigateTab;

  const DashboardTab({
    super.key,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final expenseProv = context.watch<ExpenseProvider>();
    final settingsProv = context.watch<SettingsProvider>();
    final authProv = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alertBudgets = expenseProv.alertBudgets;

    final userName = authProv.currentUser?.name ?? settingsProv.userName;
    final income = expenseProv.thisMonthIncome;
    final expense = expenseProv.thisMonthExpense;
    final savingsRate = income > 0 ? (((income - expense) / income) * 100).clamp(-100, 100).toInt() : 0;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            expenseProv.loadData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Greeting & Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $userName 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: 'Settings',
                      onPressed: () => onNavigateTab(4), // Settings Tab
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Over-budget or Near-limit Warning Banner
                if (alertBudgets.isNotEmpty) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: alertBudgets.any((b) => b.isOverBudget)
                          ? AppTheme.expenseColor.withOpacity(0.12)
                          : AppTheme.warningColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: alertBudgets.any((b) => b.isOverBudget)
                            ? AppTheme.expenseColor.withOpacity(0.4)
                            : AppTheme.warningColor.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          alertBudgets.any((b) => b.isOverBudget)
                              ? Icons.warning_amber_rounded
                              : Icons.info_outline,
                          color: alertBudgets.any((b) => b.isOverBudget)
                              ? AppTheme.expenseColor
                              : AppTheme.warningColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            alertBudgets.any((b) => b.isOverBudget)
                                ? 'Alert: ${alertBudgets.where((b) => b.isOverBudget).length} category exceeded monthly budget!'
                                : '${alertBudgets.length} category is nearing its monthly limit.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: alertBudgets.any((b) => b.isOverBudget)
                                  ? AppTheme.expenseColor
                                  : AppTheme.warningColor,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => onNavigateTab(2), // Budgets tab
                          child: const Text('View', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],

                // Main Financial Summary Card
                SummaryCard(
                  onAddExpense: () {
                    AddEditTransactionSheet.show(context, defaultIsExpense: true);
                  },
                  onAddIncome: () {
                    AddEditTransactionSheet.show(context, defaultIsExpense: false);
                  },
                ),

                const SizedBox(height: 18),

                // Quick Analytics Row (Savings Rate & Stats)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (savingsRate >= 0
                                        ? AppTheme.incomeColor
                                        : AppTheme.expenseColor)
                                    .withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                savingsRate >= 0 ? Icons.savings_outlined : Icons.trending_down,
                                color: savingsRate >= 0
                                    ? AppTheme.incomeColor
                                    : AppTheme.expenseColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Savings Rate',
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                Text(
                                  '$savingsRate%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: savingsRate >= 0
                                        ? AppTheme.incomeColor
                                        : AppTheme.expenseColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.pie_chart_outline,
                                color: AppTheme.secondaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Records',
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                Text(
                                  '${expenseProv.transactions.length}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Recent Transactions Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (expenseProv.transactions.isNotEmpty)
                      TextButton(
                        onPressed: () => onNavigateTab(3), // Transactions tab
                        child: const Text('See All'),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Recent Transactions List
                if (expenseProv.recentTransactions.isEmpty)
                  EmptyStateWidget(
                    icon: Icons.receipt_long_outlined,
                    title: 'No Transactions Yet',
                    message: 'Add your first income or expense to start tracking your finances.',
                    buttonText: '+ Add Expense',
                    onButtonPressed: () {
                      AddEditTransactionSheet.show(context, defaultIsExpense: true);
                    },
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expenseProv.recentTransactions.length,
                    itemBuilder: (ctx, i) {
                      final tx = expenseProv.recentTransactions[i];
                      return TransactionTile(
                        transaction: tx,
                        onTap: () {
                          AddEditTransactionSheet.show(
                            context,
                            initialTransaction: tx,
                          );
                        },
                        onDelete: () {
                          expenseProv.deleteTransaction(tx.id);
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
