import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronoholidder/data/collection_repository.dart';
import 'package:chronoholidder/data/models.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  late Future<List<EraScore>> _collectionFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _collectionFuture = ref.read(collectionRepositoryProvider).loadCollection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Time Collection"),
        actions: [
          IconButton(onPressed: _refresh, icon: Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder<List<EraScore>>(
        future: _collectionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading collection"));
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No Time Layers Collected Yet.", style: TextStyle(color: Colors.grey)),
                  Text("Go excavate some history!", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (item.image_url != null)
                      Image.network(item.image_url!, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.brown.shade200))
                    else
                      Container(color: Colors.brown.shade200, child: Icon(Icons.history_edu, size: 48, color: Colors.white)),
                    
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.black.withOpacity(0.7),
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(item.era_name, style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text("${item.start_year} AD", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                       top: 8,
                       right: 8,
                       child: Container(
                         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                         decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
                         child: Text("SCORE ${item.score.toInt()}", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                       ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
