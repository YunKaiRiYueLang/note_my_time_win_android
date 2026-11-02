import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('renders the time log page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('时间记录'), findsOneWidget);
    expect(find.text('起始时间：'), findsOneWidget);
    expect(find.text('终止时间：'), findsOneWidget);
  });
}
