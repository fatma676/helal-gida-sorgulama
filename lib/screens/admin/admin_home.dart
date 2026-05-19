import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../user/kategoriler_sayfasi.dart';
import '../user/favoriler_sayfasi.dart';
import '../user/hesabim_sayfasi.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
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
        await supabase.from('logs').insert({
          'islem': 'Çıkış yapıldı',
          'kullanici_mail': user.email!,
        });
        await supabase.auth.signOut();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Çıkış hatası: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<Widget> get _sayfalar => [
        const KategorilerSayfasi(),
        const FavorilerSayfasi(),
        const AdminYonetimSayfasi(),
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
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Yönetim'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hesabım'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// YÖNETİM SAYFASI
// ─────────────────────────────────────────────
class AdminYonetimSayfasi extends StatefulWidget {
  const AdminYonetimSayfasi({super.key});

  @override
  State<AdminYonetimSayfasi> createState() => _AdminYonetimSayfasiState();
}

class _AdminYonetimSayfasiState extends State<AdminYonetimSayfasi> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _urunler = [];
  bool _yukleniyor = true;

  final _adiController = TextEditingController();
  final _barkodController = TextEditingController();
  final _icerikController = TextEditingController();
  final _aciklamaController = TextEditingController();
  String _secilenDurum = 'Helal';
  String _secilenKategori = 'Et Ürünleri';

  final List<String> _durumlar = ['Helal', 'Şüpheli', 'Haram'];
  final List<String> _kategoriler = [
    'Et Ürünleri', 'Süt Ürünleri', 'Atıştırmalık', 'İçecek',
    'Dondurulmuş Ürünler', 'Baharat', 'Bakliyat', 'Soslar',
    'Unlu Mamuller', 'Yağlar', 'Konserve', 'Tatlılar',
    'Kahvaltılık', 'Bebek Maması', 'Hazır Yemek',
  ];

  // Kategori ismini veri tabanındaki ID karşılığına çeviren fonksiyon
  int _kategoriIsmindenIdGetir(String kategoriAdi) {
    return _kategoriler.indexOf(kategoriAdi) + 1;
  }

  // Veri tabanındaki id değerini dropdown arayüzü için isme çeviren fonksiyon
  String _kategoriIddenIsimGetir(int? id) {
    if (id == null || id < 1 || id > _kategoriler.length) return 'Et Ürünleri';
    return _kategoriler[id - 1];
  }

  @override
  void initState() {
    super.initState();
    _urunleriGetir();
  }

  @override
  void dispose() {
    _adiController.dispose();
    _barkodController.dispose();
    _icerikController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  Future<void> _urunleriGetir() async {
    if (!mounted) return;
    setState(() => _yukleniyor = true);
    try {
      final data = await supabase
          .from('urun')
          .select('*')
          .order('urunadi', ascending: true);
      if (mounted) {
        setState(() {
          _urunler = List<Map<String, dynamic>>.from(data);
          _yukleniyor = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  void _formuTemizle() {
    _adiController.clear();
    _barkodController.clear();
    _icerikController.clear();
    _aciklamaController.clear();
    _secilenDurum = 'Helal';
    _secilenKategori = 'Et Ürünleri';
  }

  // ── Ürün Ekleme Diyaloğu ──
  void _urunEkleDiyalogu() {
    _formuTemizle();
    showDialog(
      context: context,
      builder: (context) => _urunFormDiyalogu(
        baslik: "Yeni Ürün Ekle",
        onKaydet: () async {
          if (_adiController.text.trim().isEmpty || _barkodController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Ürün adı ve barkod zorunludur!"), backgroundColor: Colors.red),
            );
            return;
          }
          try {
            // Sütun isimleri 'kategoriid', 'icerik' ve 'aciklama' olarak eşitlendi
            await supabase.from('urun').insert({
              'urunadi': _adiController.text.trim(),
              'barkod': _barkodController.text.trim(),
              'icerik': _icerikController.text.trim(),
              'aciklama': _aciklamaController.text.trim(),
              'durum': _secilenDurum,
              'kategoriid': _kategoriIsmindenIdGetir(_secilenKategori),
            });
            
            await supabase.from('logs').insert({
              'islem': 'Ürün eklendi: ${_adiController.text.trim()}',
              'kullanici_mail': supabase.auth.currentUser?.email ?? '',
            });

            if (mounted) {
              Navigator.pop(context);
              _urunleriGetir();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ürün başarıyla eklendi!"), backgroundColor: Colors.green),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Ekleme hatası: $e"), backgroundColor: Colors.red),
              );
            }
          }
        },
      ),
    );
  }

  // ── Ürün Düzenleme Diyaloğu ──
  void _urunDuzenleDiyalogu(Map<String, dynamic> urun) {
    _adiController.text = urun['urunadi'] ?? '';
    _barkodController.text = urun['barkod'] ?? '';
    _icerikController.text = urun['icerik'] ?? '';
    _aciklamaController.text = urun['aciklama'] ?? '';
    _secilenDurum = urun['durum'] ?? 'Helal';
    // Veri tabanından gelen int id bilgisini string isme dönüştürüyoruz
    _secilenKategori = _kategoriIddenIsimGetir(urun['kategoriid']);

    showDialog(
      context: context,
      builder: (context) => _urunFormDiyalogu(
        baslik: "Ürünü Düzenle",
        onKaydet: () async {
          if (_adiController.text.trim().isEmpty || _barkodController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Ürün adı ve barkod alanları boş bırakılamaz!"), backgroundColor: Colors.red),
            );
            return;
          }
          try {
            await supabase.from('urun').update({
              'urunadi': _adiController.text.trim(),
              'barkod': _barkodController.text.trim(),
              'icerik': _icerikController.text.trim(),
              'aciklama': _aciklamaController.text.trim(),
              'durum': _secilenDurum,
              'kategoriid': _kategoriIsmindenIdGetir(_secilenKategori),
            }).eq('urunid', urun['urunid']);

            await supabase.from('logs').insert({
              'islem': 'Ürün düzenlendi: ${_adiController.text.trim()}',
              'kullanici_mail': supabase.auth.currentUser?.email ?? '',
            });

            if (mounted) {
              Navigator.pop(context);
              _urunleriGetir();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ürün başarıyla güncellendi!"), backgroundColor: Colors.green),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Güncelleme hatası: $e"), backgroundColor: Colors.red),
              );
            }
          }
        },
      ),
    );
  }

  // ── Ürün Silme Onayı ──
  void _urunSil(Map<String, dynamic> urun) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Ürünü Sil"),
        content: Text("\"${urun['urunadi']}\" ürününü silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              try {
                await supabase.from('urun').delete().eq('urunid', urun['urunid']);
                await supabase.from('logs').insert({
                  'islem': 'Ürün silindi: ${urun['urunadi']}',
                  'kullanici_mail': supabase.auth.currentUser?.email ?? '',
                });
                if (mounted) {
                  Navigator.pop(context);
                  _urunleriGetir();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Ürün başarıyla silindi!"), backgroundColor: Colors.red),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Silme hatası: $e"), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text("Sil"),
          ),
        ],
      ),
    );
  }

  // ── Ortak Form Diyaloğu (Ekle / Düzenle) ──
  Widget _urunFormDiyalogu({required String baslik, required VoidCallback onKaydet}) {
    return StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(baslik, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _formAlani(_adiController, "Ürün Adı", Icons.inventory_2_outlined),
              const SizedBox(height: 12),
              _formAlani(_barkodController, "Barkod", Icons.qr_code),
              const SizedBox(height: 12),
              _formAlani(_icerikController, "İçerik", Icons.list_alt, satirSayisi: 3),
              const SizedBox(height: 12),
              _formAlani(_aciklamaController, "Açıklama", Icons.description_outlined, satirSayisi: 3),
              const SizedBox(height: 12),
              // Durum Seçici
              DropdownButtonFormField<String>(
                value: _secilenDurum,
                decoration: InputDecoration(
                  labelText: "Helallik Durumu",
                  prefixIcon: const Icon(Icons.verified_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _durumlar.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (val) => setDialogState(() => _secilenDurum = val!),
              ),
              const SizedBox(height: 12),
              // Kategori Seçici
              DropdownButtonFormField<String>(
                value: _secilenKategori,
                decoration: InputDecoration(
                  labelText: "Kategori",
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _kategoriler.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                onChanged: (val) => setDialogState(() => _secilenKategori = val!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onKaydet,
            child: const Text("Kaydet"),
          ),
        ],
      ),
    );
  }

  Widget _formAlani(TextEditingController controller, String label, IconData icon, {int satirSayisi = 1}) {
    return TextField(
      controller: controller,
      maxLines: satirSayisi,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        alignLabelWithHint: true,
      ),
    );
  }

  Color _durumRengi(String durum) {
    if (durum == 'Helal') return Colors.green;
    if (durum == 'Haram') return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      children: [
                        const Text(
                          "Ürün Yönetimi",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          "${_urunler.length} ürün",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      _urunler.isEmpty
                          ? [
                              const SizedBox(height: 50),
                              const Center(child: Text("Sistemde henüz ürün bulunmuyor.")),
                            ]
                          : _urunler.map((urun) {
                              final durum = urun['durum'] ?? 'Şüpheli';
                              final renk = _durumRengi(durum);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 2,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: renk.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.inventory_2, color: renk),
                                  ),
                                  title: Text(
                                    urun['urunadi'] ?? 'İsimsiz Ürün',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Barkod: ${urun['barkod'] ?? '-'}",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: renk,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          durum,
                                          style: const TextStyle(color: Colors.white, fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Color(0xFF2E7D32)),
                                        onPressed: () => _urunDuzenleDiyalogu(urun),
                                        tooltip: "Düzenle",
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _urunSil(urun),
                                        tooltip: "Sil",
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _urunEkleDiyalogu,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Ürün Ekle"),
      ),
    );
  }
}