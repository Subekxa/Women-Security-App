
class UserModel {
  String? name;
  String? id;
  String? phone;
  String? childEmail;
  String? parentEmail;
  String? type;

  UserModel({
  this.name,
  this.childEmail,
  this.id,
  this.parentEmail,
  this.phone,
  this.type});

  Map<String,dynamic> toJson() => {
    'name' : name,
    'id' : id,
    'phone' : phone,
    'childEmail' : childEmail,
    'parentEmail' : parentEmail,
    'type' : type,

  };
  

}