import 'dart:math';

import 'package:material_ui/material_ui.dart';

import 'feeling.dart';
import 'ride_result.dart';
import 'scoot_ui.dart';
import 'tips.dart';
import 'traffic_questions.dart';

class RideCheckPage extends StatefulWidget {
  const RideCheckPage({super.key});

  @override
  State<RideCheckPage> createState() => _RideCheckPageState();
}

class _RideCheckPageState extends State<RideCheckPage> {
  final _random = Random();
  late var _trafficQuestions = drawTrafficQuestions(_random);
  final _answers = List<int?>.filled(
    readinessQuestions.length + trafficQuestionCount,
    null,
  );
  int _step = 0;

  void _restart() {
    setState(() {
      _trafficQuestions = drawTrafficQuestions(_random);
      _answers.fillRange(0, _answers.length, null);
      _step = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final step = _step;
    final readinessCount = readinessQuestions.length;

    final Widget content;
    if (step >= _answers.length) {
      final evaluation = RideEvaluation(
        readinessAnswers: _answers.sublist(0, readinessCount).cast<int>(),
        attemptQuestions: _trafficQuestions,
        trafficAnswers: _answers.sublist(readinessCount).cast<int>(),
      );
      content = step == _answers.length
          ? _CheckStage(
              number: 3,
              child: RideRecommendations(
                evaluation: evaluation,
                onContinue: () => setState(() => _step = step + 1),
              ),
            )
          : RideCheckResult(
              evaluation: evaluation,
              onRestart: _restart,
              onHome: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
            );
    } else {
      final isReadiness = step < readinessCount;
      final index = isReadiness ? step : step - readinessCount;
      final readiness = isReadiness ? readinessQuestions[index] : null;
      final traffic = isReadiness ? null : _trafficQuestions[index];
      final options =
          readiness?.options.map((option) => option.label).toList() ??
          traffic!.options;
      final selected = _answers[step];
      final nextLabel = switch (step + 1) {
        final next when next == readinessCount => 'К тесту ПДД',
        final next when next == _answers.length => 'К рекомендациям',
        _ => 'Продолжить',
      };

      content = _CheckStage(
        number: isReadiness ? 1 : 2,
        child: _QuestionCard(
          section: isReadiness ? 'Проверка самочувствия' : 'Тест по ПДД',
          number: index + 1,
          count: isReadiness ? readinessCount : _trafficQuestions.length,
          prompt: readiness?.prompt ?? traffic!.prompt,
          options: options,
          selected: selected,
          onSelect: (option) => setState(() => _answers[step] = option),
          nextLabel: nextLabel,
          onNext: selected == null
              ? null
              : () => setState(() => _step = step + 1),
        ),
      );
    }

    return PopScope<void>(
      canPop: step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step > 0) {
          setState(() => _step--);
        }
      },
      child: ScootScaffold(scrollKey: ValueKey(step), child: content),
    );
  }
}

class _CheckStage extends StatelessWidget {
  const _CheckStage({required this.number, required this.child});

  final int number;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Row(
            children: [
              Expanded(
                child: ExcludeSemantics(
                  child: LinearProgressIndicator(
                    value: number / 3,
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Шаг $number из 3',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.section,
    required this.number,
    required this.count,
    required this.prompt,
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.nextLabel,
    required this.onNext,
  });

  final String section;
  final int number;
  final int count;
  final String prompt;
  final List<String> options;
  final int? selected;
  final ValueChanged<int?> onSelect;
  final String nextLabel;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ScootCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                section,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Вопрос $number из $count',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Semantics(
            container: true,
            headingLevel: 2,
            child: Text(
              prompt,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          RadioGroup<int>(
            groupValue: selected,
            onChanged: onSelect,
            child: Column(
              children: [
                for (final (index, option) in options.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RadioListTile<int>(
                      value: index,
                      selected: selected == index,
                      activeColor: colors.primary,
                      selectedTileColor: colors.primaryContainer,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: selected == index
                              ? colors.primary
                              : colors.outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(option),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          FilledButton(onPressed: onNext, child: Text(nextLabel)),
        ],
      ),
    );
  }
}
