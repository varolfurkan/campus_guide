import 'package:campus_guide/models/clubs_model.dart';
import 'package:campus_guide/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/user_repository.dart';

class AdminState {
  final User? firebaseUser;
  final bool isLoading;
  final String? error;
  final bool isAdmin;
  final String? adminName;
  final List<UserModel>? users;
  final List<Club>? clubs;
  final List<Map<String, dynamic>>? notifications;
  final int unreadNotificationCount;
  final Set<String>? readNotifications;

  AdminState({
    this.firebaseUser,
    this.isLoading = false,
    this.error,
    this.isAdmin = false,
    this.adminName,
    this.users,
    this.clubs,
    this.notifications,
    this.unreadNotificationCount = 0,
    this.readNotifications,
  });

  AdminState copyWith({
    User? firebaseUser,
    bool? isLoading,
    String? error,
    bool? isAdmin,
    String? adminName,
    List<UserModel>? users,
    List<Club>? clubs,
    List<Map<String, dynamic>>? notifications,
    int? unreadNotificationCount,
    Set<String>? readNotifications,
  }) {
    return AdminState(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAdmin: isAdmin ?? this.isAdmin,
      adminName: adminName ?? this.adminName,
      users: users ?? this.users,
      clubs: clubs ?? this.clubs,
      notifications: notifications ?? this.notifications,
      unreadNotificationCount: unreadNotificationCount ?? this.unreadNotificationCount,
      readNotifications: readNotifications ?? this.readNotifications,
    );
  }
}


class AdminCubit extends Cubit<AdminState> {
  final userrepo = UserRepository();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminCubit() : super(AdminState());


  Future<void> getCurrentAdmin() async {
    try {
      emit(AdminState(isLoading: true));
      User? firebaseUser = await userrepo.getCurrentUser();

      if (firebaseUser != null) {
        bool isAdmin = await userrepo.isAdmin(firebaseUser);
        String? adminName = isAdmin ? await userrepo.getAdminName(firebaseUser) : null;
        List<Club>? clubs = await getClubsForAdmin(firebaseUser.uid);

        emit(AdminState(
          firebaseUser: firebaseUser,
          isLoading: false,
          isAdmin: isAdmin,
          adminName: adminName,
          clubs: clubs,
        ));
      } else {
        emit(AdminState(isLoading: false, isAdmin: false));
      }
    } catch (e) {
      emit(AdminState(error: e.toString(), isLoading: false));
    }
  }

  Future<void> signInAsAdmin(String email, String password) async {
    emit(state.copyWith(isLoading: true));
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if (user != null) {
        final doc = await _firestore.collection('admins').doc(user.uid).get();
        if (doc.exists) {
          emit(state.copyWith(firebaseUser: user, isLoading: false, isAdmin: true));
        } else {
          emit(state.copyWith(error: 'Admin hesabı bulunamadı', isLoading: false));
        }
      }
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(error: e.message, isLoading: false));
    }
  }

  Future<void> navigateToProfile(BuildContext context) async {
    await userrepo.navigateToProfile(context);
  }

  Future<List<Club>> getClubsForAdmin(String adminUid) async {
    emit(state.copyWith(isLoading: true));
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('student_clubs')
          .where('id', isEqualTo: adminUid)
          .get();

      List<Club> clubs = snapshot.docs.map((doc) => Club.fromMap(doc.data() as Map<String, dynamic>)).toList();
      emit(state.copyWith(clubs: clubs, isLoading: false));
      return clubs;
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
      return [];
    }
  }

  Future<void> addClub(Club club) async {
    try {
      emit(state.copyWith(isLoading: true));
      String? adminUid = state.firebaseUser?.uid;
      if (adminUid != null) {
        club = Club(
          id: adminUid,
          title: state.adminName ?? 'Kulüp Adı Bulunamadı',
          description: club.description,
          img: club.img,
          contactInfo: club.contactInfo,
          type: club.type,
          management: club.management,
          events: club.events,
          members: club.members,
        );
        await _firestore.collection('student_clubs').doc(adminUid).set(club.toMap());
        await getCurrentAdmin();
      } else {
        throw Exception('Admin UID is null');
      }
    } catch (e) {
      emit(AdminState(error: e.toString(), isLoading: false));
    }
  }

  Future<void> addEvent(String clubId, Map<String, dynamic> event) async {
    try {
      emit(state.copyWith(isLoading: true));
      await _firestore.collection('student_clubs').doc(clubId).update({
        'events': FieldValue.arrayUnion([event]),
      });
      emit(state.copyWith(isLoading: false));
      await getClubsForAdmin(state.firebaseUser?.uid ?? ''); // Refresh clubs
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> addNotification(Map<String, dynamic> notification) async {
    try {
      emit(state.copyWith(isLoading: true));
      await _firestore.collection('notifications').add(notification);
      emit(state.copyWith(isLoading: false));
      await getNotifications();
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> getNotifications() async {
    try {
      emit(state.copyWith(isLoading: true));
      QuerySnapshot snapshot = await _firestore.collection('notifications').get();
      List<Map<String, dynamic>> notifications = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
      int unreadCount = notifications.where((notification) => !(state.readNotifications?.contains(notification['id']) ?? false)).length;
      emit(state.copyWith(notifications: notifications, unreadNotificationCount: unreadCount, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }


  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      Set<String>? readNotifications = state.readNotifications ?? <String>{};
      readNotifications.add(notificationId);
      int unreadCount = state.notifications!.where((notification) => !readNotifications.contains(notification['id'])).length;
      emit(state.copyWith(readNotifications: readNotifications, unreadNotificationCount: unreadCount));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<List<Map<String, dynamic>>> getAdminNotifications(String adminUid) async {
    emit(state.copyWith(isLoading: true));
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('adminUid', isEqualTo: adminUid)
          .get();
      List<Map<String, dynamic>> notifications = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['documentId'] = doc.id;
        return data;
      }).toList();
      emit(state.copyWith(isLoading: false));
      return notifications;
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
      return [];
    }
  }


  Future<void> signOut() async {
    try {
      emit(AdminState(isLoading: true));
      await userrepo.signOut();
      emit(AdminState(firebaseUser: null, isLoading: false, error: null));
    } catch (e) {
      emit(AdminState(error: e.toString(), isLoading: false));
    }
  }

}
