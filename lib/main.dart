import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/user/user_home_page.dart';
import 'screens/admin/admin_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://jktmgfempuyzddilikul.supabase.co',
      anonKey: 'sb_publishable_hrCQ2V16ygKE9B7DLVdNdw_xjRBnTJc',
    );
  } catch (e) {
    debugPrint("Supabase başlatma hatası: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Helal Gıda Projesi',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
      ),
      home: Supabase.instance.client.auth.currentSession != null
          ? const UserHomePage()
          : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/user': (context) => const UserHomePage(),
      },
    );
  }
}