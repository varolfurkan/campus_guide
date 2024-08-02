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
    DocumentSnapshot adminDoc = await _firestore.collection('admins').doc(user.uid).get();
    return adminDoc.exists;
  }

  Future<String?> getAdminName(User user) async {
    DocumentSnapshot adminDoc = await _firestore.collection('admins').doc(user.uid).get();
    if (adminDoc.exists) {
      return adminDoc['adminName'] as String?;
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
        // Kulübün güncel durumunu alıyoruz
        final clubId = doc.id;
        final clubSnapshot = await _firestore.collection('student_clubs').doc(clubId).get();
        if (clubSnapshot.exists) {
          Map<String, dynamic> clubData = clubSnapshot.data() as Map<String, dynamic>;
          followedClubs.add(clubData);
        }
      }
      return followedClubs;
    } catch (e) {
      throw Exception('Failed to fetch followed clubs: $e');
    }
  }

  Future<void> updateFollowStatus(User user, String clubId, Map<String, dynamic> club, bool isFollowing) async {
    final clubRef = FirebaseFirestore.instance.collection('student_clubs').doc(clubId);
    final followedClubRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('followed_clubs').doc(clubId);

    try {
      // Kulübün güncel durumunu alıyoruz
      final clubSnapshot = await clubRef.get();
      final int membersCount = (clubSnapshot.data()?['members'] ?? 0) as int;

      if (isFollowing) {
        // Takipten çıkma işlemi
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          // Kulübün güncel verisini alma
          final clubSnapshot = await transaction.get(clubRef);
          if (!clubSnapshot.exists) {
            throw Exception("Kulüp bulunamadı");
          }

          // Mevcut üyeleri güncelleme
          final updatedMembersCount = (clubSnapshot.data()?['members'] ?? 0) - 1;
          transaction.update(clubRef, {'members': updatedMembersCount});
        });

        // Kullanıcıdan kulübü kaldırma
        await followedClubRef.delete();
      } else {
        // Takip etmeye başlama işlemi
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          // Kulübün güncel verisini alma
          final clubSnapshot = await transaction.get(clubRef);
          if (!clubSnapshot.exists) {
            throw Exception("Kulüp bulunamadı");
          }

          // Mevcut üyeleri güncelleme
          final updatedMembersCount = (clubSnapshot.data()?['members'] ?? 0) + 1;
          transaction.update(clubRef, {'members': updatedMembersCount});
        });

        // Kullanıcının takip ettiği kulübü ekleme
        await followedClubRef.set({
          'id': clubId,
          'title': club['title'],
          'description': club['description'],
          'img': club['img'],
          'contactInfo': club['contactInfo'],
          'type': club['type'],
          'management': club['management'],
          'events': club['events'],
          'members': (club['members'] ?? 0) + 1,
        });
      }
    } catch (e) {
      print('Hata: $e');
      throw Exception('Takip durumu güncellenirken bir hata oluştu: $e');
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
