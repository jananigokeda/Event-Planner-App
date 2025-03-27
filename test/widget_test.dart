// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:cst2335_final/database.dart';
import 'package:cst2335_final/expense_tracker_page.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cst2335_final/main.dart';


    void main() {
      testWidgets('Counter increments smoke test', (WidgetTester tester) async {
        // Initialize the database before passing it to MyApp.
        final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();


        await tester.pumpWidget(MyApp(database:database));
    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
