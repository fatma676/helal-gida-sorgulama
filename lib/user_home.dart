import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _seciliIndeks = 0;

  final List<Widget> _sayfalar = [
    const KategorilerSayfasi(),
    const Center(child: Text("Favorilerim", style: TextStyle(fontSize: 18, color: Colors.grey))),
    const Center(child: Text("Profilim", style: TextStyle(fontSize: 18, color: Colors.grey))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
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
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoriler'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class KategorilerSayfasi extends StatelessWidget {
  const KategorilerSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> kategoriler = [
      {'ad': 'Et Ürünleri', 'ikon': Icons.kebab_dining},
      {'ad': 'Süt Ürünleri', 'ikon': Icons.water_drop},
      {'ad': 'Atıştırmalık', 'ikon': Icons.cookie},
      {'ad': 'İçecek', 'ikon': Icons.local_drink},
      {'ad': 'Dondurulmuş Ürünler', 'ikon': Icons.icecream},
      {'ad': 'Baharat', 'ikon': Icons.eco},
      {'ad': 'Bakliyat', 'ikon': Icons.grain},
      {'ad': 'Soslar', 'ikon': Icons.soup_kitchen},
      {'ad': 'Unlu Mamuller', 'ikon': Icons.bakery_dining},
      {'ad': 'Yağlar', 'ikon': Icons.oil_barrel},
      {'ad': 'Konserve', 'ikon': Icons.inventory_2},
      {'ad': 'Tatlılar', 'ikon': Icons.cake},
      {'ad': 'Kahvaltılık', 'ikon': Icons.breakfast_dining},
      {'ad': 'Bebek Maması', 'ikon': Icons.child_care},
      {'ad': 'Hazır Yemek', 'ikon': Icons.fastfood},
    ];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 14),
            child: Column(
              children: [
                SizedBox(
                  height: 46,
                  width: 46,
                  child: CustomPaint(painter: CrescentPainter()),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Helal Gıda Sorgulama",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: "Ürün adı veya barkod yazın...",
                              prefixIcon: Icon(Icons.search, color: Colors.green),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text("Scan Barkod"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Kategoriler", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 0.9,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // --- BURASI GÜNCELLENDİ: InkWell ve Navigator eklendi ---
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KategoriUrunleriSayfasi(
                          kategoriAdi: kategoriler[index]['ad'],
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(kategoriler[index]['ikon'], color: const Color(0xFF2E7D32), size: 35),
                        const SizedBox(height: 8),
                        Text(
                          kategoriler[index]['ad'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: kategoriler.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }
}

// --- ŞİMDİLİK BOŞ GELECEK ÜRÜN LİSTESİ SAYFASI ---
class KategoriUrunleriSayfasi extends StatelessWidget {
  final String kategoriAdi;

  const KategoriUrunleriSayfasi({super.key, required this.kategoriAdi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          kategoriAdi,
          style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}

// Senin özel Hilal Painter'ın 
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