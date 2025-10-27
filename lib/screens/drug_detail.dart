import 'package:flutter/material.dart';
import '../theme.dart';

class DrugDetail extends StatelessWidget {
  const DrugDetail({super.key});

  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: AppTextStyles.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '약품 상세 정보',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('제품명', '예시 아세트아미노펜 500mg'),
              _section('제약사', '예시제약'),
              _section('효능', '발열 및 통증 완화'),
              _section('용법', '성인 1회 1정, 1일 3회'),
              _section('주의사항', '과량 복용 금지, 간 질환 주의'),
            ],
          ),
        ),
      ),
    );
  }
}
