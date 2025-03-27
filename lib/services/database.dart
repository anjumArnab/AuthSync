import 'package:authsync/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DatabaseService({required this.uid});

  // Reference to the Firestore collection
  late final CollectionReference _userDataCollection =
      _firestore.collection('users');

  // Function to save user data to Firestore
  Future<void> saveUserData(UserModel user) async {
    try {
      await _userDataCollection.doc(uid).set(user.toMap());
    } catch (e) {
      throw Exception('Error saving user data: $e');
    }
  }

  // Function to get user data from Firestore
  Future<UserModel?> getUserData() async {
    try {
      DocumentSnapshot doc = await _userDataCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }

  // Function to update user data in Firestore
  Future<void> updateUserData(Map<String, dynamic> updatedData) async {
    try {
      await _userDataCollection.doc(uid).update(updatedData);
    } catch (e) {
      throw Exception('Error updating user data: $e');
    }
  }
}
