/// id : 123
/// name : 'coco'
/// image : 'https://...'
/// createTime : 1202151321
/// updateTime : 1203551322

class User {
  int? id;
  String? name;
  String? image;
  int? createTime;
  int? updateTime;
  String? passwordHash;

  User({
    this.id,
    this.name,
    this.image,
    this.createTime,
    this.updateTime,
    this.passwordHash,
  });

  User.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    createTime = json['createtime'];
    updateTime = json['updatetime'];
    passwordHash = json['passwordHash'] ?? json['passwordhash'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['image'] = image;
    map['createTime'] = createTime;
    map['updateTime'] = updateTime;
    map['passwordHash'] = passwordHash;
    return map;
  }

  static List<User> listFromJson(List<dynamic>? json) {
    return json == null
        ? <User>[]
        : json.map((dynamic e) => User.fromJson(e)).toList();
  }
}
