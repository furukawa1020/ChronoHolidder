import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:chronoholidder/data/api_client.dart';
import 'package:chronoholidder/data/models.dart';
import 'package:chronoholidder/features/collection/collection_screen.dart';
import 'package:chronoholidder/features/ar/ar_screen.dart';
import 'package:chronoholidder/features/settings/settings_screen.dart';

final currentAnalysisProvider = StateProvider<AnalysisResponse?>((ref) => null);
final isLoadingProvider = StateProvider<bool>((ref) => false);

class UserLocationNotifier extends StateNotifier<LatLng> {
  UserLocationNotifier() : super(LatLng(35.6895, 139.6917)); // Tokyo default

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    state = LatLng(position.latitude, position.longitude);
  }
}

final userLocationProvider = StateNotifierProvider<UserLocationNotifier, LatLng>((ref) {
  return UserLocationNotifier();
});

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLocation = ref.watch(userLocationProvider);
    final currentAnalysis = ref.watch(currentAnalysisProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Layer (Mapbox / OpenStreetMap)
          FlutterMap(
            options: MapOptions(
              initialCenter: userLocation,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.chronoholidder.chronoholidder',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: userLocation,
                    width: 80,
                    height: 80,
                    child: Icon(Icons.location_pin, color: Colors.blue, size: 40),
                  ),
                ],
              ),
            ],
          ),

          // 2. Overlay UI
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text("ChronoHolidder", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                         IconButton(icon: Icon(Icons.settings), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => SettingsScreen()))),
                      ],
                    ),
                    SizedBox(height: 10),
                    if (currentAnalysis != null) ...[
                      // Show Visual Evidence if available
                      if (currentAnalysis.peak_eras.firstOrNull?.image_url != null) 
                        Container(
                          height: 150,
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(currentAnalysis.peak_eras.first.image_url!),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(color: Colors.black54, padding: EdgeInsets.all(4), child: Text("Visual Evidence", style: TextStyle(color: Colors.white, fontSize: 10))),
                          ),
                        ),

                      Text("Top Era: ${currentAnalysis.peak_eras.firstOrNull?.era_name ?? 'N/A'}", style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.bold)),
                      Text(currentAnalysis.summary_ai, maxLines: 2, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(context: context, builder: (c) => EraDetailSheet(analysis: currentAnalysis));
                        },
                        child: Text("掘る (Dig into History)"),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(Icons.collections_bookmark, color: Colors.brown),
                            tooltip: "Collection",
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => CollectionScreen()));
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.view_in_ar, color: Colors.indigo),
                            tooltip: "AR Mode",
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => ArScreen()));
                            },
                          ),
                        ],
                      )
                    ] else
                      ElevatedButton.icon(
                        icon: isLoading 
                           ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                           : Icon(Icons.history_edu),
                        label: Text(isLoading ? "Analyzing Layers..." : "Analyze Current Ground"),
                        onPressed: isLoading ? null : () async {
                           ref.read(isLoadingProvider.notifier).state = true;
                           await ref.read(userLocationProvider.notifier).getCurrentLocation();
                           final loc = ref.read(userLocationProvider);
                           
                           try {
                             final result = await ref.read(apiClientProvider).analyzeLocation(loc.latitude, loc.longitude);
                             ref.read(currentAnalysisProvider.notifier).state = result;
                           } catch(e) {
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                           } finally {
                             ref.read(isLoadingProvider.notifier).state = false;
                           }
                        },
                      )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class EraDetailSheet extends StatelessWidget {
  final AnalysisResponse analysis;
  const EraDetailSheet({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Layers of Time", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: analysis.peak_eras.length,
              itemBuilder: (context, index) {
                final era = analysis.peak_eras[index];
                return Card(
                  color: index == 0 ? Colors.amber[100] : null,
                  child: ListTile(
                    leading: CircleAvatar(child: Text("${index + 1}")),
                    title: Text(era.era_name),
                    subtitle: Text("${era.start_year} - ${era.end_year} • Score: ${era.score}"),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to deep dive view
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
