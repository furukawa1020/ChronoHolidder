import 'package:camera/camera.dart' hide Image;
import 'package:flutter/material.dart';
import 'package:chronoholidder/data/models.dart';
import 'package:scratcher/scratcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronoholidder/data/collection_repository.dart';

class ArScreen extends ConsumerStatefulWidget {
  final EraScore? era;
  final String? aiSummary;

  const ArScreen({super.key, this.era, this.aiSummary});

  @override
  ConsumerState<ArScreen> createState() => _ArScreenState();
}

class _ArScreenState extends ConsumerState<ArScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool isReady = false;
  double progress = 0.0;
  bool isRevealed = false;

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
    Widget bg = Container(color: Colors.black);
    if (isReady && _controller != null) {
      bg = CameraPreview(_controller!);
    }

    // fallback fake era if null
    final eraName = widget.era?.era_name ?? "Ancient Layer";
    final eraImage = widget.era?.image_url;
    final eraDesc = widget.aiSummary ?? widget.era?.reason ?? "No Data";

    return Scaffold(
      body: Stack(
        children: [
          // 1. Camera Preview (Background)
          Container(
            width: double.infinity,
            height: double.infinity,
            child: bg,
          ),
          
          // 2. The Content to Reveal (The History)
          // This is BEHIND the scratcher, but Scratcher logic puts the content as specific child.
          // Wait, Scratcher takes a 'child' (what is hidden initially?) no, Scratcher takes a child which is VISIBLE, 
          // and covers it with a color/image. Wait.
          // Scratcher: "Scratch card widget which temporarily hides content from user."
          // So 'child' is the Prize (History).
          
          Center(
            child: Scratcher(
              brushSize: 50,
              threshold: 50,
              color: Colors.brown.shade800,
              image: Image.asset("assets/images/dirt_layer.png"), 
              onChange: (value) {
                setState(() {
                  progress = value;
                });
              },
              onThreshold: () {
                setState(() {
                  isRevealed = true;
                });
                if (widget.era != null) {
                  ref.read(collectionRepositoryProvider).addToCollection(widget.era!);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Collection Updated: Excavation Successful!"),
                    backgroundColor: Colors.green,
                  ));
                }
              },
              child: Container(
                width: 300,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (eraImage != null)
                      Expanded(child: Image.network(eraImage, fit: BoxFit.cover))
                    else
                      Expanded(child: Icon(Icons.history_edu, size: 80, color: Colors.amber)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(eraName, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(eraDesc, style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 3. UI Overlays (Depth Gauge)
          Positioned(
            top: 50,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("EXCAVATION DEPTH", style: TextStyle(color: Colors.greenAccent, fontSize: 12, letterSpacing: 1.5)),
                Text("${(progress * 15).toStringAsFixed(1)}m", style: TextStyle(color: Colors.greenAccent, fontSize: 32, fontFamily: "Monospace", fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          if (progress < 10)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Text("SCRATCH TO EXCAVATE", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold,  shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
              ),
            ),
        ],
      ),
    );
  }
}
