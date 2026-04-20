class AccountRequestModel {
  final String requestId;
  final String userId;
  final String userEmail;
  final String userName;
  final String message;
  final String status; // 'pending' | 'resolved'
  final DateTime timestamp;
  final String? adminReply;
  final DateTime? adminReplyTime;

  AccountRequestModel({
    required this.requestId,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.message,
    this.status = 'pending',
    required this.timestamp,
    this.adminReply,
    this.adminReplyTime,
  });

  factory AccountRequestModel.fromJson(Map<String, dynamic> json) =>
      AccountRequestModel(
        requestId: json['requestId'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        userEmail: json['userEmail'] as String? ?? '',
        userName: json['userName'] as String? ?? '',
        message: json['message'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
            : DateTime.now(),
        adminReply: json['adminReply'] as String?,
        adminReplyTime: json['adminReplyTime'] != null
            ? DateTime.tryParse(json['adminReplyTime'].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'userId': userId,
        'userEmail': userEmail,
        'userName': userName,
        'message': message,
        'status': status,
        'timestamp': timestamp.toIso8601String(),
        if (adminReply != null) 'adminReply': adminReply,
        if (adminReplyTime != null) 'adminReplyTime': adminReplyTime!.toIso8601String(),
      };
}
