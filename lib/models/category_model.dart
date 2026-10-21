import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isExpense;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isExpense,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCode': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'colorValue': color.value,
      'isExpense': isExpense,
    };
  }

  factory CategoryItem.fromMap(Map<String, dynamic> map) {
    return findCategory(
      map['name'] as String,
      isExpense: map['isExpense'] as bool? ?? true,
    );
  }

  static const List<CategoryItem> defaultExpenseCategories = [
    CategoryItem(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant,
      color: Color(0xFFF97316), // Orange
      isExpense: true,
    ),
    CategoryItem(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_outlined,
      color: Color(0xFF8B5CF6), // Purple
      isExpense: true,
    ),
    CategoryItem(
      id: 'transport',
      name: 'Transportation',
      icon: Icons.directions_car_outlined,
      color: Color(0xFF3B82F6), // Blue
      isExpense: true,
    ),
    CategoryItem(
      id: 'bills',
      name: 'Bills & Utilities',
      icon: Icons.receipt_long_outlined,
      color: Color(0xFFEAB308), // Amber
      isExpense: true,
    ),
    CategoryItem(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_outlined,
      color: Color(0xFFEC4899), // Pink
      isExpense: true,
    ),
    CategoryItem(
      id: 'health',
      name: 'Health & Medical',
      icon: Icons.local_hospital_outlined,
      color: Color(0xFFEF4444), // Red
      isExpense: true,
    ),
    CategoryItem(
      id: 'education',
      name: 'Education',
      icon: Icons.school_outlined,
      color: Color(0xFF6366F1), // Indigo
      isExpense: true,
    ),
    CategoryItem(
      id: 'home',
      name: 'Home & Rent',
      icon: Icons.home_outlined,
      color: Color(0xFF14B8A6), // Teal
      isExpense: true,
    ),
    CategoryItem(
      id: 'travel',
      name: 'Travel & Trips',
      icon: Icons.flight_takeoff_outlined,
      color: Color(0xFF06B6D4), // Cyan
      isExpense: true,
    ),
    CategoryItem(
      id: 'other_exp',
      name: 'Other Expense',
      icon: Icons.category_outlined,
      color: Color(0xFF64748B), // Slate
      isExpense: true,
    ),
  ];

  static const List<CategoryItem> defaultIncomeCategories = [
    CategoryItem(
      id: 'salary',
      name: 'Salary & Wages',
      icon: Icons.payments_outlined,
      color: Color(0xFF10B981), // Emerald
      isExpense: false,
    ),
    CategoryItem(
      id: 'freelance',
      name: 'Freelance & Side Gig',
      icon: Icons.laptop_chromebook_outlined,
      color: Color(0xFF059669), // Dark emerald
      isExpense: false,
    ),
    CategoryItem(
      id: 'investments',
      name: 'Investments & Returns',
      icon: Icons.trending_up,
      color: Color(0xFF22C55E), // Green
      isExpense: false,
    ),
    CategoryItem(
      id: 'bonus',
      name: 'Bonus & Incentives',
      icon: Icons.card_giftcard_outlined,
      color: Color(0xFF84CC16), // Lime
      isExpense: false,
    ),
    CategoryItem(
      id: 'other_inc',
      name: 'Other Income',
      icon: Icons.account_balance_outlined,
      color: Color(0xFF0284C7), // Sky blue
      isExpense: false,
    ),
  ];

  static CategoryItem findCategory(String name, {bool isExpense = true}) {
    final list = isExpense ? defaultExpenseCategories : defaultIncomeCategories;
    for (final item in list) {
      if (item.name.toLowerCase() == name.toLowerCase() ||
          item.id.toLowerCase() == name.toLowerCase()) {
        return item;
      }
    }
    // Check opposite list
    final altList = isExpense ? defaultIncomeCategories : defaultExpenseCategories;
    for (final item in altList) {
      if (item.name.toLowerCase() == name.toLowerCase() ||
          item.id.toLowerCase() == name.toLowerCase()) {
        return item;
      }
    }
    return CategoryItem(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      icon: isExpense ? Icons.category_outlined : Icons.attach_money,
      color: isExpense ? const Color(0xFF64748B) : const Color(0xFF10B981),
      isExpense: isExpense,
    );
  }
}
