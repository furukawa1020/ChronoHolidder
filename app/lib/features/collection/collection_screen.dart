import 'package:flutter/material.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for UI demo
    final stamps = [
      {"age": "Edo Period", "loc": "Tokyo Castle", "color": Colors.amber},
      {"age": "Jomon Period", "loc": "Sannai-Maruyama", "color": Colors.brown},
      {"age": "Cretaceous", "loc": "Fukui", "color": Colors.green},
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Time Collection")),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: stamps.length,
        itemBuilder: (context, index) {
          final s = stamps[index];
          return Card(
            color: (s["color"] as Color).withOpacity(0.2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 48, color: s["color"] as Color),
                SizedBox(height: 8),
                Text(s["age"] as String, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(s["loc"] as String, style: TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}
