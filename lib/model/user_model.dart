

class UserModel {
  final String name;
  final String uid;
  final String profilePics;
  final bool isOnline;
  final String phoneNumber;
  final List<String> groupId;



  UserModel(
      {required this.name,
      required this.uid,
      required this.profilePics,
      required this.isOnline,
      required this.phoneNumber,
      required this.groupId});


  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map["name"] ??'',
      uid: map["uid"]??'',
      profilePics: map["profilePics"] ??'',
      isOnline: map["isOnline"].toLowerCase() == false,
      phoneNumber: map["phoneNumber"] ??'',
      groupId: List<String>.from(map["groupId"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "uid": uid,
      "profilePics": profilePics,
      "isOnline": isOnline,
      "phoneNumber": phoneNumber,
      "groupId": groupId,
    };
  }
}
