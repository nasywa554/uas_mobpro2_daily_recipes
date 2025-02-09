class UserModel {
  final String id; // ID pengguna
  final String username; // Nama pengguna
  final String email; // Email pengguna
  final String profileImage; // URL gambar profil pengguna

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.profileImage,
  });

  // Metode untuk mengonversi dari Map ke UserModel
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] as String,
      username: data['username'] as String,
      email: data['email'] as String,
      profileImage: data['profile_image'] as String,
    );
  }

  // Metode untuk mengonversi dari UserModel ke Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profile_image': profileImage,
    };
  }
}
