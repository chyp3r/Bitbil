class UserModel {
  final String uid;
  final String email;
  final String name;
  final String surname;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.surname,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'surname': surname,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
    );
  }
}
