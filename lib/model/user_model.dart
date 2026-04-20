// ── Model ──────────────────────────────────────────────────────────────────
class UserModel {
  String userId;
  String userName;
  String userEmail;
  String? phoneNumber;
  String? photoUrl;
  String? category; // Personal | Business | Student | Other
  String status; // active | inactive
  String? userType; // active | inactive
  bool isAdmin;
  DateTime? createdAt;

  UserModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.phoneNumber,
    this.photoUrl,
    this.category,
    this.userType,
    this.status = 'active',
    this.isAdmin = false,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userId: json['userId'] as String? ?? '',
        userName: json['userName'] as String? ?? '',
        userEmail: json['userEmail'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String?,
        photoUrl: json['photoUrl'] as String?,
        category: json['category'] as String?,
        userType: json['userType'] as String?,
        status: json['status'] as String? ?? 'active',
        isAdmin: json['isAdmin'] as bool? ?? false,
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'phoneNumber': phoneNumber,
        'photoUrl': photoUrl,
        'category': category,
        'userType': userType,
        'status': status,
        'isAdmin': isAdmin,
        'createdAt': createdAt?.toIso8601String(),
      };

  UserModel copyWith({
    String? userName,
    String? phoneNumber,
    String? photoUrl,
    String? category,
    String? status,
    String? userType,
  }) =>
      UserModel(
        userId: userId,
        userName: userName ?? this.userName,
        userEmail: userEmail,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        photoUrl: photoUrl ?? this.photoUrl,
        category: category ?? this.category,
        status: status ?? this.status,
        isAdmin: isAdmin,
        createdAt: createdAt,
        userType: userType ?? this.userType,
      );
}
