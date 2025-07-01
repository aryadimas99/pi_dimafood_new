import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // REGISTER USER (Default role: user)
  Future<User?> registerUser({
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': fullName,
          'email': email,
          'role': 'user', // default role
        });

        await user.updateDisplayName(fullName);
        await user.reload();
        return _auth.currentUser;
      }
    } catch (e) {
      print('Error saat register: $e');
    }
    return null;
  }

  // LOGIN USER
  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error saat login: $e');
      return null;
    }
  }

  // GET ROLE DARI FIRESTORE
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc['role'] != null) {
        return doc['role'];
      }
    } catch (e) {
      print('Error ambil role: $e');
    }
    return null;
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
