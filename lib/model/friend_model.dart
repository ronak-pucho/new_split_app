class FriendsModel {
  String fId;
  String userId;
  String fName;
  String lName;
  String fPhoneNumber;
  String fUpiId;
  String? description;
  int? amount;
  int? members;
  bool isExpenseDelete;
  bool isFriendsDelete;

  FriendsModel({
    required this.fId,
    required this.userId,
    required this.fName,
    required this.lName,
    required this.fPhoneNumber,
    required this.fUpiId,
    this.description,
    this.isExpenseDelete = false,
    this.isFriendsDelete = false,
    this.amount,
    this.members,
  });

  // Null-safe parsing: Firestore may omit bool fields on old docs
  factory FriendsModel.fromJson(Map<String, dynamic> json) => FriendsModel(
        fId: json['fId'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        fName: json['fName'] as String? ?? '',
        lName: json['lName'] as String? ?? '',
        fPhoneNumber: json['fPhoneNumber'] as String? ?? '',
        fUpiId: json['fUpiId'] as String? ?? '',
        description: json['description'] as String?,
        amount: (json['amount'] as num?)?.toInt(),
        members: (json['members'] as num?)?.toInt(),
        isExpenseDelete: json['isExpenseDelete'] as bool? ?? false,
        isFriendsDelete: json['isFriendsDelete'] as bool? ?? false,
      );

  get googlePayBarcode => null;

  Map<String, dynamic> toJson() => {
        'fId': fId,
        'userId': userId,
        'fName': fName,
        'lName': lName,
        'fPhoneNumber': fPhoneNumber,
        'fUpiId': fUpiId,
        'description': description,
        'amount': amount,
        'members': members,
        'isExpenseDelete': isExpenseDelete,
        'isFriendsDelete': isFriendsDelete,
      };
}
