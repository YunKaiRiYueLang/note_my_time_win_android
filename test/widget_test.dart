import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('renders the time log page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('时间记录'), findsOneWidget);
    expect(find.text('起始时间：'), findsOneWidget);
    expect(find.text('终止时间：'), findsOneWidget);
    expect(find.byIcon(Icons.history), findsOneWidget);
  });

  testWidgets('uses pickers on narrow screens', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MyApp());

    expect(find.byIcon(Icons.calendar_month), findsNWidgets(2));
    expect(find.text('年'), findsNothing);
  });
}
