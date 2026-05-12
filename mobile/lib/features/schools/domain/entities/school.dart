class School {
  final String id;
  final String name;
  final String? logoImage;
  final String type;
  final String phone;
  final String? role;

  School({
    required this.id,
    required this.name,
    required this.logoImage,
    required this.type,
    required this.phone,
    required this.role,
  });

  factory School.fromJson(Map<String, dynamic> json) => School(
    id: json['id'],
    name: json['name'],
    logoImage: json['logo_image'],
    type: json['type'],
    phone: json['phone'],
    role: json['role'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logo_image': logoImage,
    'type': type,
    'phone': phone,
    'role': role,
  };
}
