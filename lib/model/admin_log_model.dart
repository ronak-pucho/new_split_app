class AdminLogModel {
  final String logId;
  final String action;      // 'user_created' | 'user_deleted' | 'admin_login'
  final String? targetUid;
  final String? targetEmail;
  final String? adminUid;
  final String? oldData;
  final String? newData;
  final DateTime timestamp;

  AdminLogModel({
    required this.logId,
    required this.action,
    this.targetUid,
    this.targetEmail,
    this.adminUid,
    this.oldData,
    this.newData,
    required this.timestamp,
  });

  factory AdminLogModel.fromJson(Map<String, dynamic> json) => AdminLogModel(
        logId: json['logId'] as String? ?? '',
        action: json['action'] as String? ?? '',
        targetUid: json['targetUid'] as String?,
        targetEmail: json['targetEmail'] as String?,
        adminUid: json['adminUid'] as String?,
        oldData: json['oldData'] as String?,
        newData: json['newData'] as String?,
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'logId': logId,
        'action': action,
        'targetUid': targetUid,
        'targetEmail': targetEmail,
        'adminUid': adminUid,
        'oldData': oldData,
        'newData': newData,
        'timestamp': timestamp.toIso8601String(),
      };
}
