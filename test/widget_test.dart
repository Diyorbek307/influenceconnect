import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:blogify_flutter/data/app_repository.dart';
import 'package:blogify_flutter/data/local_data_source.dart';
import 'package:blogify_flutter/main.dart';

void main() {
  testWidgets('Заставка показывает название приложения', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppRepository.instance.init(dataSource: LocalDataSource());

    await tester.pumpWidget(const InfluenceConnectApp());
    await tester.pump();

    expect(find.text('InfluenceConnect'), findsOneWidget);

    // Даём таймеру заставки сработать (без pumpAndSettle — на экранах
    // бесконечная анимация фона, settle не завершится).
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 400));
  });

  test('Локальная демо-база наполняется при первом запуске', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = AppRepository.instance;
    await repo.init(dataSource: LocalDataSource());

    expect(repo.bloggers.isNotEmpty, true);
    expect(repo.brands.isNotEmpty, true);
    expect(repo.allCampaigns.isNotEmpty, true);
  });
}
