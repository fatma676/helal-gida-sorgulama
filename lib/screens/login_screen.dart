import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _adController.dispose();
    _soyadController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        // --- GİRİŞ YAPMA MANTIĞI ---
        final response =
            await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (response.user != null) {
          final String email = response.user!.email!;

          final userData = await Supabase.instance.client
              .from('kullanici')
              .select('rol')
              .eq('eposta', email)
              .maybeSingle();

          await Supabase.instance.client.from('logs').insert({
            'islem': 'Giriş yapıldı',
            'kullanici_mail': email,
          });

          if (!mounted) return;

          final role = userData != null && userData['rol'] != null
              ? userData['rol'] as String
              : 'user';

          Navigator.pushReplacementNamed(
            context,
            role == 'Admin' ? '/admin' : '/user',
          );
        }
      } else {
        // --- KAYIT OLMA MANTIĞI ---
        final response = await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (response.user != null) {
          await Supabase.instance.client.from('kullanici').insert({
            'kullaniciid': response.user!.id,
            'adsoyad':
                "${_adController.text.trim()} ${_soyadController.text.trim()}",
            'eposta': _emailController.text.trim(),
            'sifre': _passwordController.text.trim(),
            'rol': 'user',
          });

          await Supabase.instance.client.from('logs').insert({
            'islem': 'Yeni Kayıt Oluşturuldu',
            'kullanici_mail': _emailController.text.trim(),
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Kayıt başarılı! Şimdi giriş yapabilirsiniz."),
                backgroundColor: Colors.green,
              ),
            );
            setState(() => _isLogin = true);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        String mesaj = "Bir hata oluştu, lütfen tekrar deneyin.";

        if (e.toString().contains("user_already_exists")) {
          mesaj = "Bu e-posta adresi zaten kayıtlı. Giriş yapmayı deneyin.";
        } else if (e.toString().contains("Invalid login credentials")) {
          mesaj = "E-posta veya şifre hatalı. Lütfen kontrol edin.";
        } else {
          mesaj = "Hata: $e";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mesaj),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      body: Stack(
        children: [
          Positioned(
            bottom: -50,
            left: -20,
            child: Opacity(
              opacity: 0.15,
              child:
                  Icon(Icons.eco, size: 300, color: Colors.green.shade800),
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
                        child: CustomPaint(painter: CrescentPainter()),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Helal Gıda Sorgulama",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  if (!_isLogin) ...[
                    _customTextField(
                        _adController, "Ad", Icons.person_outline),
                    const SizedBox(height: 15),
                    _customTextField(
                        _soyadController, "Soyad", Icons.person_outline),
                    const SizedBox(height: 15),
                  ],
                  _customTextField(
                      _emailController, "E-posta", Icons.mail_outline),
                  const SizedBox(height: 15),
                  _customTextField(
                      _passwordController, "Şifre", Icons.lock_outline,
                      isPassword: true),
                  const SizedBox(height: 35),
                  _isLoading
                      ? const CircularProgressIndicator(
                          color: Color(0xFF2E7D32))
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 3,
                          ),
                          onPressed: _handleAuth,
                          child: Text(
                            _isLogin ? "Giriş Yap" : "Kayıt Ol",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin
                          ? "Hesabın yok mu? Kayıt Ol"
                          : "Zaten hesabın var mı? Giriş Yap",
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 15),
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

  Widget _customTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
    final innerCenter =
        outerCenter + Offset(size.width * 0.18, -size.height * 0.12);
    final innerRadius = outerRadius * 0.8;
    canvas.drawCircle(innerCenter, innerRadius, clearPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}