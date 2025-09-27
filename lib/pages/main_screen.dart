import 'package:flutter/material.dart';
import 'home_page.dart';
import 'alerts_page.dart';
import 'settings_page.dart';

// MainScreen será um StatefulWidget, pois precisa gerenciar o estado
// do item de navegação selecionado no momento.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Variável de estado para rastrear o índice da aba atualmente selecionada.
  int _selectedIndex = 0;

  // Uma lista contendo as telas que queremos exibir. A ordem é importante
  // e corresponde ao índice dos itens na barra de navegação.
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(), // Índice 0
    AlertsPage(), // Índice 1
    SettingsPage(), // Índice 2
  ];

  // Função chamada quando o usuário toca em um item da barra de navegação.
  void _onItemTapped(int index) {
    // setState atualiza nosso estado e reconstrói a UI com o novo índice.
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O corpo do Scaffold agora exibe o widget da nossa lista `_widgetOptions`
      // com base no `_selectedIndex` atual.
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      // Aqui definimos a barra de navegação inferior.
      bottomNavigationBar: BottomNavigationBar(
        // 'items' é a lista de "botões" da barra.
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Pets'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
        currentIndex: _selectedIndex, // Destaca o item atualmente selecionado.
        selectedItemColor: Theme.of(
          context,
        ).colorScheme.primary, // Cor do ícone e texto selecionados.
        onTap: _onItemTapped, // Função a ser chamada quando um item é tocado.
      ),
    );
  }
}
// O MainScreen é o ponto de entrada para a navegação principal do aplicativo.
// Ele permite que o usuário navegue entre as páginas de Pets, Alertas e Configurações
// usando uma barra de navegação inferior. Cada página é representada por um widget
// separado, e o estado do índice selecionado é gerenciado pelo MainScreen.
// O uso de IndexedStack permite que as páginas sejam mantidas em memória,
// evitando a necessidade de reconstruí-las ao navegar entre elas.
// Isso melhora a performance e a experiência do usuário, especialmente em aplicativos
// com várias páginas que não precisam ser recriadas toda vez que são acessadas.