// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/pet_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        // CORREÇÃO: Removemos o 'const' daqui
        children: [
          const ListTile(
            leading: Icon(Icons.person),
            title: Text('Perfil do Usuário'),
            subtitle: Text('Editar informações da conta'),
          ),
          const ListTile(
            leading: Icon(Icons.notifications_active),
            title: Text('Notificações'),
            subtitle: Text('Gerenciar preferências de alerta'),
          ),
          const ListTile(
            leading: Icon(Icons.help),
            title: Text('Ajuda e Suporte'),
            subtitle: Text('Obter ajuda sobre o aplicativo'),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Sobre'),
            subtitle: Text('Informações sobre o aplicativo'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () {
              // Limpa os dados do provider antes de deslogar
              Provider.of<PetProvider>(context, listen: false).clearData();

              // Chama o serviço de autenticação para deslogar
              Provider.of<AuthService>(context, listen: false).signOut();
            },
          ),
        ],
      ),
    );
  }
}
