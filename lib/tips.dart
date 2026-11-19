import 'package:material_ui/material_ui.dart';

import 'ride_result.dart';
import 'scoot_ui.dart';

class RideRecommendations extends StatelessWidget {
  const RideRecommendations({
    super.key,
    required this.evaluation,
    required this.onContinue,
  });

  final RideEvaluation evaluation;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final readinessAdvice = evaluation.readinessAdvice;
    final recommendations = [
      if (readinessAdvice.isEmpty) ...[
        'Отдохните перед поездкой, если чувствуете усталость.',
        'После употребления алкоголя выберите другой способ добраться.',
      ] else
        ...readinessAdvice,
      if (!evaluation.passedTraffic)
        'Перед поездкой разберите ошибки по ПДД и повторите проверку.',
      'Уступайте пешеходам и спешивайтесь на пешеходных переходах.',
    ];

    return ScootCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 132,
              height: 100,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(56),
              ),
              child: Icon(
                Icons.lightbulb_rounded,
                size: 60,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            container: true,
            headingLevel: 2,
            child: Text(
              'Рекомендации для вас',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  for (final (index, recommendation) in recommendations.indexed)
                    Padding(
                      padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            index < readinessAdvice.length
                                ? Icons.info_outline_rounded
                                : Icons.check_circle_rounded,
                            size: 20,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              recommendation,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onContinue,
            style: FilledButton.styleFrom(shape: const StadiumBorder()),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }
}
