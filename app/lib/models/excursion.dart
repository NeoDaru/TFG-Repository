import 'excursion_role.dart';
import 'excursion_status.dart';

class Excursion {
  const Excursion({
    required this.id,
    required this.name,
    required this.startAt,
    required this.status,
    required this.role,
    this.description = '',
  });

  final String id;
  final String name;
  final DateTime startAt;
  final ExcursionStatus status;
  final ExcursionRole role;
  final String description;

  factory Excursion.fromMembership(Map<String, dynamic> row) {
    final excursion = row['excursions'] as Map<String, dynamic>;
    return Excursion(
      id: excursion['id'] as String,
      name: excursion['name'] as String,
      startAt: DateTime.parse(excursion['start_at'] as String).toLocal(),
      status: ExcursionStatus.fromCode(excursion['status'] as String),
      role: ExcursionRole.fromCode(row['role'] as String),
      description: (excursion['description'] as String?) ?? '',
    );
  }
}