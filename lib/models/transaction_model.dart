class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final bool isExpense;
  final String category;
  final DateTime date;
  final String paymentMethod;
  final String notes;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.category,
    required this.date,
    this.paymentMethod = 'Cash',
    this.notes = '',
  });

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    bool? isExpense,
    String? category,
    DateTime? date,
    String? paymentMethod,
    String? notes,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      isExpense: isExpense ?? this.isExpense,
      category: category ?? this.category,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isExpense': isExpense,
      'category': category,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'notes': notes,
    };
  }

  factory TransactionModel.fromMap(Map<dynamic, dynamic> map) {
    return TransactionModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      isExpense: map['isExpense'] as bool? ?? true,
      category: map['category']?.toString() ?? 'Other',
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      paymentMethod: map['paymentMethod']?.toString() ?? 'Cash',
      notes: map['notes']?.toString() ?? '',
    );
  }
}
