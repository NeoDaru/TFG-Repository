enum ExcursionStatus {
  planned('PLANNED', 'Planificada'),
  inProgress('IN_PROGRESS', 'En curso'),
  finished('FINISHED', 'Finalizada'),
  cancelled('CANCELLED', 'Cancelada');

  const ExcursionStatus(this.code, this.label);
  final String code;
  final String label;

  bool get allowsEditing => this == ExcursionStatus.planned || this == ExcursionStatus.inProgress;

  static ExcursionStatus fromCode(String code) => values.firstWhere(
        (s) => s.code == code,
    orElse: () => ExcursionStatus.planned,
  );
}