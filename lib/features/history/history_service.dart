import 'calculation_history_model.dart';

class HistoryService {
  static final List<CalculationHistory> _historyList = [];

  static void addHistory(CalculationHistory history) {
    _historyList.add(history);
  }

  static List<CalculationHistory> getHistory() {
    return List.unmodifiable(_historyList.reversed);
  }

  static void clearHistory() {
    _historyList.clear();
  }
}
