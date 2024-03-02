import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:secure_alert/service/global.dart';

import 'package:shared_preferences/shared_preferences.dart';

final databaseReference = FirebaseDatabase.instance.ref();

//Users functionalities

Future signIn(String email, String password) async {
  try {
    User? user = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password)).user;

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("userID", user!.uid);
    return user.uid;
  } catch (e) {
    Fluttertoast.showToast(msg: e.toString());
    print(e);
    return false;
  }
}

Future createAccount(String email, String password, String iNo) async {
  try {
    User? user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password)).user;
    return user!.uid;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      Fluttertoast.showToast(msg: "The password provided is too weak.");
    } else if (e.code == 'email already exists') {
      Fluttertoast.showToast(msg: "The account is already exists for that email.");
    }
    return false;
  } catch (e) {
    print(e.toString());
  }
}

Future<String> fetchUserID() async {
  final User? user = FirebaseAuth.instance.currentUser;
  return user!.uid;
}

Future signOut() async {
  await FirebaseAuth.instance.signOut();
  await Global.instance.logout();
}


Future checkUserExists(String idNo) async{
  bool isDuplicate = false;
  final snapshot = await databaseReference.child('users').get();
  if (snapshot.exists) {
    Map data = await json.decode(json.encode(snapshot.value));

    for (var element in data.values) {
      if(element["iNo"] == idNo){
        isDuplicate = true;
      }
    }
    return isDuplicate;
  } else {
    return isDuplicate;
  }
}

Future getUserData(String userID) async {
  final snapshot = await databaseReference.child('users/$userID').get();
  if (snapshot.exists) {
    print(snapshot.value);
    return snapshot.value;
  } else {
    print('No data available');
  }
}

//Post methods
Future getPostData(String postID) async {
  final snapshot = await databaseReference.child('post/$postID').get();
  if (snapshot.exists) {
    print(snapshot.value);
    return snapshot.value;
  } else {
    print('No data available');
  }
}

