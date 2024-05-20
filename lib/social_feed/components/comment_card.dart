import 'package:flutter/material.dart';
import 'package:secure_alert/authenticate/models/user_model.dart';
import 'package:secure_alert/service/firebase.dart';
import 'package:secure_alert/social_feed/models/comment_model.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  const CommentCard({Key? key, required this.comment}) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  User newUser = User();
  bool onLoading = true;

  getUser() async {
    Map data = await getUserData(widget.comment.userID);
    newUser = User.otherUser(data["avatar"], data["firstName"]);
    setState(() {
      onLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return onLoading
        ? const Text("Loading...")
        : ListTile(
            leading: Container(
              width: 40.0,
              height: 40.0,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(newUser.avatar!), fit: BoxFit.cover),
                  borderRadius: const BorderRadius.all(Radius.circular(40.0)),
                  border: Border.all(color: Colors.black, width: 1.0)),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  newUser.firstName!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 4, right: 4, bottom: 2),
                  child:  Text(widget.comment.comment),
                )
              ],
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Text(widget.comment.dateCreated)],
            ),
          );
  }
}
