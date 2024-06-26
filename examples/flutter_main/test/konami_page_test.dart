// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:example/konami/konami.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocktail/mocktail.dart';
import 'package:state_beacon/state_beacon.dart';

class MockKonamiController extends Mock implements KonamiController {}

void main() {
  final konamiCtrl = MockKonamiController();
  // BeaconScheduler.setScheduler(flutterScheduler);

  testWidgets('Konami Page Test', (WidgetTester tester) async {
    final keys = Beacon.lazyThrottled<String>();
    final last10 = keys.buffer(10);

    when(() => konamiCtrl.keys).thenReturn(keys);
    when(() => konamiCtrl.last10).thenReturn(last10);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiteRefScope(
            overrides: {
              konamiControllerRef.overrideWith((_) => konamiCtrl),
            },
            child: const KonamiPage(),
          ),
        ),
      ),
    );

    expect(find.text('start typing...'), findsOneWidget);

    keys.set('A');
    BeaconScheduler.flush();
    keys.set('B');
    BeaconScheduler.flush();
    keys.set('C');
    BeaconScheduler.flush();

    await tester.pump();

    expect(find.text('C (3)'), findsOneWidget);

    // simulate typing the wrong codes
    keys.set('D');
    BeaconScheduler.flush();
    keys.set('E');
    BeaconScheduler.flush();
    keys.set('F');
    BeaconScheduler.flush();
    keys.set('G');
    BeaconScheduler.flush();
    keys.set('H');
    BeaconScheduler.flush();
    keys.set('I');
    BeaconScheduler.flush();
    keys.set('J');
    BeaconScheduler.flush();

    await tester.pumpAndSettle();

    expect(find.text('Keep trying!'), findsOneWidget);

    expect(find.text('start typing...'), findsOneWidget);

    // simulate typing the correct codes
    for (var k in konamiCodes) {
      keys.set(k, force: true);
      BeaconScheduler.flush();
    }

    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    expect(find.text('KONAMI! You won!'), findsOneWidget);

    final closeBtn = find.byKey(const ValueKey('close'));

    await tester.tap(closeBtn);

    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);

    expect(find.text('start typing...'), findsOneWidget);
  });
}
