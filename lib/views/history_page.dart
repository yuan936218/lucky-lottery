import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/lottery_controller.dart';
import '../models/lottery_model.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('开奖历史'),
        centerTitle: true,
      ),
      body: Consumer<LotteryController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.historyList.isEmpty) {
            return const Center(child: Text('暂无历史数据'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.historyList.length,
            itemBuilder: (context, index) {
              final item = controller.historyList[index];
              return _HistoryCard(item: item, type: controller.currentType);
            },
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final LotteryNumber item;
  final LotteryType type;

  const _HistoryCard({required this.item, required this.type});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.issue,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  dateFormat.format(item.date),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('红球: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: item.redBalls.map((n) => _RedBall(n.toString().padLeft(2, '0'))).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  type == LotteryType.shuangseqiu ? '蓝球: ' : '后区: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ...item.blueBalls.map((n) => _BlueBall(n.toString().padLeft(2, '0'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RedBall extends StatelessWidget {
  final String number;
  const _RedBall(this.number);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red, width: 1.5),
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}

class _BlueBall extends StatelessWidget {
  final String number;
  const _BlueBall(this.number);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue, width: 1.5),
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}
