import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color lavender = Color(0xFFD8C9F7);
  static const Color fabLavender = Color(0xFFE7DDFB);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo Home Page',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F3FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: lavender,
          centerTitle: false,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Має співпадати з Android/iOS native кодом
  static const MethodChannel _channel =
  MethodChannel('com.example.laboratorna14/native');

  final ImagePicker _picker = ImagePicker();

  File? _photo;

  Future<void> _showNativeStringDialog() async {
    String text = 'Some static string';
    try {
      final String? res =
      await _channel.invokeMethod<String>('getNativeMessage');
      if (res != null && res.trim().isNotEmpty) text = res;
    } on PlatformException {
      // якщо нативний код не підключений/помилка — залишимо статичний рядок
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
          content: SizedBox(
            width: 290,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  'https://emojiisland.com/cdn/shop/products/Robot_Emoji_Icon_abe1111a-1293-4668-bdf9-9ceb05cff58e_large.png?v=1571606090',
                  height: 52,
                  width: 52,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.smart_toy, size: 48),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Native data:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? xfile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (xfile == null) return;

      setState(() {
        _photo = File(xfile.path);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не вдалося зробити фото: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePhoto,
        backgroundColor: MyApp.fabLavender,
        elevation: 3,
        child: const Icon(Icons.camera_alt_outlined, color: Colors.black87),
      ),
      body: Column(
        children: [
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: OutlinedButton(
                onPressed: _showNativeStringDialog,
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                  side: BorderSide(color: Colors.black.withOpacity(0.25)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
                child: const Text('#1 String'),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: _photo == null
                ? const SizedBox.shrink()
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _photo!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
