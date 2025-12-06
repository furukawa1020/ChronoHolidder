import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ArScreen extends StatefulWidget {
  const ArScreen({super.key});

  @override
  State<ArScreen> createState() => _ArScreenState();
}

class _ArScreenState extends State<ArScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(cameras![0], ResolutionPreset.high);
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            isReady = true;
          });
        }
      }
    } catch (_) {
      // Handle camera error or simulator case silently
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If camera not ready, show a placeholder (functional on simulator)
    if (!isReady || _controller == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 64),
            SizedBox(height: 16),
            Text("AR Camera Loading...", style: TextStyle(color: Colors.white54)),
          ],
        )),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Camera Preview
          Container(
            width: double.infinity,
            height: double.infinity,
            child: CameraPreview(_controller!),
          ),
          // 2. AR Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.brown.withOpacity(0.5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.7, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 100,
            child: Container(
              padding: EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(
                "Edo Period Layer (15m depth)",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          Center(
            child: Opacity(
              opacity: 0.3,
              child: Icon(Icons.castle, size: 200, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Peak Era Visualization Mode",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black)]),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          )
        ],
      ),
    );
  }
}
