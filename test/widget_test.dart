import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:blogify_flutter/data/app_repository.dart';
import 'package:blogify_flutter/main.dart';

void main() {
  testWidgets('Заставка показывает название приложения', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppRepository.instance.init();

    await tester.pumpWidget(const InfluenceConnectApp());
    await tester.pump();

    expect(find.text('InfluenceConnect'), findsOneWidget);

    // Дать таймеру заставки сработать и завершить переход, чтобы не осталось
    // «висящих» таймеров к концу теста.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  test('Демо-база наполняется при первом запуске', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = AppRepository.instance;
    await repo.init();

    expect(repo.bloggers.isNotEmpty, true);
    expect(repo.brands.isNotEmpty, true);
    expect(repo.allCampaigns.isNotEmpty, true);
  });
}
