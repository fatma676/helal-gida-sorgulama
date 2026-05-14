import 'package:flutter/material.dart';

class HesabimPage extends StatelessWidget {
  final Future<Map<String, dynamic>?> profilBilgileri;
  final VoidCallback onLogout;

  const HesabimPage({
    super.key,
    required this.profilBilgileri,
    required this.onLogout,
  });

  Widget _profilMenuTile(IconData icon, String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2E7D32)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: profilBilgileri,
      builder: (context, snapshot) {
        String displayName = "Ad Soyad bulunamadı";
        if (snapshot.connectionState == ConnectionState.waiting) {
          displayName = "Yükleniyor...";
        } else if (snapshot.hasData && snapshot.data != null && snapshot.data!['adsoyad'] != null) {
          displayName = snapshot.data!['adsoyad'] as String;
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(top: 20, bottom: 12),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Hesabım",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 60, color: Colors.green.shade800),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                      ),
                      child: Column(
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Kullanıcı",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _profilMenuTile(Icons.person_outline, "Hesap Ayarları"),
                  _profilMenuTile(Icons.security, "Gizlilik Politikası"),
                  _profilMenuTile(Icons.info_outline, "Hakkımızda"),
                  const SizedBox(height: 20),
                  ListTile(
                    onTap: onLogout,
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Çıkış Yap",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    tileColor: Colors.red.withOpacity(0.05),
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
