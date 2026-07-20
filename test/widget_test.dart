import 'package:flutter_test/flutter_test.dart';

import 'package:cinesync/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CineSyncApp());

    // Ana ekranda "Keşfet" başlığının göründüğünü doğrula
    expect(find.text('Keşfet'), findsWidgets);
  });
}
