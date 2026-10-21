import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/currency_helper.dart';
import '../../utils/theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/transaction_tile.dart';
import 'add_edit_transaction_dialog.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProv = context.watch<ExpenseProvider>();
    final currencySymbol = context.watch<SettingsProvider>().currencySymbol;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredList = expenseProv.filteredTransactions;

    // Filtered total calculation
    final filteredIncome = filteredList
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final filteredExpense = filteredList
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Transaction',
            onPressed: () {
              AddEditTransactionSheet.show(context);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AddEditTransactionSheet.show(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search & Filter header container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by title, category, notes...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              expenseProv.setSearchQuery('');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onChanged: (val) {
                    expenseProv.setSearchQuery(val);
                  },
                ),

                const SizedBox(height: 10),

                // Filter row 1: Type (All, Expense, Income)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Type Segment
                      _buildChip(
                        label: 'All Types',
                        isSelected: expenseProv.filterType == 'All',
                        onSelected: () => expenseProv.setFilterType('All'),
                      ),
                      const SizedBox(width: 6),
                      _buildChip(
                        label: 'Expenses',
                        isSelected: expenseProv.filterType == 'Expense',
                        color: AppTheme.expenseColor,
                        onSelected: () => expenseProv.setFilterType('Expense'),
                      ),
                      const SizedBox(width: 6),
                      _buildChip(
                        label: 'Income',
                        isSelected: expenseProv.filterType == 'Income',
                        color: AppTheme.incomeColor,
                        onSelected: () => expenseProv.setFilterType('Income'),
                      ),

                      const VerticalDivider(width: 16),

                      // Time Range
                      _buildChip(
                        label: 'All Time',
                        isSelected: expenseProv.timeRange == 'All',
                        onSelected: () => expenseProv.setTimeRange('All'),
                      ),
                      const SizedBox(width: 6),
                      _buildChip(
                        label: 'This Month',
                        isSelected: expenseProv.timeRange == 'This Month',
                        onSelected: () => expenseProv.setTimeRange('This Month'),
                      ),
                      const SizedBox(width: 6),
                      _buildChip(
                        label: 'This Week',
                        isSelected: expenseProv.timeRange == 'This Week',
                        onSelected: () => expenseProv.setTimeRange('This Week'),
                      ),
                      const SizedBox(width: 6),
                      _buildChip(
                        label: 'Today',
                        isSelected: expenseProv.timeRange == 'Today',
                        onSelected: () => expenseProv.setTimeRange('Today'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Mini summary bar for filtered results
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredList.length} Records found',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
                Row(
                  children: [
                    Text(
                      '+${CurrencyHelper.format(filteredIncome, symbol: currencySymbol)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.incomeColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '-${CurrencyHelper.format(filteredExpense, symbol: currencySymbol)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.expenseColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: filteredList.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.search_off_outlined,
                    title: 'No Matching Transactions',
                    message: 'Try clearing your search query or changing active filters.',
                    buttonText: 'Reset Filters',
                    onButtonPressed: () {
                      _searchController.clear();
                      expenseProv.setSearchQuery('');
                      expenseProv.setFilterType('All');
                      expenseProv.setTimeRange('All');
                      expenseProv.setFilterCategory(null);
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: filteredList.length,
                    itemBuilder: (ctx, i) {
                      final tx = filteredList[i];
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
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onSelected,
  }) {
    final activeColor = color ?? AppTheme.primaryColor;
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade400,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? activeColor : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }
}
