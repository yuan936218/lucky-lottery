import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/lottery_model.dart';
import '../services/lottery_service.dart';

class LotteryController extends ChangeNotifier {
  final LotteryService _service = LotteryService();
  
  LotteryType _currentType = LotteryType.shuangseqiu;
  List<LotteryNumber> _historyList = [];
  List<NumberStats> _redStats = [];
  List<NumberStats> _blueStats = [];
  List<RecommendedNumber> _recommendations = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  LotteryType get currentType => _currentType;
  List<LotteryNumber> get historyList => _historyList;
  List<NumberStats> get redStats => _redStats;
  List<NumberStats> get blueStats => _blueStats;
  List<RecommendedNumber> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 切换彩票类型
  void switchType(LotteryType type) {
    _currentType = type;
    notifyListeners();
    loadHistory();
  }

  /// 加载历史数据
  Future<void> loadHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _historyList = await _service.getHistory(_currentType);
      _calculateStats();
      _error = null;
    } catch (e) {
      _error = e.toString();
      // 使用模拟数据
      _historyList = _generateMockData();
      _calculateStats();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 计算号码统计
  void _calculateStats() {
    final maxNumber = _currentType == LotteryType.shuangseqiu ? 33 : 35;
    final blueMax = _currentType == LotteryType.shuangseqiu ? 16 : 12;
    
    // 初始化统计数据
    _redStats = List.generate(maxNumber, (i) {
      final num = i + 1;
      final appearCount = _historyList.fold<int>(0, (sum, item) {
        return sum + (item.redBalls.contains(num) ? 1 : 0);
      });
      final missCount = _calculateMissCount(num, true);
      final rate = _historyList.isEmpty ? 0.0 : appearCount / _historyList.length;
      return NumberStats(
        number: num,
        appearCount: appearCount,
        missCount: missCount,
        appearRate: rate,
      );
    });

    _blueStats = List.generate(blueMax, (i) {
      final num = i + 1;
      final appearCount = _historyList.fold<int>(0, (sum, item) {
        return sum + (item.blueBalls.contains(num) ? 1 : 0);
      });
      final missCount = _calculateMissCount(num, false);
      final rate = _historyList.isEmpty ? 0.0 : appearCount / _historyList.length;
      return NumberStats(
        number: num,
        appearCount: appearCount,
        missCount: missCount,
        appearRate: rate,
      );
    });
  }

  /// 计算遗漏值
  int _calculateMissCount(int number, bool isRed) {
    for (int i = 0; i < _historyList.length; i++) {
      final item = _historyList[i];
      final balls = isRed ? item.redBalls : item.blueBalls;
      if (balls.contains(number)) {
        return i;
      }
    }
    return _historyList.length;
  }

  /// 生成推荐号码
  void generateRecommendation() {
    final random = Random();
    List<int> redBalls;
    List<int> blueBalls;

    if (_currentType == LotteryType.shuangseqiu) {
      // 双色球：33选6 + 16选1
      redBalls = _generateByColdHot(6, 33, true, random);
      blueBalls = _generateByColdHot(1, 16, false, random);
    } else {
      // 大乐透：35选5 + 12选2
      redBalls = _generateByColdHot(5, 35, true, random);
      blueBalls = _generateByColdHot(2, 12, false, random);
    }

    final recommendation = RecommendedNumber(
      type: _currentType,
      redBalls: redBalls,
      blueBalls: blueBalls,
      algorithm: '冷热分析',
      createdAt: DateTime.now(),
    );

    _recommendations.insert(0, recommendation);
    if (_recommendations.length > 20) {
      _recommendations.removeLast();
    }
    notifyListeners();
  }

  /// 基于冷热号生成
  List<int> _generateByColdHot(int count, int max, bool isRed, Random random) {
    final stats = isRed ? _redStats : _blueStats;
    final selected = <int>[];
    
    // 权重：出现频率高的号码更容易被选中，但也保留一定随机性
    final weights = stats.map((s) => (s.appearRate * 100 + 1).round()).toList();
    final totalWeight = weights.fold<int>(0, (sum, w) => sum + w);

    while (selected.length < count) {
      int r = random.nextInt(totalWeight);
      for (int i = 0; i < weights.length; i++) {
        r -= weights[i];
        if (r <= 0) {
          if (!selected.contains(i + 1)) {
            selected.add(i + 1);
          }
          break;
        }
      }
    }
    
    selected.sort();
    return selected;
  }

  /// 机选
  void randomSelect() {
    final random = Random();
    List<int> redBalls;
    List<int> blueBalls;

    if (_currentType == LotteryType.shuangseqiu) {
      redBalls = List.generate(33, (i) => i + 1)..shuffle(random);
      blueBalls = [random.nextInt(16) + 1];
    } else {
      redBalls = List.generate(35, (i) => i + 1)..shuffle(random);
      blueBalls = List.generate(12, (i) => i + 1)..shuffle(random);
    }

    final recommendation = RecommendedNumber(
      type: _currentType,
      redBalls: redBalls.sublist(0, _currentType == LotteryType.shuangseqiu ? 6 : 5),
      blueBalls: blueBalls.sublist(0, _currentType == LotteryType.shuangseqiu ? 1 : 2),
      algorithm: '机选',
      createdAt: DateTime.now(),
    );

    _recommendations.insert(0, recommendation);
    notifyListeners();
  }

  /// 模拟数据
  List<LotteryNumber> _generateMockData() {
    final random = Random(42);
    final list = <LotteryNumber>[];
    
    for (int i = 0; i < 100; i++) {
      final redCount = _currentType == LotteryType.shuangseqiu ? 6 : 5;
      final blueCount = _currentType == LotteryType.shuangseqiu ? 1 : 2;
      
      final redBalls = List.generate(33, (i) => i + 1)..shuffle(random);
      final blueBalls = List.generate(16, (i) => i + 1)..shuffle(random);
      
      list.add(LotteryNumber(
        issue: '2024${(100 - i).toString().padLeft(3, '0')}',
        date: DateTime.now().subtract(Duration(days: i)),
        redBalls: List<int>.from(redBalls.sublist(0, redCount))..sort(),
        blueBalls: List<int>.from(blueBalls.sublist(0, blueCount))..sort(),
      ));
    }
    
    return list;
  }
}
