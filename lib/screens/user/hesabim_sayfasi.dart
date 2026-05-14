import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HesabimPage extends StatefulWidget {
  final Future<Map<String, dynamic>?> profilBilgileri;
  final VoidCallback onLogout;

  const HesabimPage({
    super.key,
    required this.profilBilgileri,
    required this.onLogout,
  });

  @override
  State<HesabimPage> createState() => _HesabimPageState();
}

class _HesabimPageState extends State<HesabimPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- E-posta Güncelle ---
  Future<void> _ePostaGuncelle() async {
    try {
      if (_emailController.text.trim().isEmpty) {
        throw "E-posta alanı boş bırakılamaz.";
      }
      await supabase.auth
          .updateUser(UserAttributes(email: _emailController.text.trim()));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("E-posta onay bağlantısı gönderildi!")),
        );
        _emailController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    }
  }

  // --- Şifre Güncelle ---
  Future<void> _sifreGuncelle() async {
    try {
      if (_passwordController.text.length < 6) {
        throw "Şifre en az 6 karakter olmalıdır.";
      }
      await supabase.auth.updateUser(
          UserAttributes(password: _passwordController.text.trim()));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Şifreniz başarıyla güncellendi!")),
        );
        _passwordController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    }
  }

  // --- Hesap Ayarları Diyaloğu ---
  void _hesapAyarlariniGoster() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.manage_accounts_outlined, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text("Hesap Ayarları"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // E-posta Güncelleme
              const Text(
                "E-posta Güncelle",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Yeni E-posta",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _ePostaGuncelle,
                icon: const Icon(Icons.send_outlined),
                label: const Text("E-postayı Güncelle"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const Divider(height: 30),

              // Şifre Güncelleme
              const Text(
                "Şifre Güncelle",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Yeni Şifre",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _sifreGuncelle,
                icon: const Icon(Icons.lock_reset_outlined),
                label: const Text("Şifreyi Güncelle"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Kapat", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // --- Gizlilik Politikası Diyaloğu ---
  void _gizlilikGoster() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.privacy_tip_outlined, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text("Gizlilik Politikası"),
          ],
        ),
        content: const Text(
          "Verileriniz Supabase altyapısında güvenle saklanmaktadır. "
          "Kişisel verileriniz üçüncü taraflarla paylaşılmaz.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Kapat"),
          ),
        ],
      ),
    );
  }

  // --- Hakkımızda Diyaloğu ---
  void _hakkimizdaGoster() {
    showAboutDialog(
      context: context,
      applicationName: "Helal Gıda Projesi",
      applicationVersion: "1.0.0",
      applicationIcon:
          const Icon(Icons.verified_user, color: Colors.green, size: 50),
      children: const [
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text("Selçuk Üniversitesi Teknoloji Fakültesi"),
        ),
        Text("Bilgisayar Mühendisliği Bölümü Projesi"),
      ],
    );
  }

  // --- Menü Kartı Widget ---
  Widget _profilMenuTile(
      IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2E7D32)),
        title:
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing:
            const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: widget.profilBilgileri,
      builder: (context, snapshot) {
        String displayName = "Ad Soyad Yüklenemedi";

        if (snapshot.connectionState == ConnectionState.waiting) {
          displayName = "Yükleniyor...";
        } else if (snapshot.hasData && snapshot.data != null) {
          displayName = snapshot.data!['adsoyad'] ?? "İsimsiz Kullanıcı";
        }

        return CustomScrollView(
          slivers: [
            // --- Üst Profil Alanı ---
            SliverToBoxAdapter(
              child: Container(
                padding:
                    const EdgeInsets.only(top: 15, bottom: 12),
                margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Hesabım",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          size: 65, color: Colors.green.shade800),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Kullanıcı",
                            style: TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Menü Listesi ---
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _profilMenuTile(
                    Icons.manage_accounts_outlined,
                    "Hesap Ayarları",
                    _hesapAyarlariniGoster,
                  ),
                  _profilMenuTile(
                    Icons.privacy_tip_outlined,
                    "Gizlilik Politikası",
                    _gizlilikGoster,
                  ),
                  _profilMenuTile(
                    Icons.help_center_outlined,
                    "Hakkımızda",
                    _hakkimizdaGoster,
                  ),

                  const SizedBox(height: 25),

                  // Çıkış Yap Butonu
                  ListTile(
                    onTap: widget.onLogout,
                    leading:
                        const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Güvenli Çıkış",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    tileColor: Colors.red.withAlpha(26),
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}