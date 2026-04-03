import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/lottery_controller.dart';
import '../models/lottery_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LotteryController>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LuckyLottery'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<LotteryController>().loadHistory();
            },
          ),
        ],
      ),
      body: Consumer<LotteryController>(
        builder: (context, controller, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 彩票类型切换
                _buildTypeSelector(controller),
                const SizedBox(height: 20),
                
                // 今日推荐
                _buildTodayRecommend(controller),
                const SizedBox(height: 20),
                
                // 最新开奖
                _buildLatestResult(controller),
                const SizedBox(height: 20),
                
                // 快捷功能
                _buildQuickActions(context, controller),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeSelector(LotteryController controller) {
    return Row(
      children: [
        Expanded(
          child: _TypeButton(
            title: '双色球',
            isSelected: controller.currentType == LotteryType.shuangseqiu,
            onTap: () => controller.switchType(LotteryType.shuangseqiu),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeButton(
            title: '大乐透',
            isSelected: controller.currentType == LotteryType.daletou,
            onTap: () => controller.switchType(LotteryType.daletou),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayRecommend(LotteryController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  '今日推荐',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (controller.recommendations.isNotEmpty)
              _buildNumberDisplay(controller.recommendations.first)
            else
              const Center(
                child: Text('点击"智能推荐"获取号码'),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.generateRecommendation(),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('智能推荐'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestResult(LotteryController controller) {
    final latest = controller.historyList.isNotEmpty ? controller.historyList.first : null;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  '最新开奖',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (latest != null) ...[
              Text(
                '期号: ${latest.issue}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              _buildNumberDisplay(latest),
            ] else if (controller.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              const Center(child: Text('暂无数据')),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberDisplay(dynamic numberObj) {
    List<int> redBalls;
    List<int> blueBalls;
    
    if (numberObj is RecommendedNumber) {
      redBalls = numberObj.redBalls;
      blueBalls = numberObj.blueBalls;
    } else if (numberObj is LotteryNumber) {
      redBalls = numberObj.redBalls;
      blueBalls = numberObj.blueBalls;
    } else {
      return const SizedBox();
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('红球: ', style: TextStyle(fontWeight: FontWeight.bold)),
            ...redBalls.map((n) => _Ball(n.toString().padLeft(2, '0'), Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              numberObj is RecommendedNumber ? '蓝球: ' : '蓝球: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ...blueBalls.map((n) => _Ball(n.toString().padLeft(2, '0'), Colors.blue)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, LotteryController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '快捷功能',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.history,
                    label: '历史走势',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.shuffle,
                    label: '随机机选',
                    onTap: () => controller.randomSelect(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.bookmark,
                    label: '我的收藏',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B6B) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _Ball extends StatelessWidget {
  final String number;
  final Color color;

  const _Ball(this.number, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFFF6B6B)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
