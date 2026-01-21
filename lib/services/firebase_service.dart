import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Auth Operations ---
  Stream<User?> get user => _auth.authStateChanges();

  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    final user = _auth.currentUser;
    if (user != null) {
      if (displayName != null) await user.updateDisplayName(displayName);
      
      // Store in Firestore to avoid Auth photoURL length limits for base64
      await _db.collection('users').doc(user.uid).set({
        'displayName': displayName ?? user.displayName,
        'photoUrl': photoUrl,
        'email': user.email,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      await user.reload();
    }
  }

  Stream<DocumentSnapshot> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // --- Storage Operations (FREE VERSION: Using Base64) ---
  Future<String> uploadImage(File imageFile, String folderName) async {
    try {
      // Baca file sebagai bytes
      final bytes = await imageFile.readAsBytes();
      
      // Cek ukuran file (Firestore punya limit 1MB per dokumen)
      if (bytes.lengthInBytes > 800000) {
        throw 'Ukuran gambar terlalu besar (Maksimal 800KB untuk versi gratis ini)';
      }

      // Berikan prefix data URI agar Flutter bisa langsung mengenalinya sebagai gambar
      String base64Image = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64Image';
    } catch (e) {
      print('Error processing image: $e');
      rethrow;
    }
  }

  // --- Firestore Operations ---
  
  // Get all items as a stream
  Stream<List<Item>> getItems() {
    return _db.collection('items').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Item.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Add a new item
  Future<void> addItem(Item item) async {
    await _db.collection('items').add(item.toMap());
  }

  // Update an existing item
  Future<void> updateItem(String id, Item item) async {
    await _db.collection('items').doc(id).update(item.toMap());
  }

  // Delete an item
  Future<void> deleteItem(String id) async {
    await _db.collection('items').doc(id).delete();
  }

  // Search items (simple client-side filtering can be done, but here's a basic query)
  Future<List<Item>> searchItems(String query) async {
    final snapshot = await _db.collection('items').get();
    return snapshot.docs
        .map((doc) => Item.fromMap(doc.data(), doc.id))
        .where((item) =>
            item.title.toLowerCase().contains(query.toLowerCase()) ||
            item.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
