import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/lottery_controller.dart';
import '../models/lottery_model.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  int _selectedTab = 0; // 0: 冷热分析, 1: 遗漏统计

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('走势分析'),
        centerTitle: true,
      ),
      body: Consumer<LotteryController>(
        builder: (context, controller, child) {
          return Column(
            children: [
              // Tab切换
              _buildTabBar(),
              
              // 彩票类型切换
              _buildTypeSelector(controller),
              
              // 图表内容
              Expanded(
                child: _selectedTab == 0
                    ? _buildColdHotChart(controller)
                    : _buildMissChart(controller),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? const Color(0xFFFF6B6B) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '冷热分析',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 0 ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? const Color(0xFFFF6B6B) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '遗漏统计',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 1 ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(LotteryController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text('选择球色: ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('红球'),
            selected: true,
            selectedColor: Colors.red[100],
            onSelected: (selected) {},
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('蓝球'),
            selected: false,
            selectedColor: Colors.blue[100],
            onSelected: (selected) {},
          ),
        ],
      ),
    );
  }

  Widget _buildColdHotChart(LotteryController controller) {
    final stats = controller.redStats;
    if (stats.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    // 取前33个（红球）
    final data = stats.take(33).toList();
    final maxY = data.map((s) => s.appearCount).reduce((a, b) => a > b ? a : b).toDouble() + 5;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '红球出现次数统计',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _LegendItem(color: Colors.red, label: '出现次数'),
              const SizedBox(width: 16),
              _LegendItem(color: const Color(0xFF4ECDC4), label: '出现频率'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barGroups: data.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.appearCount.toDouble(),
                        color: Colors.red,
                        width: 8,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() % 5 == 0) {
                          return Text('${value.toInt() + 1}', style: const TextStyle(fontSize: 10));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissChart(LotteryController controller) {
    final stats = controller.redStats;
    if (stats.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    final data = stats.take(33).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '红球遗漏值统计',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 33,
              itemBuilder: (context, index) {
                final stat = data[index];
                return _MissBall(number: stat.number, missCount: stat.missCount);
              },
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '数字为当前遗漏期数，数值越大表示越久未出现',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _MissBall extends StatelessWidget {
  final int number;
  final int missCount;

  const _MissBall({required this.number, required this.missCount});

  @override
  Widget build(BuildContext context) {
    // 遗漏越多，颜色越深
    final intensity = (missCount / 20).clamp(0.2, 1.0);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(intensity * 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(intensity), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number.toString().padLeft(2, '0'),
            style: TextStyle(
              color: missCount > 10 ? Colors.red : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            missCount.toString(),
            style: TextStyle(
              color: Colors.red.withOpacity(intensity),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
