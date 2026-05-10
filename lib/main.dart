import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/users_list_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.instance.loadToken();
  runApp(const MbaApp());
}

class MbaApp extends StatelessWidget {
  const MbaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Acesso',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ApiService.instance.isLoggedIn
          ? const UsersListScreen()
          : const LoginScreen(),
    );
  }
}
