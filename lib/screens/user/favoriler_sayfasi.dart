import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'urun_detay.dart';

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
          .select(
              'urunid, urun(urunid, urunadi, barkod, durum, icerik, aciklama)')
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
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                  child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                        borderRadius: BorderRadius.circular(15),
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: durumRengi,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              durum,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
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
                                    IconButton(
                                      icon: const Icon(Icons.favorite,
                                          color: Color(0xFF2E7D32), size: 30),
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
