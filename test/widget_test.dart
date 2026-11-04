import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_academic_assistant/main.dart';
import 'package:student_academic_assistant/state/app_state.dart';

void main() {
  testWidgets('Dashboard navigates to tasks and saves a task', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final appState = AppState();
    await appState.load();
    await tester.pumpWidget(StudentAcademicAssistantApp(appState: appState));

    expect(find.text('Student Academic Assistant'), findsOneWidget);
    expect(find.text('Welcome back!'), findsOneWidget);

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.text('No tasks yet'), findsOneWidget);

    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Read chapter one',
    );
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(1), 'Take notes');
    await tester.pump();
    await tester.tap(find.text('Save task'));
    await tester.pumpAndSettle();

    expect(appState.tasks, hasLength(1));
    expect(appState.tasks.single.title, 'Read chapter one');
    expect(find.text('Read chapter one'), findsOneWidget);
    expect(find.text('Take notes'), findsOneWidget);
  });
}
