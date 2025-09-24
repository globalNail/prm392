import 'base_entity.dart';

class Account extends BaseEntity {
  final String name;
  final String email;

  Account({required super.id, required this.name, required this.email});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(id: json['id'], name: json['name'], email: json['email']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}
