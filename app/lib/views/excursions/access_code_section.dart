import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/excursions/access_code_controller.dart';
import '../../core/access_code.dart';
import '../../repositories/excursion_repository.dart';

class AccessCodeSection extends StatefulWidget {
  const AccessCodeSection({super.key, required this.excursionId});

  final String excursionId;

  @override
  State<AccessCodeSection> createState() => _AccessCodeSectionState();
}

class _AccessCodeSectionState extends State<AccessCodeSection> {
  late final AccessCodeController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AccessCodeController(ExcursionRepository(), widget.excursionId);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _confirm(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _copy(String code) async {
    await Clipboard.setData(ClipboardData(text: formatAccessCode(code)));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Código copiado')));
  }

  Future<void> _regenerate() async {
    final ok = await _confirm(
      'Generar un código nuevo',
      'El código anterior dejará de funcionar. '
          'Quienes ya se han unido seguirán en la excursión.',
    );
    if (ok) await _controller.generate();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (!_controller.loaded) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final code = _controller.code;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_controller.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _controller.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (code == null) ...[
              const Text(
                'Genera un código para que otras personas puedan unirse '
                    'a esta excursión.',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _controller.isLoading ? null : _controller.generate,
                icon: const Icon(Icons.vpn_key),
                label: const Text('Generar código'),
              ),
            ] else ...[
              SelectableText(
                formatAccessCode(code),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text('Compártelo con quien quieras que se una.'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => _copy(code),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar'),
                  ),
                  TextButton(
                    onPressed: _controller.isLoading ? null : _regenerate,
                    child: const Text('Generar nuevo'),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}