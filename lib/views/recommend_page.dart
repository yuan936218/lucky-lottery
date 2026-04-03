import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/lottery_controller.dart';
import '../models/lottery_model.dart';

class RecommendPage extends StatelessWidget {
  const RecommendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('智能推荐'),
        centerTitle: true,
      ),
      body: Consumer<LotteryController>(
        builder: (context, controller, child) {
          return Column(
            children: [
              // 类型选择和推荐按钮
              _buildHeader(context, controller),
              
              // 推荐结果列表
              Expanded(
                child: controller.recommendations.isEmpty
                    ? _buildEmptyState()
                    : _buildRecommendationList(controller),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LotteryController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 类型切换
          Row(
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
          ),
          const SizedBox(height: 16),
          
          // 推荐按钮
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.generateRecommendation(),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('智能推荐'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.randomSelect(),
                  icon: const Icon(Icons.shuffle),
                  label: const Text('随机机选'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6B6B),
                    side: const BorderSide(color: Color(0xFFFF6B6B)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '暂无推荐记录',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '点击上方按钮获取推荐号码',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationList(LotteryController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.recommendations.length,
      itemBuilder: (context, index) {
        final rec = controller.recommendations[index];
        return _RecommendationCard(recommendation: rec);
      },
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

class _RecommendationCard extends StatelessWidget {
  final RecommendedNumber recommendation;

  const _RecommendationCard({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('MM-dd HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        recommendation.type.name,
                        style: const TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        recommendation.algorithm,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  timeFormat.format(recommendation.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 号码展示
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('红球: ', style: TextStyle(fontWeight: FontWeight.bold)),
                ...recommendation.redBalls.map(
                  (n) => _Ball(n.toString().padLeft(2, '0'), Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  recommendation.type == LotteryType.shuangseqiu ? '蓝球: ' : '后区: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ...recommendation.blueBalls.map(
                  (n) => _Ball(n.toString().padLeft(2, '0'), Colors.blue),
                ),
              ],
            ),
          ],
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
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
