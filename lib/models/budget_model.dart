class BudgetModel {
  final String id;
  final String category;
  final double monthlyLimit;
  final double alertThreshold; // 0.8 means 80%

  BudgetModel({
    required this.id,
    required this.category,
    required this.monthlyLimit,
    this.alertThreshold = 0.8,
  });

  BudgetModel copyWith({
    String? id,
    String? category,
    double? monthlyLimit,
    double? alertThreshold,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      category: category ?? this.category,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      alertThreshold: alertThreshold ?? this.alertThreshold,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'monthlyLimit': monthlyLimit,
      'alertThreshold': alertThreshold,
    };
  }

  factory BudgetModel.fromMap(Map<dynamic, dynamic> map) {
    return BudgetModel(
      id: map['id']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      monthlyLimit: (map['monthlyLimit'] as num?)?.toDouble() ?? 0.0,
      alertThreshold: (map['alertThreshold'] as num?)?.toDouble() ?? 0.8,
    );
  }
}
