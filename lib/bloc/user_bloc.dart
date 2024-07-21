import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/user_repository.dart';

class UserState {
  final User? firebaseUser;
  final bool isLoading;
  final String? error;
  final bool isAdmin;
  final List<Map<String, dynamic>> studentClubs;
  final List<Map<String, dynamic>> followedClubs;
  final bool isFollowing;
  final bool followStatusChanged;

  UserState({
    this.firebaseUser,
    this.isLoading = false,
    this.error,
    this.isAdmin = false,
    this.studentClubs = const [],
    this.followedClubs = const [],
    this.isFollowing = false,
    this.followStatusChanged = false,
  });

  UserState copyWith({
    User? firebaseUser,
    bool? isLoading,
    String? error,
    bool? isAdmin,
    List<Map<String, dynamic>>? studentClubs,
    List<Map<String, dynamic>>? followedClubs,
    bool? isFollowing,
    bool? followStatusChanged,
  }) {
    return UserState(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAdmin: isAdmin ?? this.isAdmin,
      studentClubs: studentClubs ?? this.studentClubs,
      followedClubs: followedClubs ?? this.followedClubs,
      isFollowing: isFollowing ?? this.isFollowing,
      followStatusChanged: followStatusChanged ?? this.followStatusChanged,
    );
  }
}

class UserCubit extends Cubit<UserState> {
  final userrepo = UserRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserCubit() : super(UserState());

  Future<void> getCurrentUser() async {
    try {
      emit(UserState(isLoading: true));
      User? firebaseUser = await userrepo.getCurrentUser();

      if (firebaseUser != null) {
        emit(state.copyWith(
          firebaseUser: firebaseUser,
          isLoading: false,
        ));
      } else {
        emit(UserState(isLoading: false));
      }
    } catch (e) {
      emit(UserState(error: e.toString(), isLoading: false));
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      emit(UserState(isLoading: true, isAdmin: false));
      await userrepo.signInWithEmailAndPassword(email, password);
      User? user = await userrepo.getCurrentUser();

      if (user != null) {
        final doc = await _firestore.collection('admins').doc(user.uid).get();
        if (doc.exists) {
          emit(UserState(error: 'Admin girişinden giriniz', isLoading: false, isAdmin: true));
        } else {
          emit(state.copyWith(firebaseUser: user, isLoading: false));
        }
      } else {
        emit(UserState(error: 'Kullanıcı bulunamadı', isLoading: false));
      }
    } catch (e) {
      emit(UserState(error: e.toString(), isLoading: false));
    }
  }


  Future<void> signUpWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      emit(UserState(isLoading: true));
      await userrepo.signUpWithEmailAndPassword(email, password, displayName);
      await getCurrentUser();
    } catch (e) {
      emit(UserState(error: e.toString(), isLoading: false));
    }
  }


  Future<void> navigateToProfile(BuildContext context) async {
    await userrepo.navigateToProfile(context);
  }

  Future<void> getStudentClubs() async {
    try {
      emit(state.copyWith(isLoading: true));
      List<Map<String, dynamic>> clubs = await userrepo.getStudentClubs();
      emit(state.copyWith(studentClubs: clubs, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> getFollowedClubs() async {
    try {
      emit(state.copyWith(isLoading: true));
      User? user = await userrepo.getCurrentUser();
      if (user != null) {
        List<Map<String, dynamic>> followedClubs = await userrepo.getFollowedClubs(user);
        emit(state.copyWith(followedClubs: followedClubs, isLoading: false));
      } else {
        emit(state.copyWith(error: 'Kullanıcı bulunamadı', isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> updateFollowStatus(String clubId, Map<String, dynamic> club) async {
    try {
      emit(state.copyWith(isLoading: true));
      User? user = await userrepo.getCurrentUser();
      if (user != null) {
        bool isFollowing = await userrepo.isFollowingClub(user, clubId);
        await userrepo.updateFollowStatus(user, clubId, club, isFollowing);
        await getFollowedClubs();
      } else {
        emit(state.copyWith(error: 'Kullanıcı bulunamadı', isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> isFollowingClub(String clubId) async {
    //TODO şurayı çözcez, studentclubs ve clubdetailscreen'de bloc düzgünce kullanmamız lazım
    try {
      emit(state.copyWith(isLoading: true));
      User? user = await userrepo.getCurrentUser();
      if (user != null) {
        bool isFollowing = await userrepo.isFollowingClub(user, clubId);
        emit(state.copyWith(isFollowing: isFollowing, isLoading: false));
      } else {
        emit(state.copyWith(error: 'Kullanıcı bulunamadı', isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void followStatusChanged() {
    emit(state.copyWith(followStatusChanged: !state.followStatusChanged));
  }


  Future<void> signOut() async {
    try {
      emit(UserState(isLoading: true));
      await userrepo.signOut();
      emit(UserState(firebaseUser: null, isLoading: false, error: null));
    } catch (e) {
      emit(UserState(error: e.toString(), isLoading: false));
    }
  }

}
