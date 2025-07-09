import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/entry.dart';

class DatabaseService {
  late FirebaseFirestore _db;
  DatabaseService() {
    _db = FirebaseFirestore.instance;
  }

  FirebaseFirestore get db => _db;

  CollectionReference<Map<String, dynamic>> get entries => _db.collection('entries');

  Future<List<Entry>> getEntries() async {
    try {
      final snapshot = await entries.get();
      return snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              return Entry.fromJson(data);
            } catch (e) {
              log('Error parsing document ${doc.id}: $e');
              return null;
            }
          })
          .where((entry) => entry != null)
          .cast<Entry>()
          .toList();
    } catch (e) {
      log('Error fetching entries: $e');
      rethrow;
    }
  }

  Future<void> addEntry(Entry entry) async {
    await entries.doc(entry.id).set(entry.toJson());
  }

  Future<void> updateEntry(Entry entry) async {
    await entries.doc(entry.id).update(entry.toJson());
  }

  Future<void> deleteEntry(String id) async {
    await entries.doc(id).delete();
  }
}
