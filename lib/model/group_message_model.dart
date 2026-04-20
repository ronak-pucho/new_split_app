import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessageModel {
  final String messageId;
  final String senderId;
  final String senderName;
  final String text;
  final bool isExpense;
  final double? expenseAmount;
  final String? expenseDescription;
  final int? totalMembers;
  final List<String> unreadBy;
  final DateTime timestamp;

  GroupMessageModel({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.isExpense = false,
    this.expenseAmount,
    this.expenseDescription,
    this.totalMembers,
    this.unreadBy = const [],
    required this.timestamp,
  });

  factory GroupMessageModel.fromJson(Map<String, dynamic> json) => GroupMessageModel(
        messageId: json['messageId'] ?? '',
        senderId: json['senderId'] ?? '',
        senderName: json['senderName'] ?? 'Unknown',
        text: json['text'] ?? '',
        isExpense: json['isExpense'] ?? false,
        expenseAmount: double.tryParse((json['expenseAmount'] ?? '').toString()),
        expenseDescription: json['expenseDescription'],
        totalMembers: json['totalMembers'],
        unreadBy: json['unreadBy'] != null ? List<String>.from(json['unreadBy']) : [],
        timestamp: json['timestamp'] != null ? (json['timestamp'] as Timestamp).toDate() : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'isExpense': isExpense,
        'expenseAmount': expenseAmount,
        'expenseDescription': expenseDescription,
        'totalMembers': totalMembers,
        'unreadBy': unreadBy,
        'timestamp': timestamp,
      };
}
