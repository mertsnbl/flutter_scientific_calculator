import 'package:flutter/material.dart';

import '../history/calculation_history_model.dart';
import '../history/history_screen.dart';
import '../history/history_service.dart';
import 'scientific_calculator_service.dart';

class ScientificScreen extends StatefulWidget {
  const ScientificScreen({super.key});

  @override
  State<ScientificScreen> createState() => _ScientificScreenState();
}

class _ScientificScreenState extends State<ScientificScreen> {
  String _input = '';
  String _result = '0';

  final List<List<String>> _buttonRows = [
    ['sin(', 'cos(', 'tan(', 'log('],
    ['sqrt(', '^', '(', ')'],
    ['7', '8', '9', '÷'],
    ['4', '5', '6', '×'],
    ['1', '2', '3', '-'],
  ];

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _input = '';
        _result = '0';
      } else if (value == '⌫') {
        _deleteLastInput();
      } else if (value == '=') {
        _calculateResult();
      } else {
        _addInput(value);
      }
    });
  }

  void _addInput(String value) {
    final operators = ['+', '-', '×', '÷', '^'];

    if (_input.isNotEmpty && operators.contains(value)) {
      final lastChar = _input[_input.length - 1];

      if (operators.contains(lastChar)) {
        _input = _input.substring(0, _input.length - 1) + value;
        return;
      }
    }

    _input += value;
  }

  void _deleteLastInput() {
    if (_input.isEmpty) {
      return;
    }

    final functions = ['sin(', 'cos(', 'tan(', 'log(', 'sqrt('];

    for (final function in functions) {
      if (_input.endsWith(function)) {
        _input = _input.substring(0, _input.length - function.length);
        return;
      }
    }

    _input = _input.substring(0, _input.length - 1);
  }

  void _calculateResult() {
    if (_input.isEmpty) {
      return;
    }

    final calculatedResult = ScientificCalculatorService.calculate(_input);
    _result = calculatedResult;

    if (calculatedResult != 'Hatalı işlem') {
      HistoryService.addHistory(
        CalculationHistory(
          expression: _input,
          result: calculatedResult,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Color _getButtonBackground(String text) {
    if (text == 'C' || text == '⌫') {
      return const Color(0xFF8B1E2D);
    }

    if (text == '=') {
      return const Color(0xFF2F64D6);
    }

    if (['+', '-', '×', '÷'].contains(text)) {
      return const Color(0xFFA9772C);
    }

    if ([
      'sin(',
      'cos(',
      'tan(',
      'log(',
      'sqrt(',
      '^',
      '(',
      ')',
    ].contains(text)) {
      return const Color(0xFF4B5B73);
    }

    return const Color(0xFF1F2D44);
  }

  Widget _buildButton(String text, {double height = 46}) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: () => _onButtonPressed(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getButtonBackground(text),
          foregroundColor: Colors.white,
          elevation: 1.2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<String> buttons) {
    return Row(
      children: buttons.map((text) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: _buildButton(text),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlusRow() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: _buildButton('0'),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: _buildButton('.'),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: _buildButton('+'),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: _buildButton('C', height: 48),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: _buildButton('⌫', height: 48),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: _buildButton('=', height: 48),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryButton() {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton.icon(
        onPressed: _openHistory,
        icon: const Icon(Icons.history, size: 18),
        label: const Text(
          'Hesaplama Geçmişi',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCBD5E1),
          foregroundColor: const Color(0xFF162033),
          elevation: 0.7,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _input.isEmpty ? '0' : _input,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xFFCBD5E1),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              _result,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16233B),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFD8DEE8),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDisplay(),
                const SizedBox(height: 8),
                _buildHistoryButton(),
                const SizedBox(height: 8),
                ..._buttonRows.map(_buildRow),
                _buildPlusRow(),
                _buildBottomRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}