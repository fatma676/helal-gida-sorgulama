import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase bağlantısını kuruyoruz
  // Not: Gerçek projede bu değerleri environment variables veya .env dosyasından alınız
  try {
    await Supabase.initialize(
      url: 'https://your-project-id.supabase.co', 
      anonKey: 'your-anon-key-here',
    );
  } catch (e) {
    print('Supabase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Helal Gıda Projesi',
      theme: ThemeData(
        primarySwatch: Colors.green, 
      ),
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 100),
              SizedBox(height: 20),
              Text(
                "Bağlantı Başarılı!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text("Supabase ve Flutter artık el ele."),
            ],
          ),
        ),
      ),
    );
  }
}