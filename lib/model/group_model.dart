class GroupModel {
  String groupId;
  String groupName;
  String groupType;
  List<String> friends; // Represents the list of group members

  GroupModel({
    required this.groupId,
    required this.groupName,
    required this.groupType,
    required this.friends,
  });

  // Factory constructor for creating a new GroupModel instance from JSON
  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        groupId: json["groupId"],
        groupName: json["groupName"],
        groupType: json["groupType"],
        friends: List<String>.from(json["friends"] ?? []),
      );

  // Method to convert the GroupModel instance to a JSON object
  Map<String, dynamic> toJson() => {
        "groupId": groupId,
        "groupName": groupName,
        "groupType": groupType,
        "friends": friends, // Ensure friends are included in the JSON
      };
}
