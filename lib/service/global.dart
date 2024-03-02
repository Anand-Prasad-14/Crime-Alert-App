import 'package:secure_alert/service/firebase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../authenticate/models/user_model.dart';

class Global {
  static User? _user;
  static Global? _global;

  Global._internal();

  factory Global() {
    _global ??= Global._internal();
    return _global!;
  }

  static Global get instance {
    if (_global == null){
      throw 'Global Not Yet Instantiated With Config...';
    }
    return _global!;
  }

  init() async {
    _user = User();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? id = preferences.getString("userID");
    if (id != null) {
      Map userInfo = await getUserData(id);
      Global.instance.user!.setUserInfo(id, userInfo);
    }
  }

  User? get user {
    return _user;
  }

  Future logout() async {
    _user!.clearUserInfo();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove("userID");
  }
}