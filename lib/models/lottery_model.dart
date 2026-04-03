/// 彩票类型枚举
enum LotteryType {
  shuangseqiu('双色球', 'SSQ'),
  daletou('大乐透', 'DLT');

  final String name;
  final String code;
  const LotteryType(this.name, this.code);
}

/// 开奖号码模型
class LotteryNumber {
  final String issue; // 期号
  final DateTime date; // 开奖日期
  final List<int> redBalls; // 红球
  final List<int> blueBalls; // 蓝球

  LotteryNumber({
    required this.issue,
    required this.date,
    required this.redBalls,
    required this.blueBalls,
  });

  factory LotteryNumber.fromJson(Map<String, dynamic> json, LotteryType type) {
    List<int> redBalls = [];
    List<int> blueBalls = [];
    
    if (type == LotteryType.shuangseqiu) {
      // 双色球：红球6个 + 蓝球1个
      redBalls = List<int>.from(json['red'] ?? []);
      blueBalls = List<int>.from(json['blue'] ?? []);
    } else {
      // 大乐透：前区5个 + 后区2个
      redBalls = List<int>.from(json['front'] ?? []);
      blueBalls = List<int>.from(json['back'] ?? []);
    }
    
    return LotteryNumber(
      issue: json['issue'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      redBalls: redBalls,
      blueBalls: blueBalls,
    );
  }

  String get displayNumber {
    String red = redBalls.map((e) => e.toString().padLeft(2, '0')).join(' ');
    String blue = blueBalls.map((e) => e.toString().padLeft(2, '0')).join(' ');
    return '$red + $blue';
  }
}

/// 号码统计数据
class NumberStats {
  final int number;
  final int appearCount; // 出现次数
  final int missCount; // 遗漏次数
  final double appearRate; // 出现频率

  NumberStats({
    required this.number,
    required this.appearCount,
    required this.missCount,
    required this.appearRate,
  });
}

/// 推荐号码模型
class RecommendedNumber {
  final LotteryType type;
  final List<int> redBalls;
  final List<int> blueBalls;
  final String algorithm; // 算法名称
  final DateTime createdAt;

  RecommendedNumber({
    required this.type,
    required this.redBalls,
    required this.blueBalls,
    required this.algorithm,
    required this.createdAt,
  });

  String get displayNumber {
    String red = redBalls.map((e) => e.toString().padLeft(2, '0')).join(' ');
    String blue = blueBalls.map((e) => e.toString().padLeft(2, '0')).join(' ');
    return '$red + $blue';
  }
}
