// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:pet_monitor_final/pages/login_page.dart';
import 'package:pet_monitor_final/pages/main_screen.dart';
import 'package:pet_monitor_final/providers/pet_provider.dart';
import 'package:pet_monitor_final/services/auth_service.dart';
import 'package:pet_monitor_final/services/firestore_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const firebaseConfig = {
    'apiKey': "AIzaSyAR8oiNXJQ6StRQ1-1h-vzurp7zDR-tOY4",
    'authDomain': "pet-monitor-e0437.firebaseapp.com",
    'projectId': "pet-monitor-e0437",
    'storageBucket': "pet-monitor-e0437.appspot.com",
    'messagingSenderId': "903104501156",
    'appId': "1:903104501156:web:1b1d4e4ea9a8c3fdb69d31",
  };

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: firebaseConfig['apiKey']!,
      authDomain: firebaseConfig['authDomain']!,
      projectId: firebaseConfig['projectId']!,
      storageBucket: firebaseConfig['storageBucket']!,
      messagingSenderId: firebaseConfig['messagingSenderId']!,
      appId: firebaseConfig['appId']!,
    ),
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Recebeu uma mensagem com o app em primeiro plano!');
    if (message.notification != null) {
      debugPrint(
        'A notificação continha um título: ${message.notification!.title}',
      );
      debugPrint(
        'A notificação continha um corpo: ${message.notification!.body}',
      );
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PetProvider()),
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: const MeuApp(),
    ),
  );
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Monitor',
      debugShowCheckedModeBanner: false,

      // --- TEMA CLARO (LIGHT THEME) ---
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          elevation: 4,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
        ),
        // CORREÇÃO AQUI: Trocamos CardTheme por CardThemeData
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),
      ),

      // --- TEMA ESCURO (DARK THEME) ---
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
        ),
        // CORREÇÃO AQUI: Trocamos CardTheme por CardThemeData
        cardTheme: CardThemeData(
          color: Colors.grey[850],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
    );
  }
}

// O resto do seu código (AuthWrapper) permanece o mesmo.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final petProvider = Provider.of<PetProvider>(context, listen: false);
          final user = snapshot.data!;
          FirestoreService().saveUserToken(user.uid);
          petProvider.loadUserPets(user.uid);
          return const MainScreen();
        }
        return const LoginPage();
      },
    );
  }
}
