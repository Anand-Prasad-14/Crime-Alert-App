import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:secure_alert/service/global.dart';
import 'package:secure_alert/social_feed/components/post_card.dart';
import 'package:secure_alert/social_feed/models/post_model.dart';
import 'package:secure_alert/social_feed/views/add_edit_view.dart';
import 'package:secure_alert/utils/custom_widgets.dart';

import '../../service/firebase.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<Post> postList = [];

  TextEditingController controller = TextEditingController();
  String uID = Global.instance.user!.uId!;

  String? postID;
  var postRef = FirebaseDatabase.instance.ref().child('post');

  String filter = "";
  bool onLoading = true;
  String? selectedLocation;

  getAlldata() async {
    postList = [];
    postList = await getMyPostList().whenComplete(() => setState(() {
          //onLoading = false;
        }));
    setState(() {
      onLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getAlldata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: 'Post Feed'),
      body: onLoading
          ? Container()
          : Container(
              constraints: const BoxConstraints(maxHeight: double.infinity),
              child: RefreshIndicator(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: getInitialList(),
                      )
                    ],
                  ),
                  onRefresh: () {
                    return Future.delayed(const Duration(seconds: 1), () {
                      setState(() {});
                    });
                  }),
            ),
    );
  }

  getInitialList() {
    postList.sort((b, a) => a.dateCreated!.compareTo(b.dateCreated!));
    return getPostCard(postList);
  }

  getPostCard(List postList) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: postList.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditPost(isEdit: postList[index].postId)),
                        );
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.green,
                      )),
                  IconButton(
                      onPressed: () async {
                        //delete data from database
                        postRef.child(postList[index].postID).remove();
                        //get updated post list
                        postList = await getAlldata();
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.redAccent.shade700,
                      ))
                ],
              ),
              PostCard(
                  post: postList[index],
                  controller: controller,
                  onComment: (val, id) async {
                    DatabaseReference commentRef =
                        postRef.child(id).child('comments');
                    String commentID = commentRef.push().key!;

                    await commentRef.child(commentID).set({
                      'userID': uID,
                      'dateCreated': DateFormat('d MM, yyyy, h:mm a')
                          .format(DateTime.now()),
                      'comment': val
                    });

                    setState(() {
                      FocusManager.instance.primaryFocus?.unfocus();
                      controller.clear();
                      onLoading = true;
                    });
                    postList = await getAlldata();
                  })
            ],
          );
        });
  }
}
