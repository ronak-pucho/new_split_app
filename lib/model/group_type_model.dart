class GroupTypeModel {
  final String id;
  final String name;
  final DateTime createdAt;

  GroupTypeModel({required this.id, required this.name, required this.createdAt});

  factory GroupTypeModel.fromJson(Map<String, dynamic> json) => GroupTypeModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        createdAt: json['createdAt'] != null ? json['createdAt'].toDate() : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt,
      };
}
