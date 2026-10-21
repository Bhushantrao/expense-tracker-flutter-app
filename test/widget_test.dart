import 'package:flutter_test/flutter_test.dart';
import 'package:expense_manager/main.dart';

void main() {
  testWidgets('ExpenseManagerApp basic smoke test', (WidgetTester tester) async {
    // Basic instantiation test
    expect(const ExpenseManagerApp(), isNotNull);
  });
}
