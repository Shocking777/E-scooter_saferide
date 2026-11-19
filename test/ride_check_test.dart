import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saferide/main.dart';
import 'package:saferide/traffic_questions.dart';

Future<void> tapAndSettle(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> openCheck(WidgetTester tester) async {
  await tapAndSettle(tester, find.text('Начать проверку'));
  await tapAndSettle(tester, find.text('Начать'));
}

Future<void> answer(WidgetTester tester, int option) async {
  await tapAndSettle(tester, find.byType(RadioListTile<int>).at(option));
  await tapAndSettle(tester, find.byType(FilledButton));
}

TrafficQuestion shownTrafficQuestion() => trafficQuestions.singleWhere(
  (question) => find.text(question.prompt).evaluate().isNotEmpty,
);

Future<List<TrafficQuestion>> answerTraffic(
  WidgetTester tester, {
  Set<int> mistakes = const {},
}) async {
  final shown = <TrafficQuestion>[];
  for (var index = 0; index < trafficQuestionCount; index++) {
    final question = shownTrafficQuestion();
    expect(shown, isNot(contains(question)));
    shown.add(question);
    final option = mistakes.contains(index)
        ? (question.correctOption + 1) % question.options.length
        : question.correctOption;
    await answer(tester, option);
  }
  return shown;
}

Future<void> showResult(WidgetTester tester) async {
  expect(find.text('Шаг 3 из 3'), findsOneWidget);
  expect(find.text('Рекомендации для вас'), findsOneWidget);
  expect(find.textContaining('ПДД · '), findsNothing);
  await tapAndSettle(tester, find.text('Понятно'));
  expect(find.text('Шаг 3 из 3'), findsNothing);
}

void main() {
  test('The question bank has 100 distinct questions with valid options', () {
    expect(trafficQuestions, hasLength(100));
    expect(
      trafficQuestions.map((question) => question.prompt).toSet(),
      hasLength(trafficQuestions.length),
    );
    for (final question in trafficQuestions) {
      expect(question.options.toSet(), hasLength(3));
      expect(question.correctOption, inInclusiveRange(0, 2));
      expect(question.explanation, isNotEmpty);
    }
  });

  test('An attempt draws ten distinct questions in a random order', () {
    final random = Random(42);
    final first = drawTrafficQuestions(random);
    final second = drawTrafficQuestions(random);
    expect(first, hasLength(trafficQuestionCount));
    expect(first.toSet(), hasLength(trafficQuestionCount));
    expect(second.toSet(), hasLength(trafficQuestionCount));
    expect(first.toSet(), isNot(equals(second.toSet())));
    expect(first, isNot(equals(trafficQuestions.take(trafficQuestionCount))));
    expect(drawTrafficQuestions(Random(42)), orderedEquals(first));
  });

  testWidgets('A new question requires a choice and back keeps the answer', (
    tester,
  ) async {
    await tester.pumpWidget(const ScootApp());
    await openCheck(tester);

    expect(find.text('Шаг 1 из 3'), findsOneWidget);
    expect(find.text('Проверка самочувствия'), findsOneWidget);
    final continueButton = find.byType(FilledButton);
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);
    await tester.drag(
      find.text('Как вы себя чувствуете?'),
      const Offset(-320, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('Вопрос 1 из 4'), findsOneWidget);

    await answer(tester, 1);
    expect(find.text('Употребляли ли вы недавно алкоголь?'), findsOneWidget);
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);

    await tapAndSettle(tester, find.byTooltip('Назад'));
    expect(find.text('Вопрос 1 из 4'), findsOneWidget);
    expect(
      tester.widget<RadioGroup<int>>(find.byType(RadioGroup<int>)).groupValue,
      1,
    );
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNotNull);
  });

  testWidgets('Eight correct answers pass and the mistakes can be reviewed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 680);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ScootApp());
    await tapAndSettle(tester, find.byTooltip('Включить тёмную тему'));
    await openCheck(tester);

    for (var i = 0; i < 4; i++) {
      await answer(tester, 0);
    }
    expect(find.text('Шаг 2 из 3'), findsOneWidget);
    expect(find.text('Тест по ПДД'), findsOneWidget);
    expect(find.text('Вопрос 1 из 10'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(FilledButton))).brightness,
      Brightness.dark,
    );

    final shown = await answerTraffic(tester, mistakes: {0, 3});
    expect(find.textContaining('Уступайте пешеходам'), findsOneWidget);
    await showResult(tester);
    expect(find.text('Отлично!'), findsOneWidget);
    expect(find.byIcon(Icons.emoji_events_rounded), findsWidgets);
    expect(find.text('ПДД · 8 из 10'), findsOneWidget);

    await tapAndSettle(tester, find.text('Разбор ошибок'));
    for (final index in [0, 3]) {
      final question = shown[index];
      expect(find.text(question.prompt), findsOneWidget);
      expect(find.text(question.explanation), findsOneWidget);
      expect(
        find.text(
          'Правильный ответ — ${question.options[question.correctOption]}',
        ),
        findsWidgets,
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Readiness risks override a perfect traffic score', (
    tester,
  ) async {
    await tester.pumpWidget(const ScootApp());
    await openCheck(tester);

    for (final option in [2, 1, 2, 1]) {
      await answer(tester, option);
    }
    await answerTraffic(tester);

    expect(
      find.textContaining('недавнее употребление алкоголя'),
      findsOneWidget,
    );
    expect(find.textContaining('пройдёт усталость'), findsOneWidget);
    expect(find.textContaining('влияние препарата'), findsOneWidget);
    expect(find.textContaining('удерживать внимание'), findsOneWidget);
    await showResult(tester);
    expect(find.text('Отложите поездку'), findsOneWidget);
    expect(find.text('ПДД · 10 из 10'), findsOneWidget);
    expect(find.byIcon(Icons.emoji_events_rounded), findsNothing);

    await tapAndSettle(tester, find.text('На главный экран'));
    expect(find.text('Добро пожаловать в Scoot!'), findsOneWidget);
  });

  testWidgets('Seven correct answers fail, an edit updates the score', (
    tester,
  ) async {
    await tester.pumpWidget(const ScootApp());
    await openCheck(tester);

    for (var i = 0; i < 4; i++) {
      await answer(tester, 0);
    }
    final shown = await answerTraffic(tester, mistakes: {0, 1, 9});
    expect(find.textContaining('разберите ошибки по ПДД'), findsOneWidget);
    await showResult(tester);
    expect(find.text('Повторите ПДД'), findsOneWidget);
    expect(find.text('ПДД · 7 из 10'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Шаг 3 из 3'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Вопрос 10 из 10'), findsOneWidget);
    expect(shownTrafficQuestion(), same(shown.last));
    await answer(tester, shown.last.correctOption);
    expect(find.textContaining('разберите ошибки по ПДД'), findsNothing);
    await showResult(tester);
    expect(find.text('Отлично!'), findsOneWidget);
    expect(find.text('ПДД · 8 из 10'), findsOneWidget);

    await tapAndSettle(tester, find.text('Пройти заново'));
    expect(find.text('Вопрос 1 из 4'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(find.text('ПДД · 8 из 10'), findsNothing);

    for (var i = 0; i < 4; i++) {
      await answer(tester, 0);
    }
    final nextAttempt = await answerTraffic(tester);
    expect(nextAttempt.toSet(), isNot(equals(shown.toSet())));
    await showResult(tester);
    expect(find.text('ПДД · 10 из 10'), findsOneWidget);
  });
}
