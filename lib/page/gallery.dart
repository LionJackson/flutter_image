import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../helper/image_classification_helper.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  ImageClassificationHelper? imageClassificationHelper;
  final imagePicker = ImagePicker();
  String? imagePath;
  img.Image? image;
  Map<String, double>? classification;
  bool cameraIsAvailable = Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    imageClassificationHelper = ImageClassificationHelper();
    imageClassificationHelper!.initHelper();
    super.initState();
  }

  void cleanResult() {
    imagePath = null;
    image = null;

    classification = null;
    setState(() {});
  }

  Future<void> processImage() async {
    if (imagePath != null) {
      final imageData = File(imagePath!).readAsBytesSync();
      image = img.decodeImage(imageData);
      setState(() {});
      classification = await imageClassificationHelper?.inferenceImage(image!);
      setState(() {});
    }
  }

  @override
  void dispose() {
    imageClassificationHelper?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('拍照/图库 识别'),
        actions: [
          IconButton(
              onPressed: () async {
                cleanResult();
                final result = await imagePicker.pickImage(
                  source: ImageSource.camera,
                );
                imagePath = result?.path;
                setState(() {});
                processImage();
              },
              icon: const Icon(Icons.camera_alt_outlined)),
          IconButton(
              onPressed: () async {
                cleanResult();
                final result = await imagePicker.pickImage(
                  source: ImageSource.gallery,
                );

                imagePath = result?.path;
                setState(() {});
                processImage();
              },
              icon: const Icon(Icons.photo))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (image != null) ...[
            const Text('模型信息：', style: TextStyle(color: Colors.blueAccent)),
            if (imageClassificationHelper?.inputTensor != null)
              Text(
                'Input: (shape: ${imageClassificationHelper?.inputTensor.shape} type: '
                '${imageClassificationHelper?.inputTensor.type})',
              ),
            if (imageClassificationHelper?.outputTensor != null)
              Text(
                'Output: (shape: ${imageClassificationHelper?.outputTensor.shape} '
                'type: ${imageClassificationHelper?.outputTensor.type})',
              ),
            // Show picked image information
            Text('Num channels: ${image?.numChannels}  Bits per channel: ${image?.bitsPerChannel}'),
            Text('Height: ${image?.height}  Width: ${image?.width}'),
          ],
          if (imagePath != null)
            Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0), // 设置圆角半径
                child: Image.file(
                  File(imagePath!),
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover, // 让图片适应容器大小
                ),
              ),
            ),
          if (classification != null) const Text('识别结果：', style: TextStyle(color: Colors.blueAccent)),
          if (classification != null)
            ...(classification!.entries.toList()
                  ..sort(
                    (a, b) => a.value.compareTo(b.value),
                  ))
                .reversed
                .take(3)
                .map(
                  (e) => Container(
                    padding: const EdgeInsets.all(8),
                    child: Text('${e.key}: ${(e.value * 100).toStringAsFixed(2)}%'),
                  ),
                ),
        ],
      ),
    );
  }
}
