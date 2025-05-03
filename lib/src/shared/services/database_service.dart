import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  late FirebaseFirestore _db;
  DatabaseService() {
    _db = FirebaseFirestore.instance;
  }

  FirebaseFirestore get db => _db;

  get users => _db.collection('users');
  get entries => _db.collection('entries');

  // Future<void> addEntry(Entry entry) async {
  //   await FirebaseFirestore.instance.collection('users').doc(user.id).set(user.toJson());
  // }
}
