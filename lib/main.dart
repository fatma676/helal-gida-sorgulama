import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
      ],
      locale: const Locale('tr', 'TR'),
      debugShowCheckedModeBanner: false,
      title: 'Helal Gıda Projesi',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
      ),
      // Oturum açıksa hangi sayfaya gideceğini belirlemek için
      // AuthGate widget'ı kullanıyoruz
      home: const AuthGate(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/user': (context) => const UserHomePage(),
        '/admin': (context) => const AdminHomePage(),
      },
    );
  }
}

// Uygulama açılınca oturum varsa rolü kontrol edip doğru sayfaya yönlendirir
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      // Oturum yok → login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      });
      return;
    }

    // Oturum var → rolü kontrol et
    final email = session.user.email!;
    final userData = await Supabase.instance.client
        .from('kullanici')
        .select('rol')
        .eq('eposta', email)
        .maybeSingle();

    if (!mounted) return;

    final role =
        userData != null && userData['rol'] != null ? userData['rol'] as String : 'user';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          role == 'Admin' ? '/admin' : '/user',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Rol kontrol edilirken loading göster
    return const Scaffold(
      backgroundColor: Color(0xFFF1F8F1),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
      ),
    );
  }
}