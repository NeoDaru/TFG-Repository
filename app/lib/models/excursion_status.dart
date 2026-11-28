enum ExcursionStatus {
  planned('PLANNED', 'Planificada'),
  inProgress('IN_PROGRESS', 'En curso'),
  finished('FINISHED', 'Finalizada'),
  cancelled('CANCELLED', 'Cancelada');

  const ExcursionStatus(this.code, this.label);
  final String code;
  final String label;

  bool get isActive =>
      this == ExcursionStatus.planned || this == ExcursionStatus.inProgress;

  bool get allowsEditing => isActive;

  List<ExcursionStatus> get nextStatuses {
    switch (this) {
      case ExcursionStatus.planned:
        return [ExcursionStatus.inProgress, ExcursionStatus.cancelled];
      case ExcursionStatus.inProgress:
        return [ExcursionStatus.finished];
      case ExcursionStatus.finished:
      case ExcursionStatus.cancelled:
        return [];
    }
  }

  static ExcursionStatus fromCode(String code) => values.firstWhere(
        (s) => s.code == code,
    orElse: () => ExcursionStatus.planned,
  );
}