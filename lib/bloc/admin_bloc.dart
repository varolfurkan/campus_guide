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

  AdminState({
    this.firebaseUser,
    this.isLoading = false,
    this.error,
    this.isAdmin = false,
    this.adminName,
    this.users,
  });

  AdminState copyWith({
    User? firebaseUser,
    bool? isLoading,
    String? error,
    bool? isAdmin,
    String? adminName,
    List<UserModel>? users,
  }) {
    return AdminState(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAdmin: isAdmin ?? this.isAdmin,
      adminName: adminName ?? this.adminName,
      users: users ?? this.users,
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

        emit(AdminState(
          firebaseUser: firebaseUser,
          isLoading: false,
          isAdmin: isAdmin,
          adminName: adminName,
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
