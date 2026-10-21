import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryIconWidget extends StatelessWidget {
  final String categoryName;
  final bool isExpense;
  final double size;

  const CategoryIconWidget({
    super.key,
    required this.categoryName,
    this.isExpense = true,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final cat = CategoryItem.findCategory(categoryName, isExpense: isExpense);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cat.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Icon(
          cat.icon,
          color: cat.color,
          size: size * 0.52,
        ),
      ),
    );
  }
}
