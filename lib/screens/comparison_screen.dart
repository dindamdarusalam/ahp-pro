
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ahp_provider.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  // Navigation State
  int _stageIndex = 0; // 0 = Criteria, 1...n = Alternatives for each Criterion
  int _pairIndex = 0;
  List<Map<String, dynamic>> _currentPairs = [];
  double _currentValue = 1.0; // 1 to 9 (Positive means Left is better, if we handle logic right)
  
  // Actually, standard AHP slider often goes from 9 (A) ... 1 ... 9 (B).
  // Let's implement range -9 to 9. 
  // 0 = 1 (Equal). 
  // -8 = 9 for Left.
  // 8 = 9 for Right.
  // We'll map slider value to Saaty.
  double _sliderValue = 0.0; // -8 to 8 integers? Or just Steps.

  @override
  void initState() {
    super.initState();
    _generateCriteriaPairs();
  }

  void _generateCriteriaPairs() {
    final provider = Provider.of<AhpProvider>(context, listen: false);
    _currentPairs = [];
    int n = provider.criteria.length;
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        _currentPairs.add({
          'type': 'criteria',
          'item1': provider.criteria[i],
          'item2': provider.criteria[j],
          'index1': i,
          'index2': j,
        });
      }
    }
  }

  void _generateAlternativePairs(String criterion) {
    final provider = Provider.of<AhpProvider>(context, listen: false);
    _currentPairs = [];
    int n = provider.alternatives.length;
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        _currentPairs.add({
          'type': 'alternative',
          'criterion': criterion,
          'item1': provider.alternatives[i],
          'item2': provider.alternatives[j],
          'index1': i,
          'index2': j,
        });
      }
    }
  }

  void _next() {
    final provider = Provider.of<AhpProvider>(context, listen: false);
    
    // Save current value
    double saatyValue;
    if (_sliderValue == 0) saatyValue = 1;
    else if (_sliderValue < 0) saatyValue = _sliderValue.abs() + 1; // Left side
    else saatyValue = 1 / (_sliderValue + 1); // Right side favored? 
    // Wait, Standard Saaty:
    // If A is 3x B, value is 3. Matrix[A][B] = 3.
    // If B is 3x A, value is 1/3. Matrix[A][B] = 1/3.
    // Slider: Left (A) ... Equal ... Right (B)
    // Left: 9, 8, ... 2. Value > 1.
    // Right: 2, ... 9. Value < 1.
    
    if (_sliderValue < 0) {
      // Favors Left (Item 1)
      saatyValue = _sliderValue.abs() + 1;
    } else if (_sliderValue > 0) {
      // Favors Right (Item 2)
      saatyValue = 1.0 / (_sliderValue + 1);
    } else {
      saatyValue = 1.0;
    }

    final pair = _currentPairs[_pairIndex];
    if (pair['type'] == 'criteria') {
      provider.updateCriteriaComparison(pair['index1'], pair['index2'], saatyValue);
    } else {
      provider.updateAlternativeComparison(pair['criterion'], pair['index1'], pair['index2'], saatyValue);
    }

    // Move next
    if (_pairIndex < _currentPairs.length - 1) {
      setState(() {
        _pairIndex++;
        _sliderValue = 0;
      });
    } else {
      // End of this stage
      if (_stageIndex == 0) {
        // Finished Criteria, move to first Alternative set
        _stageIndex++;
        _pairIndex = 0;
        _sliderValue = 0;
        _generateAlternativePairs(provider.criteria[0]);
        setState(() {});
      } else {
        // Finished Alternatives for a Criterion
        if (_stageIndex < provider.criteria.length) {
          _stageIndex++;
          _pairIndex = 0;
          _sliderValue = 0;
          _generateAlternativePairs(provider.criteria[_stageIndex - 1]);
          setState(() {});
        } else {
          // Finished ALL
          Navigator.pushNamed(context, '/result');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPairs.isEmpty) return const SizedBox(); // Should not happen
    
    final pair = _currentPairs[_pairIndex];
    final provider = Provider.of<AhpProvider>(context);
    
    String title = _stageIndex == 0 
        ? 'Compare Criteria' 
        : 'Compare Alternatives for\n"${provider.criteria[_stageIndex - 1]}"';
        
    int totalStages = 1 + provider.criteria.length;
    double progress = (_stageIndex + (_pairIndex / _currentPairs.length)) / totalStages;

    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress, color: Colors.orange, backgroundColor: Colors.grey[200]),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${_pairIndex + 1} / ${_currentPairs.length}', 
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildItemCard(pair['item1'], true),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('VS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
                        ),
                        Expanded(
                          child: _buildItemCard(pair['item2'], false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      _getConfidenceLabel(), 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.green,
                        inactiveTrackColor: Colors.green.withOpacity(0.3),
                        thumbColor: Colors.green,
                        overlayColor: Colors.green.withOpacity(0.1),
                        trackHeight: 10,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                      ),
                      child: Slider(
                        value: _sliderValue,
                        min: -8,
                        max: 8,
                        divisions: 16,
                        label: _sliderValue.round().toString(),
                        onChanged: (val) {
                          setState(() {
                            _sliderValue = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Left is Important', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        Text('Equal', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        Text('Right is Important', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _next,
                        child: const Text('NEXT COMPARISON'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(String text, bool isLeft) {
    bool isFavored = (isLeft && _sliderValue < 0) || (!isLeft && _sliderValue > 0);
    return Card(
      elevation: isFavored ? 4 : 0,
      color: isFavored ? Colors.green.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isFavored ? Colors.green : Colors.grey.shade300, width: isFavored ? 2 : 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 120, // fixed height for better alignment
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isFavored ? FontWeight.bold : FontWeight.normal,
            color: isFavored ? Colors.green.shade900 : Colors.black87,
          ),
        ),
      ),
    );
  }

  String _getConfidenceLabel() {
    double val = _sliderValue;
    if (val == 0) return "Equally Important (1)";
    
    String side = val < 0 ? "Left" : "Right";
    int score = val.abs().toInt() + 1; // 1 to 9
    
    Map<int, String> labels = {
      1: "Equally Important",
      2: "Equally to Moderately",
      3: "Moderately Important",
      4: "Moderately to Strongly",
      5: "Strongly Important",
      6: "Strongly to Very Strongly",
      7: "Very Strongly Important",
      8: "Very Strongly to Extremely",
      9: "Extremely Important"
    };

    return "$side is ${labels[score]} ($score)";
  }
}
