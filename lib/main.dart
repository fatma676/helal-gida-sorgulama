import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://jktmgfempuyzddilikul.supabase.co/rest/v1/',
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
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();

  bool _isLogin = true; // Giriş mi Kayıt mı kontrolü
  bool _isLoading = false;

  // Giriş ve Kayıt İşlemlerini Yöneten Fonksiyon
  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        // --- GİRİŞ YAP ---
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (response.user != null) {
          final String email = response.user!.email!;

          // Rolü çek
          final userData = await Supabase.instance.client
              .from('kullanıcı')
              .select('rol')
              .eq('email', email)
              .single();

          // Log kaydı (Hocanın şartı)
          await Supabase.instance.client.from('logs').insert({
            'islem': 'Giriş yapıldı',
            'kullanici_mail': email,
          });

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => userData['rol'] == "Admin"
                    ? const AdminHomePage()
                    : const UserHomePage(),
              ),
            );
          }
        }
      } else {
        // --- KAYIT OL ---
        final response = await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (response.user != null) {
          // Kendi kullanıcı tablona ekle
          await Supabase.instance.client.from('kullanıcı').insert({
            'ad': _adController.text.trim(),
            'soyad': _soyadController.text.trim(),
            'email': _emailController.text.trim(),
            'rol': 'user', // Varsayılan rol
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Kayıt başarılı! Şimdi giriş yapabilirsiniz.")),
            );
            setState(() => _isLogin = true);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1), // Tasarımdaki açık yeşil fon
      body: Stack(
        children: [
          // Arka plandaki yaprak tasarımı (Alt kısım)
          Positioned(
            bottom: -50,
            left: -20,
            child: Opacity(
              opacity: 0.15,
              child: Icon(Icons.eco, size: 300, color: Colors.green.shade800),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 90,
                        width: 90,
                        child: CustomPaint(
                          painter: CrescentPainter(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Helal Gıda Sorgulama",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  
                  // KAYIT MODUNDA EKSTRA KUTULAR
                  if (!_isLogin) ...[
                    _customTextField(_adController, "Ad", Icons.person_outline),
                    const SizedBox(height: 15),
                    _customTextField(_soyadController, "Soyad", Icons.person_outline),
                    const SizedBox(height: 15),
                  ],

                  _customTextField(_emailController, "E-posta", Icons.mail_outline),
                  const SizedBox(height: 15),
                  _customTextField(_passwordController, "Şifre", Icons.lock_outline, isPassword: true),
                  
                  const SizedBox(height: 35),

                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1DB954),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 3,
                          ),
                          onPressed: _handleAuth,
                          child: Text(
                            _isLogin ? "Giriş Yap" : "Kayıt Ol",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                  
                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin ? "Hesabın yok mu? Kayıt Ol" : "Zaten hesabın var mı? Giriş Yap",
                      style: const TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tasarımdaki o temiz beyaz kutular (TextField)
  Widget _customTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}

class CrescentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2E7D32);
    final outerCenter = Offset(size.width * 0.54, size.height * 0.55);
    final outerRadius = size.width * 0.38;

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawCircle(outerCenter, outerRadius, paint);

    final clearPaint = Paint()..blendMode = BlendMode.clear;
    final innerCenter = outerCenter + Offset(size.width * 0.18, -size.height * 0.12);
    final innerRadius = outerRadius * 0.8;
    canvas.drawCircle(innerCenter, innerRadius, clearPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- ANA SAYFALAR ---
class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Helal Gıda Sistemi"), actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: () => _logout(context))
      ]),
      body: const Center(child: Text("Kullanıcı Sayfası - Ürün Arama Yakında!")),
    );
  }
}

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Paneli"), backgroundColor: Colors.red.shade100, actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: () => _logout(context))
      ]),
      body: const Center(child: Text("Admin Sayfası - Veri Yönetimi Yakında!")),
    );
  }
}

void _logout(BuildContext context) async {
  await Supabase.instance.client.auth.signOut();
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
}