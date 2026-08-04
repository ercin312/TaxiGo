import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../admin_theme.dart';
import '../api/admin_api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.api,
    required this.onSuccess,
  });

  final AdminApi api;
  final VoidCallback onSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _base;
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _base = TextEditingController(text: widget.api.baseUrl);
    _email = TextEditingController(text: 'admin@taxigo.app');
    _password = TextEditingController(text: 'password');
  }

  @override
  void dispose() {
    _base.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.api.login(
        email: _email.text.trim(),
        password: _password.text,
        apiBase: _base.text.trim(),
      );
      widget.onSuccess();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF14161D), Color(0xFF2A2F3D), Color(0xFF1A1D26)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'TaxiGo',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                    ),
                    Text(
                      'Windows Admin',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AdminTheme.muted,
                          ),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: _base,
                      enabled: !_busy,
                      decoration: const InputDecoration(
                        labelText: 'API adresi',
                        hintText: 'http://127.0.0.1:8000/api/v1',
                        prefixIcon: Icon(Icons.dns_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _email,
                      enabled: !_busy,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _password,
                      enabled: !_busy,
                      obscureText: true,
                      onSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: Text(_busy ? 'Giriş yapılıyor…' : 'Giriş yap'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Demo: admin@taxigo.app / password',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AdminTheme.muted,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(
                          const ClipboardData(text: 'admin@taxigo.app'),
                        );
                      },
                      child: const Text('E-postayı kopyala'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
