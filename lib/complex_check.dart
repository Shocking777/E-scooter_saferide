import 'package:material_ui/material_ui.dart';

import 'ride_check.dart';
import 'scoot_ui.dart';
import 'traffic_questions.dart';

class ComprehensiveCheckPage extends StatelessWidget {
  const ComprehensiveCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScootScaffold(
      child: ScootCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: const Icon(Icons.assignment_outlined, size: 42),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Комплексная проверка',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Оцените самочувствие, пройдите тест по правилам для '
              'электросамокатов и посмотрите рекомендации перед поездкой.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Для зачёта по ПДД нужно набрать $trafficPassScore из '
              '$trafficQuestionCount. Если ответы укажут на риск, '
              'Scoot порекомендует отложить поездку независимо от балла.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const RideCheckPage()),
              ),
              child: const Text('Начать'),
            ),
          ],
        ),
      ),
    );
  }
}
