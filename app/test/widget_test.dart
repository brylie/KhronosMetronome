// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ae_khronos/main.dart';

void main() {
  testWidgets('Test sound enable and disable', (WidgetTester tester) async {
    // ignore: prefer_const_constructors
    await tester.pumpWidget(AeMetronome());

    // Get widget state for validation
    final MetronomePageState aeMetronomeState =
        tester.state(find.byType(MetronomePage));

    // Widget should start with sound disabled
    expect(aeMetronomeState.soundEnabled, false);

    // press play
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    // After pressing play, sound should be enabled
    expect(aeMetronomeState.soundEnabled, true);

    // press stop
    await tester.tap(find.byIcon(Icons.stop));
    await tester.pump();

    // After pressing stop, sound should be disabled
    expect(aeMetronomeState.soundEnabled, false);
  });
}
