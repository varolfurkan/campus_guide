class UserModel {
  final String uid;
  final String displayName;
  final String email;

  UserModel({required this.uid, required this.displayName, required this.email});

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
    };
  }

}
