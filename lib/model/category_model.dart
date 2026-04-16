class CategoryModel {
  final String categoryId;
  final String categoryName;
  final DateTime? createdAt;

  CategoryModel({
    required this.categoryId,
    required this.categoryName,
    this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        categoryId: json['categoryId'] as String? ?? '',
        categoryName: json['categoryName'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'categoryName': categoryName,
        'createdAt': createdAt?.toIso8601String(),
      };
}
