import 'package:flutter/material.dart';
import '../../controllers/account/account_controller.dart';
import '../../controllers/session_controller.dart';
import '../../core/validators.dart';
import '../../models/form_status.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/profile_repository.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _controller = AccountController(AuthRepository(), ProfileRepository(), sessionController);

  final _nameKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _emailRepeat = TextEditingController();
  final _emailPassword = TextEditingController();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.load().then((_) {
      if (mounted) _name.text = _controller.name;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _name.dispose();
    _email.dispose();
    _emailRepeat.dispose();
    _emailPassword.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    if (!_nameKey.currentState!.validate()) return;
    await _controller.updateName(_name.text);
  }

  Future<void> _saveEmail() async {
    if (!_emailKey.currentState!.validate()) return;
    final ok = await _controller.updateEmail(_email.text, _emailPassword.text);
    if (ok) _emailKey.currentState?.reset();
  }

  Future<void> _savePassword() async {
    if (!_passwordKey.currentState!.validate()) return;
    final ok = await _controller.updatePassword(
      _currentPassword.text,
      _newPassword.text,
    );
    if (ok) _passwordKey.currentState?.reset();
  }

  Widget _section(String title, Widget child) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _status(FormStatus status) {
    if (status.error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          status.error!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }
    if (status.success != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          status.success!,
          style: TextStyle(color: Colors.green.shade700),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _button(String label, FormStatus status, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: FilledButton(
        onPressed: status.isLoading ? null : onPressed,
        child: status.isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi cuenta')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _section(
                  'Nombre',
                  Form(
                    key: _nameKey,
                    child: Column(children: [
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        textCapitalization: TextCapitalization.words,
                        validator: Validators.name,
                      ),
                      _status(_controller.nameStatus),
                      _button(
                          'Guardar nombre', _controller.nameStatus, _saveName),
                    ]),
                  ),
                ),

                _section(
                  'Correo electrónico',
                  Form(
                    key: _emailKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Correo actual: ${_controller.email ?? ''}'),
                        TextFormField(
                          controller: _email,
                          decoration:
                          const InputDecoration(labelText: 'Nuevo correo'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final basic = Validators.email(value);
                            if (basic != null) return basic;
                            if (value!.trim().toLowerCase() ==
                                _controller.email?.toLowerCase()) {
                              return 'Ese ya es tu correo actual';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _emailPassword,
                          decoration: const InputDecoration(
                              labelText: 'Contraseña actual'),
                          obscureText: true,
                          validator: Validators.requiredPassword,
                        ),
                        _status(_controller.emailStatus),
                        _button('Cambiar correo', _controller.emailStatus,
                            _saveEmail),
                      ],
                    ),
                  ),
                ),

                _section(
                  'Contraseña',
                  Form(
                    key: _passwordKey,
                    child: Column(children: [
                      TextFormField(
                        controller: _currentPassword,
                        decoration: const InputDecoration(
                            labelText: 'Contraseña actual'),
                        obscureText: true,
                        validator: Validators.requiredPassword,
                      ),
                      TextFormField(
                        controller: _newPassword,
                        decoration: const InputDecoration(
                          labelText: 'Nueva contraseña',
                          helperText: 'Mínimo 8 caracteres',
                        ),
                        obscureText: true,
                        validator: Validators.newPassword,
                      ),
                      TextFormField(
                        controller: _confirmPassword,
                        decoration: const InputDecoration(
                            labelText: 'Repite la nueva contraseña'),
                        obscureText: true,
                        validator: (value) => value == _newPassword.text
                            ? null
                            : 'Las contraseñas no coinciden',
                      ),
                      _status(_controller.passwordStatus),
                      _button('Cambiar contraseña',
                          _controller.passwordStatus, _savePassword),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}