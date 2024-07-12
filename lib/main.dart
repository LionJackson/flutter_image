import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image/page/camera.dart';

import 'page/gallery.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '图像识别',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        appBarTheme: AppBarTheme(
          color: Colors.green.shade400,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.disabled)) {
                  return Colors.white.withOpacity(0.5);
                }
                return Colors.white;
              },
            ),
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.green.withOpacity(0.8);
                } else if (states.contains(WidgetState.disabled)) {
                  return Colors.green.withOpacity(0.4);
                }
                return Colors.green;
              },
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '图像识别'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraDescription cameraDescription;

  bool cameraIsAvailable = Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
    initPages();
  }

  initPages() async {
    if (cameraIsAvailable) {
      cameraDescription = (await availableCameras()).first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GalleryPage()),
                  );
                },
                child: const Text('拍照/图库 识别')),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraPage(camera: cameraDescription)),
                  );
                },
                child: const Text('相机识别'))
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
