import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a document to a collection
  Future<void> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collectionPath).add(data);
    } catch (e) {
      print('Error adding document: $e');
      rethrow;
    }
  }

  // Get all documents from a collection
  Future<Map<String, dynamic>> getUserProfile(String userUID) async {
    try {
      final userDoc =
          await _firestore.collection('userProfiles').doc(userUID).get();

      return userDoc.data() ?? {};
    } catch (e) {
      print('Error getting documents: $e');
      rethrow;
    }
  }

  // Update a document in a collection
  Future<void> updateDocument(
    String collectionPath,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).update(data);
    } catch (e) {
      print('Error updating document: $e');
      rethrow;
    }
  }

  // Delete a document from a collection
  Future<void> deleteDocument(String collectionPath, String docId) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).delete();
    } catch (e) {
      print('Error deleting document: $e');
      rethrow;
    }
  }

  // Listen to real-time updates in a collection
  Stream<QuerySnapshot> listenToCollection(String collectionPath) {
    return _firestore.collection(collectionPath).snapshots();
  }
}
