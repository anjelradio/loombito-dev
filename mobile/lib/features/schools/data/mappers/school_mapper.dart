import 'package:mobile/features/schools/domain/domain.dart';

class SchoolMapper {
  static School schoolJsonToEntity(Map<String, dynamic> json) => School(
    id: json['id'],
    name: json['name'],
    logoImage: json['logo_image'],
    type: json['type'],
    phone: json['phone'],
    role: json['role'],
  );
}
