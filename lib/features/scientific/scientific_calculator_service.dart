import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';

class ScientificCalculatorService {
  static String calculate(String input) {
    if (input.trim().isEmpty) {
      return '0';
    }

    try {
      String expression = input.trim();

      expression = _prepareExpression(expression);
      expression = _completeMissingParentheses(expression);
      expression = _calculateScientificFunctions(expression);

      final double result = _calculateWithParser(expression);

      return _formatResult(result);
    } catch (e) {
      return 'Hatalı işlem';
    }
  }

  static String _prepareExpression(String expression) {
    return expression
        .replaceAll(' ', '')
        .replaceAll(',', '.')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('π', math.pi.toString());
  }

  //kullanıcı kapanış parantezini unutursa eksik parantezleri tamamlar
  static String _completeMissingParentheses(String expression) {
    int openCount = 0;
    int closeCount = 0;

    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '(') {
        openCount++;
      } else if (expression[i] == ')') {
        closeCount++;
      }
    }

    while (closeCount < openCount) {
      expression += ')';
      closeCount++;
    }

    return expression;
  }

  static String _calculateScientificFunctions(String expression) {
    final functions = ['sqrt', 'sin', 'cos', 'tan', 'log'];

    for (final functionName in functions) {
      expression = _calculateOneFunction(expression, functionName);
    }

    return expression;
  }

  static String _calculateOneFunction(String expression, String functionName) {
    final searchText = '$functionName(';

    while (expression.contains(searchText)) {
      final functionStartIndex = expression.indexOf(searchText);
      final openParenthesisIndex = functionStartIndex + functionName.length;

      final closeParenthesisIndex = _findClosingParenthesis(
        expression,
        openParenthesisIndex,
      );

      if (closeParenthesisIndex == -1) {
        throw Exception('Parantez hatası');
      }

      final insideText = expression.substring(
        openParenthesisIndex + 1,
        closeParenthesisIndex,
      );

      final double insideValue = _calculateInnerExpression(insideText);
      final double functionResult = _applyFunction(functionName, insideValue);

      final String safeResultText = _numberToExpressionText(functionResult);

      expression =
          expression.substring(0, functionStartIndex) +
          safeResultText +
          expression.substring(closeParenthesisIndex + 1);
    }

    return expression;
  }

  //fonksiyon parantezinin nerede kapandığını bulur.
  static int _findClosingParenthesis(String expression, int openIndex) {
    int counter = 0;

    for (int i = openIndex; i < expression.length; i++) {
      if (expression[i] == '(') {
        counter++;
      } else if (expression[i] == ')') {
        counter--;
      }

      if (counter == 0) {
        return i;
      }
    }

    return -1;
  }

  //sin(30+15), sqrt(16+9) gibi fonksiyon içerisindeki basit ifadeleri hesaplar.
  static double _calculateInnerExpression(String expression) {
    expression = _prepareExpression(expression);
    expression = _completeMissingParentheses(expression);
    expression = _calculateScientificFunctions(expression);

    return _calculateWithParser(expression);
  }

  static double _applyFunction(String functionName, double value) {
    switch (functionName) {
      case 'sin':
        return math.sin(_degreeToRadian(value));

      case 'cos':
        return math.cos(_degreeToRadian(value));

      case 'tan':
        final double radian = _degreeToRadian(value);

        if (math.cos(radian).abs() < 0.0000001) {
          throw Exception('Tanımsız tanjant');
        }

        return math.tan(radian);

      case 'log':
        if (value <= 0) {
          throw Exception('Logaritma hatası');
        }

        // logx 10 tabanlı logaritma olarak hesaplanır.
        return math.log(value) / math.ln10;

      case 'sqrt':
        if (value < 0) {
          throw Exception('Karekök hatası');
        }

        return math.sqrt(value);

      default:
        throw Exception('Bilinmeyen fonksiyon');
    }
  }

  static double _calculateWithParser(String expression) {
    final parser = Parser();
    final parsedExpression = parser.parse(expression);
    final contextModel = ContextModel();

    return parsedExpression.evaluate(EvaluationType.REAL, contextModel);
  }

  static double _degreeToRadian(double degree) {
    return degree * math.pi / 180;
  }

  static String _numberToExpressionText(double value) {
    if (value.isNaN || value.isInfinite) {
      throw Exception('Geçersiz sayı');
    }

    if (value.abs() < 0.0000001) {
      return '0';
    }

    if ((value - value.round()).abs() < 0.000001) {
      return value.round().toString();
    }

    String formatted = value.toStringAsFixed(15);

    while (formatted.contains('.') && formatted.endsWith('0')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }

    if (formatted.endsWith('.')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }

    return formatted;
  }

  static String _formatResult(double result) {
    if (result.isNaN || result.isInfinite) {
      return 'Hatalı işlem';
    }

    if (result.abs() < 0.0000001) {
      result = 0;
    }

    final double roundedToHalf = (result * 2).round() / 2;
    if ((result - roundedToHalf).abs() < 0.0000001) {
      result = roundedToHalf;
    }

    if ((result - result.round()).abs() < 0.000001) {
      return result.round().toString();
    }

    String formatted = result.toStringAsPrecision(16);

    if (formatted.contains('.') && !formatted.contains('e')) {
      while (formatted.endsWith('0')) {
        formatted = formatted.substring(0, formatted.length - 1);
      }

      if (formatted.endsWith('.')) {
        formatted = formatted.substring(0, formatted.length - 1);
      }
    }

    return formatted;
  }
}