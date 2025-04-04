class UserModel {
  final String uid;
  final String email;
  final String name;
  final String telefone;
  final String userType;
  final double rating;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.telefone,
    this.userType = 'cliente',
    this.rating = 0.0,
  });
}