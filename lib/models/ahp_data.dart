
class AhpSubmitData {
  final List<String> criteria;
  final List<String> alternatives;
  final List<List<double>> criteriaMatrix;
  final Map<String, List<List<double>>> alternativesMatrices;

  AhpSubmitData({
    required this.criteria,
    required this.alternatives,
    required this.criteriaMatrix,
    required this.alternativesMatrices,
  });

  Map<String, dynamic> toJson() {
    return {
      'criteria': criteria,
      'alternatives': alternatives,
      'criteria_matrix': criteriaMatrix,
      'alternatives_matrices': alternativesMatrices,
    };
  }
}

class AhpResult {
  final Map<String, double> criteriaWeights;
  final double consistencyRatio;
  final List<AhpRank> results;

  AhpResult({
    required this.criteriaWeights,
    required this.consistencyRatio,
    required this.results,
  });

  factory AhpResult.fromJson(Map<String, dynamic> json) {
    var list = json['results'] as List;
    List<AhpRank> rankingList = list.map((i) => AhpRank.fromJson(i)).toList();

    return AhpResult(
      criteriaWeights: Map<String, double>.from(json['criteria_weights'].map((k, v) => MapEntry(k, (v as num).toDouble()))),
      consistencyRatio: (json['consistency_ratio'] as num).toDouble(),
      results: rankingList,
    );
  }
}

class AhpRank {
  final int rank;
  final String alternative;
  final double score;

  AhpRank({required this.rank, required this.alternative, required this.score});

  factory AhpRank.fromJson(Map<String, dynamic> json) {
    return AhpRank(
      rank: json['rank'],
      alternative: json['alternative'],
      score: (json['score'] as num).toDouble(),
    );
  }
}
