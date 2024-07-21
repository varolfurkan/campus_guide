import 'package:campus_guide/models/user_model.dart';
import 'package:campus_guide/screens/student_profile.dart';
import 'package:campus_guide/screens/admin_screen.dart';
import 'package:campus_guide/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  Future<bool> isAdmin(User user) async {
    final doc = await _firestore.collection('admins').doc(user.uid).get();
    return doc.exists;
  }

  Future<String?> getAdminName(User user) async {
    final doc = await _firestore.collection('admins').doc(user.uid).get();
    if (doc.exists) {
      return doc.data()?['adminName'];
    }
    return null;
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      throw Exception('E-posta veya şifre hatalı.');
    } catch (e) {
      throw Exception('Giriş sırasında bir hata oluştu.');
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)
          .then((userCredential) async {
        User? user = userCredential.user;
        await user?.updateDisplayName(displayName);
        if (user != null) {
          UserModel newUser = UserModel(uid: user.uid, displayName: displayName, email: email);
          await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        }
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Bu e-posta adresi ile zaten bir kullanıcı kayıtlı.');
      } else {
        throw Exception('Kayıt sırasında bir hata oluştu.');
      }
    } catch (e) {
      throw Exception('Kayıt sırasında bir hata oluştu.');
    }
  }


  Future<void> navigateToProfile(BuildContext context) async {
    User? user = await getCurrentUser();

    if (user != null) {
      final doc = await _firestore.collection('admins').doc(user.uid).get();
      if (doc.exists) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AdminScreen()),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const StudentProfile()),
        );
      }
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) =>  const LoginScreen()),
      );
    }
  }


  Future<List<Map<String, dynamic>>> getStudentClubs() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('student_clubs').get();
      List<Map<String, dynamic>> clubs = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> clubData = doc.data() as Map<String, dynamic>;
        clubs.add(clubData);
      }
      return clubs;
    } catch (e) {
      throw Exception('Failed to fetch student clubs: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFollowedClubs(User user) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').doc(user.uid).collection('followed_clubs').get();
      List<Map<String, dynamic>> followedClubs = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> clubData = doc.data() as Map<String, dynamic>;
        followedClubs.add(clubData);
      }
      return followedClubs;
    } catch (e) {
      throw Exception('Failed to fetch followed clubs: $e');
    }
  }

  Future<void> updateFollowStatus(User user, String clubId, Map<String, dynamic> club, bool isFollowing) async {
    try {
      DocumentReference docRef = _firestore.collection('users').doc(user.uid).collection('followed_clubs').doc(clubId);
      if (isFollowing) {
        await docRef.delete();
      } else {
        await docRef.set({
          'id': clubId,
          'title': club['title'],
          'img': club['img'],
          'description': club['description'],
          'events': club['events'],
          'members': club['members'],
          'type': club['type'],
          // Başka kulüp bilgileri olacaksa onları da buraya eklicez
        });
      }
    } catch (e) {
      throw Exception('Failed to update follow status: $e');
    }
  }

  Future<bool> isFollowingClub(User user, String clubId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).collection('followed_clubs').doc(clubId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check follow status: $e');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

}
