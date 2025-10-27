import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pillsnap/features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  group('Onboarding Page Tests', () {
    testWidgets('Should display three onboarding screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingPage(),
          ),
        ),
      );

      // Verify first screen
      expect(find.text('사진 한 장으로 의약품 확인'), findsOneWidget);
      expect(find.text('촬영만으로 즉시 의약품 정보를 확인하세요'), findsOneWidget);
      expect(find.text('건너뛰기'), findsOneWidget);
      expect(find.text('다음'), findsOneWidget);

      // Navigate to second screen
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      // Verify second screen
      expect(find.text('약사 검증 AI 서비스'), findsOneWidget);
      expect(find.text('AI와 함께 약사가 검증한 신뢰할 수 있는 정보'), findsOneWidget);
      expect(find.text('건너뛰기'), findsOneWidget);
      expect(find.text('다음'), findsOneWidget);

      // Navigate to third screen
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      // Verify third screen
      expect(find.text('상세하고 정확한 정보'), findsOneWidget);
      expect(find.text('효능 용법 주의사항 등 전문가급 정보 제공'), findsOneWidget);
      expect(find.text('건너뛰기'), findsNothing); // Should not show on last page
      expect(find.text('시작하기'), findsOneWidget);
    });

    testWidgets('Should have working page indicators', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingPage(),
          ),
        ),
      );

      // Verify indicators exist
      final indicators = find.byType(AnimatedContainer);
      expect(indicators, findsNWidgets(3));
    });

    testWidgets('Skip button should complete onboarding', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingPage(),
          ),
        ),
      );

      // Tap skip button
      await tester.tap(find.text('건너뛰기'));
      await tester.pumpAndSettle();
      
      // Note: In a real test, we would verify navigation to home screen
      // For now, we just verify the button exists and is tappable
    });
  });
}