
import 'package:flutter/material.dart';
import '../models/ahp_data.dart';

class AhpProvider with ChangeNotifier {
  // Default Data for Case Study: Pabrik Gula Tebu
  List<String> criteria = [
    'Efisiensi Evaporasi',
    'Tingkat Rendemen',
    'Risiko Kebocoran Uap',
    'Biaya Perbaikan'
  ];

  List<String> alternatives = [
    'Boiler Station',
    'Cane Cutter',
    'Mill Turbines',
    'Vacuum Pan',
    'Centrifugals'
  ];

  // Matrices
  // criteriaMatrix is n x n
  List<List<double>> criteriaMatrix = [];
  
  // Map of Criterion -> (m x m) Matrix for Alternatives
  Map<String, List<List<double>>> alternativesMatrices = {};

  void initMatrices() {
    // Initialize Criteria Matrix (Identity)
    int n = criteria.length;
    criteriaMatrix = List.generate(n, (i) => List.generate(n, (j) => i == j ? 1.0 : 1.0));

    // Initialize Alternatives Matrices
    int m = alternatives.length;
    for (var crit in criteria) {
      alternativesMatrices[crit] = List.generate(m, (i) => List.generate(m, (j) => i == j ? 1.0 : 1.0));
    }
    notifyListeners();
  }

  void updateCriteriaComparison(int i, int j, double value) {
    criteriaMatrix[i][j] = value;
    criteriaMatrix[j][i] = 1 / value;
    notifyListeners();
  }

  void updateAlternativeComparison(String criterion, int i, int j, double value) {
    if (alternativesMatrices.containsKey(criterion)) {
      alternativesMatrices[criterion]![i][j] = value;
      alternativesMatrices[criterion]![j][i] = 1 / value;
      notifyListeners();
    }
  }

  AhpSubmitData getSubmitData() {
    return AhpSubmitData(
      criteria: criteria,
      alternatives: alternatives,
      criteriaMatrix: criteriaMatrix,
      alternativesMatrices: alternativesMatrices,
    );
  }
}
