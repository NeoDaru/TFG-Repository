import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/account/home_controller.dart';
import '../../controllers/excursions/excursion_list_controller.dart';
import '../../controllers/session_controller.dart';
import '../../core/date_format.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/excursion_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _home = HomeController(AuthRepository(), sessionController);
  final _list = ExcursionListController(ExcursionRepository());

  @override
  void initState() {
    super.initState();
    _home.refresh();
    _list.load();
  }

  @override
  void dispose() {
    _home.dispose();
    _list.dispose();
    super.dispose();
  }

  Future<void> _createExcursion() async {
    final created = await context.push<bool>('/excursions/new');
    if (created == true) _list.load();
  }

  Future<void> _joinExcursion() async {
    final excursionId = await context.push<String>('/excursions/join');
    if (excursionId == null) return;
    _list.load();
    if (mounted) _openExcursion(excursionId);
  }

  Future<void> _openExcursion(String id) async {
    await context.push('/excursions/$id');
    _list.load();
  }

  Future<void> _showAddMenu() async {
    final option = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Crear una excursión'),
              onTap: () => Navigator.pop(context, 'create'),
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Unirme con un código'),
              onTap: () => Navigator.pop(context, 'join'),
            ),
          ],
        ),
      ),
    );
    if (option == 'create') await _createExcursion();
    if (option == 'join') await _joinExcursion();
  }

  Widget _buildList() {
    if (_list.isLoading && _list.excursions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_list.error != null && _list.excursions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_list.error!),
            TextButton(onPressed: _list.load, child: const Text('Reintentar')),
          ],
        ),
      );
    }
    if (_list.excursions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Todavía no perteneces a ninguna excursión.\n'
                'Crea una o únete con un código usando el botón de abajo.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _list.load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
        itemCount: _list.excursions.length,
        itemBuilder: (context, index) {
          final excursion = _list.excursions[index];
          return Card(
            child: ListTile(
              onTap: () => _openExcursion(excursion.id),
              title: Text(excursion.name),
              subtitle: Text(
                '${formatDateTime(excursion.startAt)}\n${excursion.role.label}',
              ),
              isThreeLine: true,
              trailing: Chip(
                label: Text(excursion.status.label),
                visualDensity: VisualDensity.compact,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis excursiones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Mi cuenta',
            onPressed: () => context.push('/account'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _home.signOut,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMenu,
        icon: const Icon(Icons.add),
        label: const Text('Añadir'),
      ),
      body: Column(
        children: [
          ListenableBuilder(
            listenable: _home,
            builder: (context, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hola, ${_home.name}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: _list,
              builder: (context, _) => _buildList(),
            ),
          ),
        ],
      ),
    );
  }
}