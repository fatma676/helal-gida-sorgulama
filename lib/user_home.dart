import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ──────────────────────────────────────────────
// ANA SAYFA
// ──────────────────────────────────────────────

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
        _profilSayfasi(),
      ];

  Widget _profilSayfasi() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _profilBilgileri,
      builder: (context, snapshot) {
        String displayName = "Ad Soyad bulunamadı";
        if (snapshot.connectionState == ConnectionState.waiting) {
          displayName = "Yükleniyor...";
        } else if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!['adsoyad'] != null) {
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
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          size: 60, color: Colors.green.shade800),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10)
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(displayName,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text("Kullanıcı",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
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
                    onTap: _handleLogout,
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Çıkış Yap",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorilerim'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hesabım'),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// KATEGORİLER SAYFASI
// ──────────────────────────────────────────────

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
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
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
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 8),
                            ],
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: "Ürün adı veya barkod yazın...",
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.green),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text("Okut"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Kategoriler",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          kategoriler[index]['ikon'],
                          color: const Color(0xFF2E7D32),
                          size: 35,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          kategoriler[index]['ad'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600),
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

// ──────────────────────────────────────────────
// KATEGORİ ÜRÜNLERİ SAYFASI
// ──────────────────────────────────────────────

class KategoriUrunleriSayfasi extends StatefulWidget {
  final String kategoriAdi;

  const KategoriUrunleriSayfasi({super.key, required this.kategoriAdi});

  @override
  State<KategoriUrunleriSayfasi> createState() =>
      _KategoriUrunleriSayfasiState();
}

class _KategoriUrunleriSayfasiState extends State<KategoriUrunleriSayfasi> {
  bool _yukleniyor = true;
  List<dynamic> _urunler = [];
  final List<int> _favoriUrunIdleri = [];

  @override
  void initState() {
    super.initState();
    _urunleriGetir();
    _favoriListesiniGetir();
  }

  Future<void> _favoriListesiniGetir() async {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email;
    if (email == null) return;

    try {
      final favoriData = await Supabase.instance.client
          .from('favoriler')
          .select('urunid')
          .eq('kullanici_mail', email);

      if (favoriData is List) {
        setState(() {
          _favoriUrunIdleri.clear();
          _favoriUrunIdleri.addAll(favoriData
              .where((item) =>
                  item is Map<String, dynamic> && item['urunid'] != null)
              .map<int>((item) => item['urunid'] as int));
        });
      }
    } catch (e) {
      debugPrint('Favori listesi alınamadı: $e');
    }
  }

  Future<void> _favoriToggle(int urunId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final zatenFavori = _favoriUrunIdleri.contains(urunId);

    try {
      if (zatenFavori) {
        await Supabase.instance.client
            .from('favoriler')
            .delete()
            .eq('kullanici_mail', user.email!)
            .eq('urunid', urunId);

        if (mounted) {
          setState(() => _favoriUrunIdleri.remove(urunId));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Ürün favorilerden kaldırıldı!"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        await Supabase.instance.client.from('favoriler').insert({
          'kullanici_mail': user.email,
          'urunid': urunId,
        });

        if (mounted) {
          setState(() => _favoriUrunIdleri.add(urunId));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Ürün favorilere eklendi!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("İşlem sırasında hata oluştu: $e"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _urunleriGetir() async {
    try {
      final supabase = Supabase.instance.client;

      final kategoriData = await supabase
          .from('kategori')
          .select('kategoriid')
          .eq('kategoriadi', widget.kategoriAdi)
          .single();

      final int kategoriId = kategoriData['kategoriid'];

      final urunlerData = await supabase
          .from('urun')
          .select('*')
          .eq('kategoriid', kategoriId)
          .order('urunadi', ascending: true);

      setState(() {
        _urunler = urunlerData;
        _yukleniyor = false;
      });
    } catch (e) {
      debugPrint("Hata oluştu: $e");
      setState(() => _yukleniyor = false);
    }
  }

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
          widget.kategoriAdi,
          style: const TextStyle(
              color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
        ),
      ),
      body: _yukleniyor
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : _urunler.isEmpty
              ? const Center(
                  child: Text("Bu kategoride henüz ürün bulunmuyor."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _urunler.length,
                  itemBuilder: (context, index) {
                    final urun = _urunler[index];
                    final String durum = urun['durum'];

                    Color durumRengi = Colors.grey;
                    if (durum == 'Helal') durumRengi = Colors.green;
                    if (durum == 'Şüpheli') durumRengi = Colors.orange;
                    if (durum == 'Haram') durumRengi = Colors.red;

                    final bool favori =
                        _favoriUrunIdleri.contains(urun['urunid']);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        // Ürüne tıklayınca detay sayfasına git
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UrunDetaySayfasi(urun: Map<String, dynamic>.from(urun)),
                            ),
                          );
                        },
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: durumRengi.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.inventory_2, color: durumRengi),
                        ),
                        title: Text(
                          urun['urunadi'],
                          style:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Barkod: ${urun['barkod']}"),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: durumRengi,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                durum,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            favori
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: favori ? Colors.green : Colors.red,
                          ),
                          onPressed: () => _favoriToggle(urun['urunid']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ──────────────────────────────────────────────
// ÜRÜN DETAY SAYFASI
// ──────────────────────────────────────────────

class UrunDetaySayfasi extends StatelessWidget {
  final Map<String, dynamic> urun;

  const UrunDetaySayfasi({super.key, required this.urun});

  @override
  Widget build(BuildContext context) {
    final String durum = urun['durum'] ?? 'Bilinmiyor';
    final String urunAdi = urun['urunadi'] ?? 'İsimsiz Ürün';
    final String icerik =
        urun['icerik'] ?? 'İçerik bilgisi girilmemiş.';
    final String aciklama = urun['aciklama'] ??
        'Bu ürün için henüz bir analiz açıklaması bulunmamaktadır.';

    Color temaRengi;
    IconData durumIkonu;
    if (durum == 'Helal') {
      temaRengi = Colors.green.shade700;
      durumIkonu = Icons.check_circle_outline;
    } else if (durum == 'Haram') {
      temaRengi = Colors.red.shade700;
      durumIkonu = Icons.cancel_outlined;
    } else {
      temaRengi = Colors.orange.shade700;
      durumIkonu = Icons.help_outline;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      appBar: AppBar(
        title: Text(urunAdi,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: temaRengi,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Üst Durum Bannerı
            Container(
              width: double.infinity,
              color: temaRengi,
              padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
              child: Column(
                children: [
                  Icon(durumIkonu, size: 80, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    durum.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            // İçerik Kartları
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _bilgiKarti(
                      baslik: "Ürün İçeriği",
                      altBaslik: icerik,
                      ikon: Icons.list_alt,
                      ikonRenk: Colors.blueGrey,
                    ),
                    const SizedBox(height: 15),
                    _bilgiKarti(
                      baslik: "Analiz Açıklaması",
                      altBaslik: aciklama,
                      ikon: Icons.description_outlined,
                      ikonRenk: temaRengi,
                    ),
                    const SizedBox(height: 15),
                    _bilgiKarti(
                      baslik: "Barkod Numarası",
                      altBaslik: urun['barkod'] ?? "-",
                      ikon: Icons.qr_code_scanner,
                      ikonRenk: Colors.black87,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bilgiKarti({
    required String baslik,
    required String altBaslik,
    required IconData ikon,
    required Color ikonRenk,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ikon, color: ikonRenk, size: 24),
              const SizedBox(width: 10),
              Text(
                baslik,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),
          Text(
            altBaslik,
            style: const TextStyle(
                fontSize: 15, color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// FAVORİLER SAYFASI
// ──────────────────────────────────────────────

class FavorilerSayfasi extends StatefulWidget {
  const FavorilerSayfasi({super.key});

  @override
  State<FavorilerSayfasi> createState() => _FavorilerSayfasiState();
}

class _FavorilerSayfasiState extends State<FavorilerSayfasi> {
  bool _yukleniyor = true;
  List<Map<String, dynamic>> _favoriler = [];

  @override
  void initState() {
    super.initState();
    _favorileriGetir();
  }

  Future<void> _favorileriGetir() async {
    setState(() => _yukleniyor = true);

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.email == null) {
      setState(() => _yukleniyor = false);
      return;
    }

    try {
      final data = await Supabase.instance.client
          .from('favoriler')
          .select('urunid, urun(urunid, urunadi, barkod, durum, icerik, aciklama)')
          .eq('kullanici_mail', user.email!);

      final List<Map<String, dynamic>> liste = [];
      for (final row in data as List) {
        final urun = row['urun'];
        if (urun != null && urun is Map<String, dynamic>) {
          liste.add({
            'urunid': urun['urunid'],
            'urunadi': urun['urunadi'],
            'barkod': urun['barkod'],
            'durum': urun['durum'],
            'icerik': urun['icerik'],
            'aciklama': urun['aciklama'],
          });
        }
      }

      setState(() {
        _favoriler = liste;
        _yukleniyor = false;
      });
    } catch (e) {
      debugPrint('Favoriler getirilemedi: $e');
      setState(() => _yukleniyor = false);
    }
  }

  Future<void> _favoridanKaldir(int urunId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client
          .from('favoriler')
          .delete()
          .eq('kullanici_mail', user.email!)
          .eq('urunid', urunId);

      setState(() {
        _favoriler.removeWhere((u) => u['urunid'] == urunId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ürün favorilerden kaldırıldı!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("İşlem sırasında hata oluştu: $e"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              "Favorilerim",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _yukleniyor
              ? const Center(
                  child:
                      CircularProgressIndicator(color: Color(0xFF2E7D32)))
              : _favoriler.isEmpty
                  ? const Center(
                      child: Text(
                        "Henüz favori ürününüz yok.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFF2E7D32),
                      onRefresh: _favorileriGetir,
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _favoriler.length,
                        itemBuilder: (context, index) {
                          final urun = _favoriler[index];
                          final String durum = urun['durum'] ?? '';

                          Color durumRengi = Colors.grey;
                          if (durum == 'Helal') durumRengi = Colors.green;
                          if (durum == 'Şüpheli')
                            durumRengi = Colors.orange;
                          if (durum == 'Haram') durumRengi = Colors.red;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 2,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              // Favoriler ekranından da detay sayfasına git
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UrunDetaySayfasi(urun: urun),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: durumRengi.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(15),
                                      ),
                                      child: Icon(Icons.inventory_2,
                                          color: durumRengi),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4),
                                            decoration: BoxDecoration(
                                              color: durumRengi,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              durum,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            urun['urunadi'] ?? '',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black87),
                                          ),
                                          Text(
                                            "Barkod: ${urun['barkod'] ?? ''}",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Kalp ikonu — basınca favoriden kaldır
                                    IconButton(
                                      icon: const Icon(Icons.favorite,
                                          color: Color(0xFF2E7D32),
                                          size: 30),
                                      onPressed: () =>
                                          _favoridanKaldir(urun['urunid']),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// YARDIMCI — Hilal Çizici
// ──────────────────────────────────────────────

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