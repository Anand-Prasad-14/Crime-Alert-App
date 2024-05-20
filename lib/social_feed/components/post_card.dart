import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:secure_alert/service/global.dart';
import 'package:secure_alert/utils/theme.dart';

import '../../authenticate/models/user_model.dart';
import '../models/post_model.dart';
import 'comment_card.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final Function(String, String) onComment;
  final TextEditingController controller;

  const PostCard(
      {Key? key,
      required this.post,
      required this.controller,
      required this.onComment})
      : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool haveImage = false;
  String comment = "";
  User user = User();
  bool haveComment = false;
  String uID = "0";

  @override
  void initState() {
    if (widget.post.media.isNotEmpty) {
      haveImage = true;
    }
    if (widget.post.comments.isNotEmpty) {
      haveComment = true;
    }
    if (Global.instance.user!.isLoggedIn) {
      uID = Global.instance.user!.uId!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade300,
      elevation: 0.0,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: GestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Container(
                width: 50.0,
                height: 50.0,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(widget.post.avatar!),
                        fit: BoxFit.cover),
                    borderRadius: const BorderRadius.all(Radius.circular(40.0)),
                    border: Border.all(color: Colors.black, width: 1.0)),
              ),
              title: uID == widget.post.userId
                  ? Text("${widget.post.firstName!} (me)")
                  : Text(widget.post.firstName!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('d MMM yyyy, h:mm a')
                      .format(widget.post.dateCreated!)),
                  Text(
                    widget.post.location!,
                    style: TextStyle(color: Colors.red.shade900),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 15, top: 15, right: 15),
              child: Text(
                widget.post.title!,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
              child: Text(
                widget.post.content!,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            Visibility(
                visible: haveImage,
                child: SizedBox(
                 height: 270,
              
                  
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              mainAxisSpacing: 8.0,
                              crossAxisSpacing: 8.0,
                              ),
                              itemCount: widget.post.media.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            widget.post.media[index],
                            fit: BoxFit.cover,
                          ),
                        );
                      }),
                )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      padding: const EdgeInsets.only(left: 2),
                      onPressed: () {
                        showCommentSheet();
                      },
                      icon: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${!haveComment ? 0 : widget.post.comments.length}",
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                          Icon(
                            Icons.mode_comment_outlined,
                            color: Colors.red.shade900,
                          )
                        ],
                      ))
                ],
              ),
            ),
            Visibility(
                visible: Global.instance.user!.isLoggedIn,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: getTextField(
                      hint: 'Write a comment..',
                      onChanged: (val) {
                        comment = val;
                      }),
                ))
          ],
        ),
      ),
    );
  }

  getTextField(
      {String? text,
      String? label,
      String? hint,
      String? valError,
      Function(String)? onChanged,
      bool? obscureText,
      String? Function(String?)? validator}) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
      child: TextFormField(
        controller: widget.controller,
        decoration: ThemeHelper().textInputDecoReport(
            hint!,
            IconButton(
                onPressed: () {
                  widget.onComment(comment, widget.post.postId!);
                },
                icon: const Icon(Icons.check))),
        onChanged: onChanged,
        validator: validator ??
            (val) {
              if (val!.isEmpty) {
                return valError;
              }
              return null;
            },
      ),
    );
  }

  showCommentSheet() {
    return showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 500,
            child: Center(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Comments",
                            style: TextStyle(
                                fontSize: 22, color: Colors.red.shade900)),
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close))
                      ],
                    ),
                  ),
                  haveComment
                      ? ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: widget.post.comments.length,
                          itemBuilder: (BuildContext context, int index) {
                            return CommentCard(
                                comment: widget.post.comments[index]);
                          })
                      : const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("No comments yet!"),
                        )
                ],
              ),
            ),
          );
        });
  }
}
