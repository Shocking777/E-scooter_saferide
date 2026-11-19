import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import 'complex_check.dart';
import 'feeling.dart';
import 'scoot_ui.dart';
import 'traffic_questions.dart';

void main() {
  runApp(const ScootApp());
}

class ScootApp extends StatefulWidget {
  const ScootApp({super.key});

  @override
  State<ScootApp> createState() => _ScootAppState();
}

class _ScootAppState extends State<ScootApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scoot',
      debugShowCheckedModeBanner: false,
      theme: scootTheme(Brightness.light),
      darkTheme: scootTheme(Brightness.dark),
      themeMode: _themeMode,
      home: WelcomeScreen(
        onThemeChanged: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onThemeChanged});

  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return ScootScaffold(
      actions: [
        IconButton(
          onPressed: () =>
              onThemeChanged(dark ? ThemeMode.light : ThemeMode.dark),
          tooltip: dark ? 'Включить светлую тему' : 'Включить тёмную тему',
          icon: Icon(
            dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
        ),
      ],
      child: ScootCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WelcomeIllustration(dark: dark),
            const SizedBox(height: 20),
            Text(
              'Добро пожаловать в Scoot!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Оцените своё состояние и проверьте знание ПДД '
              'перед поездкой на электросамокате.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.checklist_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${readinessQuestions.length} вопроса о состоянии '
                    'и $trafficQuestionCount вопросов по ПДД',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => const ComprehensiveCheckPage(),
                ),
              ),
              child: const Text('Начать проверку'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220),
        child: AspectRatio(
          aspectRatio: 1072 / 818.65033,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white,
                Colors.white,
                Colors.transparent,
              ],
              stops: [0, 0.08, 0.92, 1],
            ).createShader(bounds),
            child: SvgPicture.asset(
              'assets/svg/main.svg',
              colorMapper: dark
                  ? const _WelcomeIllustrationColors(dark: true)
                  : const _WelcomeIllustrationColors(dark: false),
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeIllustrationColors extends ColorMapper {
  const _WelcomeIllustrationColors({required this.dark});

  final bool dark;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (attributeName != 'fill') return color;
    // The exported artwork has separate white canvas and ground paths.
    if (id == 'path1' || id == 'path4') return Colors.transparent;
    if (!dark) return color;

    return switch (id) {
      // The vector wordmark includes two background-colored counters.
      'path154' ||
      'path156' ||
      'path158' ||
      'path159' ||
      'path160' => const Color(0xFFDCEFE9),
      'path155' || 'path157' => scootDarkCardColor,
      'path32' || 'path151' => color,
      'path42' || 'path62' => const Color(0xFF2D7563),
      'path43' || 'path63' || 'path65' => const Color(0xFF286050),
      'path44' => const Color(0xFF205448),
      _ => switch (color.toARGB32()) {
        0xFFFFFFFF => const Color(0xFF416159),
        0xFFD3F4F6 => const Color(0xFF33544E),
        0xFFB7EAE8 => const Color(0xFF3C5F59),
        0xFFA1E0DB => const Color(0xFF3A665F),
        0xFFDBF5F7 => const Color(0xFF2B4945),
        _ => color,
      },
    };
  }
}
