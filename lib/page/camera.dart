import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../helper/image_classification_helper.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  State<StatefulWidget> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  late CameraController cameraController;
  late ImageClassificationHelper imageClassificationHelper;
  Map<String, double>? classification;
  bool _isProcessing = false;

  // init camera
  initCamera() {
    cameraController = CameraController(widget.camera, ResolutionPreset.medium,
        imageFormatGroup: Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.yuv420);
    cameraController.initialize().then((value) {
      cameraController.startImageStream(imageAnalysis);
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> imageAnalysis(CameraImage cameraImage) async {
    // if image is still analyze, skip this frame
    if (_isProcessing) {
      return;
    }
    _isProcessing = true;
    classification = await imageClassificationHelper.inferenceCameraFrame(cameraImage);
    _isProcessing = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initCamera();
    imageClassificationHelper = ImageClassificationHelper();
    imageClassificationHelper.initHelper();
    super.initState();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        cameraController.stopImageStream();
        break;
      case AppLifecycleState.resumed:
        if (!cameraController.value.isStreamingImages) {
          await cameraController.startImageStream(imageAnalysis);
        }
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    imageClassificationHelper.close();
    super.dispose();
  }

  Widget cameraWidget(context) {
    var camera = cameraController.value;
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * camera.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(cameraController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    list.add(
      SizedBox(
        child: (!cameraController.value.isInitialized) ? Container() : cameraWidget(context),
      ),
    );
    list.add(Container(
      alignment: Alignment.bottomCenter,
      color: Colors.black.withOpacity(0.3),
      height: 100,
      child: Column(
        children: [
          if (classification != null)
            ...(classification!.entries.toList()
                  ..sort(
                    (a, b) => a.value.compareTo(b.value),
                  ))
                .reversed
                .take(3)
                .map(
                  (e) => Container(
                    padding: const EdgeInsets.all(3),
                    child: Text(
                      '${e.key}: ${(e.value * 100).toStringAsFixed(2)}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
        ],
      ),
    ));

    return Scaffold(
      appBar: AppBar(title: const Text('相机识别')),
      body: Stack(
        children: list,
      ),
    );
  }
}
