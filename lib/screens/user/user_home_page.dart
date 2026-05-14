import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'components.dart';
import 'favoriler_sayfasi.dart';
import 'hesabim.dart';
import 'kategoriler_sayfasi.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _seciliIndeks = 0;
  late final Future<Map<String, dynamic>?> _profilBilgileri;

  @override
  void initState() {
    super.initState();
    _profilBilgileri = _fetchProfilBilgileri();
  }

  Future<Map<String, dynamic>?> _fetchProfilBilgileri() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.email == null) return null;

    return await Supabase.instance.client
        .from('kullanici')
        .select('adsoyad')
        .eq('eposta', user.email!)
        .maybeSingle();
  }

  Future<void> _handleLogout() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        final String email = user.email!;
        await supabase.from('logs').insert({
          'islem': 'Çıkış yapıldı',
          'kullanici_mail': email,
        });
        await supabase.auth.signOut();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Çıkış yapılırken hata oluştu: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Widget> get _sayfalar => [
        const KategorilerSayfasi(),
        const FavorilerSayfasi(),
        HesabimPage(
          profilBilgileri: _profilBilgileri,
          onLogout: _handleLogout,
        ),
      ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      appBar: _seciliIndeks == 0
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout, color: Color(0xFF2E7D32)),
                  tooltip: "Çıkış Yap",
                ),
              ],
            ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Icon(Icons.eco, size: 400, color: Colors.green.shade900),
            ),
          ),
          _sayfalar[_seciliIndeks],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _seciliIndeks,
        onTap: (index) => setState(() => _seciliIndeks = index),
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorilerim'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hesabım'),
        ],
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
