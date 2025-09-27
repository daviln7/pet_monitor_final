import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet_monitor_final/services/auth_service.dart';

// --- AQUI ESTÁ A CORREÇÃO DEFINITIVA DO ERRO DE DIGITAÇÃO ---
// O correto é 'package:firebase_auth', com dois-pontos, e não um ponto.
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _error = '';
  bool _isLogin = true;

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      // Agora o tipo 'User' é reconhecido e o erro desaparece.
      User? user;
      final authService = Provider.of<AuthService>(context, listen: false);

      if (_isLogin) {
        user = await authService.signInWithEmailAndPassword(
            _email.trim(), _password.trim());
      } else {
        user = await authService.registerWithEmailAndPassword(
            _email.trim(), _password.trim());
      }

      if (user == null && mounted) {
        setState(() {
          _error = 'Por favor, verifique suas credenciais.';
        });
      }
      // Se o login for bem-sucedido, o AuthWrapper tratará da navegação.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Registrar'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  key: const ValueKey('email'),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Por favor, insira um e-mail válido.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value!;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('password'),
                  validator: (value) {
                    if (value == null || value.length < 7) {
                      return 'A senha deve ter pelo menos 7 caracteres.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha'),
                ),
                const SizedBox(height: 20),
                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _error,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _trySubmit,
                  child: Text(_isLogin ? 'Entrar' : 'Criar Conta'),
                ),
                TextButton(
                  child: Text(
                      _isLogin ? 'Criar nova conta' : 'Eu já tenho uma conta'),
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _error = '';
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
