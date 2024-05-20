class User {
  bool isLoggedIn = false;
  String? uId;
  String? firstName;
  String? avatar;
  String? iNo;
  String? passwd;
  String? dob;
  String? email;
  String? mobileNo;
  String? address;
  String? country;
  String? state;
  String? city;
  String? zipcode;

  User();
  User.otherUser(this.avatar, this.firstName);

  void setUserInfo(String userID, Map data) {
    isLoggedIn = true;
    uId = userID;
    firstName = data['firstName'];
    iNo = data['iNo'];
    dob = data['dob'];
    avatar = data['avatar'];
    email = data['email'];
    mobileNo = data['phone'];
    address = data['address'];
    country = data['country'];
    state = data['state'];
    city = data['city'];
    zipcode = data['pincode'];
  }

  clearUserInfo() {
    isLoggedIn = false;
    uId = null;
    firstName = null;
    iNo = null;
    dob = null;
    avatar = null;
    email = null;
    mobileNo = null;
    address = null;
    country = null;
    state = null;
    city = null;
    zipcode = null;
  }
}
