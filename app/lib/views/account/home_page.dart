import 'package:flutter/material.dart';
import '../../controllers/account/home_controller.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/profile_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = HomeController(AuthRepository(), ProfileRepository());

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _controller.signOut,
          ),
        ],
      ),
      body: Center(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hola, ${_controller.name ?? ''}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(_controller.email ?? ''),
              if (_controller.error != null) Text(_controller.error!),
            ],
          ),
        ),
      ),
    );
  }
}