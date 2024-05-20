import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:secure_alert/service/global.dart';
import 'package:secure_alert/social_feed/models/comment_model.dart';
import 'package:secure_alert/social_feed/models/post_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

final databaseReference = FirebaseDatabase.instance.ref();

//Users functionalities

Future signIn(String email, String password) async {
  try {
    User? user = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password))
        .user;

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
    User? user = (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password))
        .user;
    return user!.uid;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      Fluttertoast.showToast(msg: "The password provided is too weak.");
    } else if (e.code == 'email already exists') {
      Fluttertoast.showToast(
          msg: "The account is already exists for that email.");
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

Future checkUserExists(String idNo) async {
  bool isDuplicate = false;
  final snapshot = await databaseReference.child('users').get();
  if (snapshot.exists) {
    Map data = await json.decode(json.encode(snapshot.value));

    for (var element in data.values) {
      if (element["iNo"] == idNo) {
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

//SOS methods
Future getSOSData(String userId) async {
  final snapshot = await databaseReference.child('sos/$userId').get();
  if (snapshot.exists) {
    return snapshot.value;
  } else {
    print('No data available.');
  }
}

Future getRecipientContact(String userId) async {
  List<String> recipientList = [];
  final contactRef = FirebaseDatabase.instance.ref().child('contacts/$userId');
  await contactRef.onValue.listen((event) async {
    for (final child in event.snapshot.children) {
      final contactID = await json.decode(json.encode(child.key));
      Map data = await json.decode(json.encode(child.value));

      recipientList.add(data["phone"]);
    }
  });
  return recipientList;
}

Future<List<Post>> getPostList() async {
  List<Post> postList = [];
  final postRef = FirebaseDatabase.instance.ref().child('post');
  await postRef.onValue.listen((event) async {
    //fetch every post in database
    for (final child in event.snapshot.children) {
      List<String> postMedia = [];
      List<Comment> comments = [];

      //assign postID and post data
      final postID = await json.decode(json.encode(child.key));
      Map data = await json.decode(json.encode(child.value));

      //add media files to media list
      if (data['media'] != null) {
        for (var i = 0; i < data['media'].length; i++) {
          postMedia.add(data['media'][i]["file"]);
        }
      }

      //add comments to comment list
      if (data['comments'] != null) {
        var commentData = data['comments'];
        commentData.keys.forEach((key) {
          var commentID = key;
          var data = commentData[commentID];
          comments.add(Comment(commentID, data['dateCreated'], data['userID'],
              data['comment']));
        });
      }

      postList.add(Post(
          postId: postID,
          userId: data['userID'],
          firstName: data['userName'],
          location: data['location'],
          dateCreated: DateTime.parse(data['dateCreated']),
          avatar: data['avatar'],
          content: data['content'],
          priority: data['priority'],
          title: data['title'],
          media: postMedia,
          comments: comments));
    }
  }, onError: (error) {
    print('Error getting post List');
  });
  return postList;
}

Future<List<Post>> getMyPostList() async {
  List<Post> postList = [];
  final postRef = FirebaseDatabase.instance.ref().child('post');
  await postRef.onValue.listen((event) async {
    for (final child in event.snapshot.children) {
      List<String> postMedia = [];
      List<Comment> comments = [];

      //assign postID and post data to variable
      final postID = await json.decode(json.encode(child.key));
      Map data = await json.decode(json.encode(child.value));

      //condition to check if post created by current user
      if (Global.instance.user!.uId == data['userID']) {
        //add media files to medialist
        if (data['media'] != null) {
          for (var i = 0; i < data['media'].length; i++) {
            if (data['media'][i] != null) {
              postMedia.add(data['media'][i]["file"]);
            }
          }
        }

        //add comments to commentlist
        if (data['comments'] != null) {
          var commentData = data['comments'];
          commentData.keys.forEach((key) {
            var commentID = key;
            var data = commentData[commentID];
            comments.add(Comment(commentID, data['dateCreated'], data['userID'],
                data['comment']));
          });
        }

        //add the post to the postlist
        postList.add(Post(
            postId: postID,
            userId: data['userID'],
            firstName: data['userName'],
            location: data['location'],
            dateCreated: DateTime.parse(data['dateCreated']),
            avatar: data['avatar'],
            content: data['content'],
            priority: data['priority'],
            title: data['title'],
            media: postMedia,
            comments: comments));
      }
    }
  }, onError: (error) {
    print('Error getting post List');
  });
  return postList;
}

Future editAvatarPostList() async {
  final postRef = FirebaseDatabase.instance.ref().child('post');
  await postRef.onValue.listen((event) async {
    for (final child in event.snapshot.children) {
      final postID = await json.decode(json.encode(child.key));
      Map data = await json.decode(json.encode(child.value));

      //If post is created by currentuser
      if (Global.instance.user!.uId == data['userID']) {
        //update user avatar
        postRef.child(postID).update({
          "avatar": Global.instance.user!.avatar,
        });
      }
    }
  }, onError: (error) {
    print('Error getting post List');
  });
}
