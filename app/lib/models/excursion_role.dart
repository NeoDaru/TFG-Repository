enum ExcursionRole {
  coordinator('COORDINATOR', 'Coordinador'),
  participant('PARTICIPANT', 'Participante');

  const ExcursionRole(this.code, this.label);
  final String code;
  final String label;

  static ExcursionRole fromCode(String code) => values.firstWhere(
        (r) => r.code == code,
    orElse: () => ExcursionRole.participant,
  );
}