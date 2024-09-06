class User {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String password;
  final String role;

  // Constructeur nommé
  const User(
      {required this.id,
      required this.email,
      required this.password,
      required this.nom,
      required this.prenom,
      required this.role});
}
