import 'package:flutter/material.dart';

class UrunDetaySayfasi extends StatelessWidget {
  final Map<String, dynamic> urun;

  const UrunDetaySayfasi({super.key, required this.urun});

  @override
  Widget build(BuildContext context) {
    final String durum = urun['durum'] ?? 'Bilinmiyor';
    final String urunAdi = urun['urunadi'] ?? 'İsimsiz Ürün';
    final String icerik = urun['icerik'] ?? 'İçerik bilgisi girilmemiş.';
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
        title: Text(urunAdi, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: temaRengi,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
            style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }
}
