import 'package:material_ui/material_ui.dart';

import 'feeling.dart';
import 'traffic_questions.dart';

class RideEvaluation {
  RideEvaluation({
    required List<int> readinessAnswers,
    required List<TrafficQuestion> attemptQuestions,
    required List<int> trafficAnswers,
  }) : readinessAdvice = [
         for (final (index, answer) in readinessAnswers.indexed)
           if (readinessQuestions[index].options[answer].advice
               case final String recommendation)
             recommendation,
       ],
       mistakes = [
         for (final (index, answer) in trafficAnswers.indexed)
           if (answer != attemptQuestions[index].correctOption)
             (question: attemptQuestions[index], answer: answer),
       ],
       questionCount = attemptQuestions.length;

  final List<String> readinessAdvice;
  final List<({TrafficQuestion question, int answer})> mistakes;
  final int questionCount;

  int get score => questionCount - mistakes.length;
  bool get passedTraffic => score >= trafficPassScore;
}

class RideCheckResult extends StatelessWidget {
  const RideCheckResult({
    super.key,
    required this.evaluation,
    required this.onRestart,
    required this.onHome,
  });

  final RideEvaluation evaluation;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasReadinessRisk = evaluation.readinessAdvice.isNotEmpty;
    final passed = !hasReadinessRisk && evaluation.passedTraffic;
    final (title, message, icon) = switch ((hasReadinessRisk, passed)) {
      (true, _) => (
        'Отложите поездку',
        'Учтите рекомендации по самочувствию перед следующей проверкой.',
        Icons.warning_amber_rounded,
      ),
      (false, false) => (
        'Повторите ПДД',
        'Разберите ошибки и пройдите проверку ещё раз перед поездкой.',
        Icons.menu_book_rounded,
      ),
      (false, true) => (
        'Отлично!',
        'Вы успешно прошли проверку. Желаем безопасных и приятных поездок!',
        Icons.emoji_events_rounded,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: passed
                          ? const _Celebration()
                          : CircleAvatar(
                              radius: 46,
                              backgroundColor: colors.errorContainer,
                              foregroundColor: colors.onErrorContainer,
                              child: Icon(icon, size: 46),
                            ),
                    ),
                    const SizedBox(height: 14),
                    Semantics(
                      container: true,
                      headingLevel: 2,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'ПДД · ${evaluation.score} из '
                                '${evaluation.questionCount}',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colors.onPrimaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Проходной балл — $trafficPassScore из '
                                '${evaluation.questionCount}',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: passed ? onHome : onRestart,
                      style: FilledButton.styleFrom(
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        passed ? 'На главный экран' : 'Пройти заново',
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: passed ? onRestart : onHome,
                      child: Text(
                        passed ? 'Пройти заново' : 'На главный экран',
                      ),
                    ),
                  ],
                ),
              ),
              if (passed)
                SizedBox(
                  height: 72,
                  child: CustomPaint(painter: _Cityscape(colors.primary)),
                ),
            ],
          ),
        ),
        if (evaluation.mistakes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              title: const Text('Разбор ошибок'),
              subtitle: Text(
                'Неверных ответов — ${evaluation.mistakes.length}',
              ),
              expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
              childrenPadding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              children: [
                for (final mistake in evaluation.mistakes) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    mistake.question.prompt,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ваш ответ — ${mistake.question.options[mistake.answer]}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Правильный ответ — '
                    '${mistake.question.options[mistake.question.correctOption]}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mistake.question.explanation,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Celebration extends StatelessWidget {
  const _Celebration();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 244,
        height: 148,
        child: CustomPaint(
          painter: _Confetti(Theme.of(context).colorScheme.primary),
          child: const Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment(0, 0.17),
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 118,
                  color: Color(0xFFC58C31),
                ),
              ),
              Icon(
                Icons.emoji_events_rounded,
                size: 118,
                color: Color(0xFFF5C35A),
              ),
              Align(
                alignment: Alignment(0, -0.23),
                child: Icon(
                  Icons.star_rounded,
                  size: 26,
                  color: Color(0xFFFFEEC3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Confetti extends CustomPainter {
  const _Confetti(this.accent);

  final Color accent;

  static const _pieces = [
    (0.12, 0.18, 0.30),
    (0.31, 0.07, -0.63),
    (0.48, 0.10, 0.47),
    (0.69, 0.08, -0.43),
    (0.88, 0.20, 0.49),
    (0.06, 0.41, -0.60),
    (0.94, 0.43, 0.76),
    (0.18, 0.62, 0.71),
    (0.82, 0.62, -0.77),
    (0.10, 0.82, 0.47),
    (0.29, 0.87, -0.37),
    (0.75, 0.88, 0.61),
    (0.91, 0.79, -0.49),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final (index, (x, y, angle)) in _pieces.indexed) {
      canvas.save();
      canvas.translate(size.width * x, size.height * y);
      canvas.rotate(angle);
      paint.color = index % 3 == 0
          ? const Color(0xFFF2B749)
          : accent.withValues(alpha: index.isEven ? 0.66 : 0.9);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: 5,
            height: index.isEven ? 10 : 6,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _Confetti oldDelegate) =>
      accent != oldDelegate.accent;
}

class _Cityscape extends CustomPainter {
  const _Cityscape(this.accent);

  final Color accent;

  static const _buildings = [
    (14.0, 25.0, 42.0),
    (41.0, 15.0, 28.0),
    (58.0, 24.0, 36.0),
    (85.0, 21.0, 22.0),
    (121.0, 27.0, 43.0),
    (151.0, 20.0, 29.0),
    (185.0, 19.0, 32.0),
    (207.0, 24.0, 23.0),
    (236.0, 20.0, 46.0),
    (258.0, 27.0, 57.0),
    (288.0, 20.0, 34.0),
    (315.0, 29.0, 50.0),
  ];

  static const _trees = [
    (4.0, 30.0),
    (28.0, 21.0),
    (52.0, 24.0),
    (81.0, 15.0),
    (107.0, 21.0),
    (130.0, 17.0),
    (157.0, 15.0),
    (182.0, 24.0),
    (212.0, 17.0),
    (240.0, 21.0),
    (267.0, 17.0),
    (294.0, 24.0),
    (324.0, 21.0),
    (348.0, 29.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 360, size.height / 72);
    final walls = Paint()..color = accent.withValues(alpha: 0.14);
    final windows = Paint()..color = accent.withValues(alpha: 0.12);
    for (final (x, width, height) in _buildings) {
      final top = 72 - height;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, top, width, height + 4),
          const Radius.circular(4),
        ),
        walls,
      );
      for (var y = top + 7; y < 58; y += 8) {
        for (var window = x + 5; window < x + width - 5; window += 6) {
          canvas.drawRect(Rect.fromLTWH(window, y, 2, 4), windows);
        }
      }
    }

    final greenery = Path();
    for (final (x, height) in _trees) {
      greenery.addOval(
        Rect.fromCenter(
          center: Offset(x, 75),
          width: height * 1.6,
          height: height * 2,
        ),
      );
    }
    canvas.drawPath(greenery, Paint()..color = accent.withValues(alpha: 0.27));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _Cityscape oldDelegate) =>
      accent != oldDelegate.accent;
}
