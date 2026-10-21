import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/currency_helper.dart';
import '../../utils/theme.dart';
import '../../widgets/budget_progress_card.dart';
import '../../widgets/empty_state.dart';
import 'set_budget_dialog.dart';

class BudgetsTab extends StatelessWidget {
  const BudgetsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProv = context.watch<ExpenseProvider>();
    final currencySymbol = context.watch<SettingsProvider>().currencySymbol;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final statuses = expenseProv.budgetStatuses;
    final totalBudget = expenseProv.totalMonthlyBudgetLimit;
    final totalSpent = expenseProv.totalMonthlyBudgetSpent;
    final totalRemaining = totalBudget - totalSpent;
    final totalPct = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
    final totalPctInt = (totalPct * 100).toInt();

    final overBudgetCount = statuses.where((s) => s.isOverBudget).length;
    final warningCount = statuses.where((s) => s.isWarning).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets & Limits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Budget',
            onPressed: () {
              SetBudgetDialog.show(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Monthly Budget Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1E293B),
                    const Color(0xFF0F172A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFF475569),
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.speed, color: Color(0xFF2DD4BF), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Monthly Budget (${DateFormat('MMMM').format(DateTime.now())})',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (totalPct >= 1.0
                                  ? AppTheme.expenseColor
                                  : (totalPct >= 0.8
                                      ? AppTheme.warningColor
                                      : const Color(0xFF2DD4BF)))
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$totalPctInt% Spent',
                          style: TextStyle(
                            color: totalPct >= 1.0
                                ? AppTheme.expenseColor
                                : (totalPct >= 0.8
                                    ? AppTheme.warningColor
                                    : const Color(0xFF2DD4BF)),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    CurrencyHelper.format(totalBudget, symbol: currencySymbol),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: totalPct,
                      minHeight: 10,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        totalPct >= 1.0
                            ? AppTheme.expenseColor
                            : (totalPct >= 0.8
                                ? AppTheme.warningColor
                                : const Color(0xFF2DD4BF)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spent: ${CurrencyHelper.format(totalSpent, symbol: currencySymbol)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        totalRemaining >= 0
                            ? 'Remaining: ${CurrencyHelper.format(totalRemaining, symbol: currencySymbol)}'
                            : 'Exceeded by ${CurrencyHelper.format(-totalRemaining, symbol: currencySymbol)}',
                        style: TextStyle(
                          color: totalRemaining >= 0 ? const Color(0xFF6EE7B7) : AppTheme.expenseColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Over-budget or Near Limit alert callouts
            if (overBudgetCount > 0) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.expenseColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.expenseColor.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.expenseColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$overBudgetCount category has exceeded its set monthly limit! Consider reducing spending.',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.expenseColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (warningCount > 0) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.warningColor.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$warningCount category is above 80% of its budget limit.',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.warningColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Category Budgets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => SetBudgetDialog.show(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Set Budget', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (statuses.isEmpty)
              EmptyStateWidget(
                icon: Icons.track_changes_outlined,
                title: 'No Budgets Configured',
                message:
                    'Set category limits to keep your expenses under control and receive alerts.',
                buttonText: '+ Set First Budget',
                onButtonPressed: () => SetBudgetDialog.show(context),
              )
            else
              ...statuses.map((status) {
                return BudgetProgressCard(
                  status: status,
                  onEdit: () {
                    SetBudgetDialog.show(context, initialBudget: status.budget);
                  },
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Budget?'),
                        content: Text(
                            'Are you sure you want to delete the budget limit for "${status.budget.category}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () {
                              expenseProv.deleteBudget(status.budget.id);
                              Navigator.pop(ctx);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
          ],
        ),
      ),
    );
  }
}
