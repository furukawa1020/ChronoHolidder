import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chronoholidder/data/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final collectionRepositoryProvider = Provider((ref) => CollectionRepository());

class CollectionRepository {
  static const _key = 'user_collection';

  Future<List<EraScore>> loadCollection() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList = prefs.getStringList(_key) ?? [];
    
    return rawList.map((str) {
      try {
        return EraScore.fromJson(jsonDecode(str));
      } catch (e) {
        return null;
      }
    }).whereType<EraScore>().toList();
  }

  Future<void> addToCollection(EraScore item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentList = prefs.getStringList(_key) ?? [];
    
    // Check duplicates based on era_name + score (simple check)
    // In a real app, maybe check distinct ID.
    bool exists = currentList.any((str) {
      try {
        final existing = EraScore.fromJson(jsonDecode(str));
        return existing.era_name == item.era_name && existing.score == item.score;
      } catch (_) {
        return false;
      }
    });

    if (!exists) {
      currentList.add(jsonEncode(item.toJson()));
      await prefs.setStringList(_key, currentList);
    }
  }

  Future<void> clearCollection() async {
     final prefs = await SharedPreferences.getInstance();
     await prefs.remove(_key);
  }
}
