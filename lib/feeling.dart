class ReadinessOption {
  const ReadinessOption(this.label, {this.advice});

  final String label;
  final String? advice;
}

class ReadinessQuestion {
  const ReadinessQuestion(this.prompt, this.options);

  final String prompt;
  final List<ReadinessOption> options;
}

const readinessQuestions = [
  ReadinessQuestion('Как вы себя чувствуете?', [
    ReadinessOption('Отлично'),
    ReadinessOption('Нормально'),
    ReadinessOption(
      'Устал(а) или хочется спать',
      advice: 'Отдохните и вернитесь к проверке, когда пройдёт усталость.',
    ),
    ReadinessOption(
      'Плохо себя чувствую',
      advice: 'При плохом самочувствии выберите другой способ добраться.',
    ),
  ]),
  ReadinessQuestion('Употребляли ли вы недавно алкоголь?', [
    ReadinessOption('Нет'),
    ReadinessOption(
      'Да',
      advice:
          'Вы указали недавнее употребление алкоголя. '
          'Откажитесь от поездки на самокате и выберите другой способ добраться.',
    ),
    ReadinessOption(
      'Не уверен(а)',
      advice: 'Если вы сомневаетесь насчёт алкоголя, отложите поездку.',
    ),
  ]),
  ReadinessQuestion(
    'Принимали ли вы недавно лекарства или другие вещества, которые могут '
    'вызвать сонливость или замедлить реакцию?',
    [
      ReadinessOption('Нет'),
      ReadinessOption(
        'Да',
        advice:
            'Препараты и другие вещества могут влиять на реакцию. '
            'Отложите поездку и проверьте указания к препарату, если его принимали.',
      ),
      ReadinessOption(
        'Не уверен(а)',
        advice:
            'Если влияние препарата или другого вещества на реакцию '
            'неясно, отложите поездку.',
      ),
    ],
  ),
  ReadinessQuestion('Легко ли вам сейчас сосредоточиться на дороге?', [
    ReadinessOption('Да'),
    ReadinessOption(
      'Нет, трудно сосредоточиться',
      advice:
          'Отложите поездку, пока вам трудно удерживать внимание на дороге.',
    ),
    ReadinessOption(
      'Не уверен(а)',
      advice:
          'Если вы сомневаетесь, что сможете сосредоточиться, '
          'отложите поездку.',
    ),
  ]),
];
