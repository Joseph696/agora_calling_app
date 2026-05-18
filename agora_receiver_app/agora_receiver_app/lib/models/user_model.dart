class UserModel {
  final String uid;
  final String name;
  final String email;
  final bool isOnline;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.isOnline,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      isOnline: map['isOnline'],
    );
  }
}