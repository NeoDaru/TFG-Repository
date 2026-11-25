import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/excursions/excursion_detail_controller.dart';
import '../../core/date_format.dart';
import '../../models/excursion.dart';
import '../../models/excursion_role.dart';
import '../../repositories/excursion_repository.dart';
import 'access_code_section.dart';

class ExcursionDetailPage extends StatefulWidget {
  const ExcursionDetailPage({super.key, required this.excursionId});

  final String excursionId;

  @override
  State<ExcursionDetailPage> createState() => _ExcursionDetailPageState();
}

class _ExcursionDetailPageState extends State<ExcursionDetailPage> {
  late final ExcursionDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        ExcursionDetailController(ExcursionRepository(), widget.excursionId);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _edit(Excursion excursion) async {
    final updated = await context.push<bool>(
      '/excursions/${excursion.id}/edit',
      extra: excursion,
    );
    if (updated == true) _controller.load();
  }

  Widget _buildBody(BuildContext context, Excursion? excursion) {
    if (excursion == null) {
      if (_controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _controller.error ?? 'No se pudo cargar la excursión.',
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: _controller.load,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.load,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                excursion.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text(excursion.status.label)),
                  Chip(label: Text(excursion.role.label)),
                ],
              ),
              const SizedBox(height: 16),
              _InfoSection(
                title: 'Fecha y hora',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      icon: Icons.calendar_today,
                      text: MaterialLocalizations.of(context)
                          .formatFullDate(excursion.startAt),
                    ),
                    _InfoRow(
                      icon: Icons.access_time,
                      text: formatTime(excursion.startAt),
                    ),
                  ],
                ),
              ),
              _InfoSection(
                title: 'Descripción',
                child: Text(
                  excursion.description.isEmpty
                      ? 'Esta excursión no tiene descripción.'
                      : excursion.description,
                ),
              ),
              if (excursion.role == ExcursionRole.coordinator)
                _InfoSection(
                  title: 'Código de acceso',
                  child: AccessCodeSection(excursionId: excursion.id),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final excursion = _controller.excursion;
        final canEdit = excursion != null &&
            excursion.role == ExcursionRole.coordinator &&
            excursion.status.allowsEditing;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalle de la excursión'),
            actions: [
              if (canEdit)
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar excursión',
                  onPressed: () => _edit(excursion),
                ),
            ],
          ),
          body: _buildBody(context, excursion),
        );
      },
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}