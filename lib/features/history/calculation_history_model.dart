class CalculationHistory {
  final String expression;
  final String result;
  final DateTime createdAt;

  CalculationHistory({
    required this.expression,
    required this.result,
    required this.createdAt,
  });
}