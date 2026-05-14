import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarkodTaramaSayfasi extends StatefulWidget {
  const BarkodTaramaSayfasi({super.key});

  @override
  State<BarkodTaramaSayfasi> createState() => _BarkodTaramaSayfasiState();
}

class _BarkodTaramaSayfasiState extends State<BarkodTaramaSayfasi> {
  bool _tarandiMi = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Barkod Tara"),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_tarandiMi) return;
              final barkod = capture.barcodes.firstOrNull?.rawValue;
              if (barkod != null) {
                setState(() => _tarandiMi = true);
                Navigator.pop(context, barkod);
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2E7D32), width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Icon(Icons.qr_code_scanner, color: Colors.white, size: 36),
                SizedBox(height: 12),
                Text(
                  "Barkodu çerçeve içine getirin",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
