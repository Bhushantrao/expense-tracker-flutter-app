import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/budget_model.dart';
import '../../models/category_model.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';

class SetBudgetDialog extends StatefulWidget {
  final BudgetModel? initialBudget;

  const SetBudgetDialog({super.key, this.initialBudget});

  static Future<void> show(BuildContext context, {BudgetModel? initialBudget}) {
    return showDialog(
      context: context,
      builder: (ctx) => SetBudgetDialog(initialBudget: initialBudget),
    );
  }

  @override
  State<SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends State<SetBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedCategory;
  late TextEditingController _limitController;
  double _alertThreshold = 0.8;

  @override
  void initState() {
    super.initState();
    if (widget.initialBudget != null) {
      _selectedCategory = widget.initialBudget!.category;
      _limitController = TextEditingController(
        text: widget.initialBudget!.monthlyLimit.toStringAsFixed(0),
      );
      _alertThreshold = widget.initialBudget!.alertThreshold;
    } else {
      _selectedCategory = CategoryItem.defaultExpenseCategories.first.name;
      _limitController = TextEditingController();
      _alertThreshold = 0.8;
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final limit = double.tryParse(_limitController.text.trim()) ?? 0.0;
    if (limit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget limit must be greater than 0')),
      );
      return;
    }

    final isEdit = widget.initialBudget != null;
    final budget = BudgetModel(
      id: isEdit
          ? widget.initialBudget!.id
          : 'budget_${_selectedCategory.toLowerCase().replaceAll(' ', '_')}',
      category: _selectedCategory,
      monthlyLimit: limit,
      alertThreshold: _alertThreshold,
    );

    context.read<ExpenseProvider>().setBudget(budget);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = context.watch<SettingsProvider>().currencySymbol;
    final isEdit = widget.initialBudget != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        isEdit ? 'Edit Budget' : 'Set Category Budget',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Set a monthly spending limit to receive alerts before overspending.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Expense Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: CategoryItem.defaultExpenseCategories.map((c) {
                  return DropdownMenuItem<String>(
                    value: c.name,
                    child: Row(
                      children: [
                        Icon(c.icon, color: c.color, size: 20),
                        const SizedBox(width: 8),
                        Text(c.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: isEdit
                    ? null
                    : (val) {
                        if (val != null) {
                          setState(() => _selectedCategory = val);
                        }
                      },
              ),

              const SizedBox(height: 14),

              // Monthly limit field
              TextFormField(
                controller: _limitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Monthly Limit',
                  prefixText: '$currencySymbol ',
                  prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  hintText: '5000',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter budget limit';
                  if (double.tryParse(val.trim()) == null) return 'Enter a valid number';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Alert threshold slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Alert Threshold:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${(_alertThreshold * 100).toInt()}% of limit',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _alertThreshold,
                    min: 0.5,
                    max: 0.95,
                    divisions: 9,
                    label: '${(_alertThreshold * 100).toInt()}%',
                    onChanged: (val) {
                      setState(() => _alertThreshold = val);
                    },
                  ),
                  const Text(
                    'You will see an alert badge when spending reaches this percentage.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEdit ? 'Save Changes' : 'Set Budget'),
        ),
      ],
    );
  }
}
