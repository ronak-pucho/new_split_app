class GroupModel {
  String groupId;
  String groupName;
  String groupType;
  List<String> friends;
  Map<String, dynamic>? unreadCounts;
  bool isActive;

  GroupModel({
    required this.groupId,
    required this.groupName,
    required this.groupType,
    required this.friends,
    this.unreadCounts,
    this.isActive = true,
  });

  // Factory constructor for creating a new GroupModel instance from JSON
  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        groupId: json["groupId"],
        groupName: json["groupName"],
        groupType: json["groupType"],
        friends: List<String>.from(json["friends"] ?? []),
        unreadCounts: json["unreadCounts"] != null
            ? Map<String, dynamic>.from(json["unreadCounts"])
            : null,
        isActive: json["isActive"] ?? true,
      );

  // Method to convert the GroupModel instance to a JSON object
  Map<String, dynamic> toJson() => {
        "groupId": groupId,
        "groupName": groupName,
        "groupType": groupType,
        "friends": friends,
        "isActive": isActive,
        if (unreadCounts != null) "unreadCounts": unreadCounts,
      };
}
