// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: file_names

class UserEntity {
  String name;
  String email;
  String code;

  UserEntity({required this.name, required this.email, required this.code});

  @override
  String toString() {
    return 'User(name: $name, email: $email, codigo: $code)';
  }

  Map<String, String> getUserFjson() {
    return {'name': name, 'email': email, 'codigo': code};
  }
}
