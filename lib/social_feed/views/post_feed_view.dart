import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:secure_alert/service/global.dart';
import 'package:secure_alert/social_feed/models/post_model.dart';
import 'package:secure_alert/social_feed/views/add_edit_view.dart';
import 'package:secure_alert/utils/bottom_navigation.dart';
import 'package:secure_alert/utils/custom_widgets.dart';

import '../../service/firebase.dart';
import '../components/post_card.dart';

class PostFeedScreen extends StatefulWidget {
  const PostFeedScreen({super.key});

  @override
  State<PostFeedScreen> createState() => _PostFeedScreenState();
}

const kGoogleApiKey = '<GoogleApiKEY>';

class _PostFeedScreenState extends State<PostFeedScreen> {
  List<Post> initPostList = [];
  List<Post> postList = [];

  TextEditingController controller = TextEditingController();
  String uID = "0";
  final Mode _mode = Mode.overlay;
  String filter = "";
  bool onLoading = true;
  String? selectedLocation;

  getAlldata() async {
    initPostList = await getPostList();
    postList = initPostList;
    setState(() {
      print("hello1: $postList");
      onLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getAlldata();
    if (Global.instance.user!.isLoggedIn) {
      uID = Global.instance.user!.uId!;
    }
  }

  List<String> filterType = ['Recent', 'Priority'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Global.instance.user!.isLoggedIn
          ? customAppBarAction(
              title: 'Post Feed',
              actions: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditPost(isEdit: false)));
                  },
                  icon: const Icon(Icons.add)),
                  )
          : customAppBar(title: "Post Feed"),
      body: onLoading
          ? const Text("Scroll Updown to refresh")
          : Container(
              constraints: const BoxConstraints(maxHeight: double.infinity),
              child: RefreshIndicator(
                edgeOffset: 0,
              displacement: 200,
              backgroundColor: Colors.red.shade900,
              color: Colors.white,
              strokeWidth: 2,
                  onRefresh: () {
                    return Future.delayed(const Duration(seconds: 1), () {
                      setState(() {
                        postList = initPostList;
                        postList.sort(
                            (b, a) => a.dateCreated!.compareTo(b.dateCreated!));
                        getPostCard(postList);
                      });
                    });
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    getFilterPopUp();
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.filter_alt_rounded,
                                      color: Colors.red.shade900,
                                    ),
                                    Text(
                                      "Filter List",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.red.shade900),
                                    )
                                  ],
                                ))
                          ],
                        ),
                      ),
                      Expanded(
                          child: ListView(
                        children: [getPostCard(postList)],
                      ))
                    ],
                  )),
            ),
            
      bottomNavigationBar:
          const CustomBottomNavigationBar(defaultSelectedIndex: 3),
    );
  }

  getPostCard(List postList) {
    print('$postList');
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: postList.length,
        itemBuilder: (BuildContext context, int index) {
          return PostCard(
              post: postList[index],
              controller: controller,
              onComment: (val, id) async {
                DatabaseReference commentRef = FirebaseDatabase.instance
                    .ref()
                    .child('post')
                    .child(id)
                    .child('comments');

                String commentID = commentRef.push().key!;
                await commentRef.child(commentID).set({
                  'userID': uID,
                  'dateCreated':
                      DateFormat('d MM, yyyy, h:mm a').format(DateTime.now()),
                  'comment': val
                });
                //refresh data
                setState(() {
                  FocusManager.instance.primaryFocus?.unfocus();
                  controller.clear();
                  onLoading = true;
                });
                await getAlldata();
              });
        });
  }

  getFilterPopUp() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enter Location'),
            scrollable: true,
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    selectFilterField(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text("OR"),
                    ),
                    getLocationField()
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.red.shade900)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          );
        });
  }

  selectFilterField() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: 200,
        padding: const EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.red.shade900)),
        child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedBorder: InputBorder.none),
                style: TextStyle(color: Colors.red.shade900, fontSize: 16),
                isExpanded: true,
                items: filterType.map((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
                validator: (value) {
                  if (filter == null) {
                    return "Please select";
                  }
                  return null;
                },
                onChanged: (value) {
                  filter = value.toString();
                  getFilterList(filter);
                })),
      ),
    );
  }

  getFilterList(String filter) {
    switch (filter) {
      case "Recent":
        postList = initPostList;
        postList.sort((a, b) => a.dateCreated!.compareTo(b.dateCreated!));
        setState(() {
          getPostCard(postList);
        });
        break;
      case "Priority":
        postList = initPostList;
        postList.sort((a, b) => a.priority!.compareTo(b.priority!));
        setState(() {
          getPostCard(postList);
        });
        break;
    }
  }

  getLocationField() {
    return Container(
      padding: const EdgeInsets.only(bottom: 19),
      child: OutlinedButton(
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.red.shade900))),
              backgroundColor: MaterialStateProperty.all(Colors.grey.shade200),
              padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 15))),
          onPressed: _handlePressButton,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: Colors.red.shade900,
                    size: 15,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Text(
                    selectedLocation ?? "Enter Location",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                )
              ],
            ),
          )),
    );
  }

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        language: 'en',
        mode: _mode,
        strictbounds: false,
        types: [""],
        logo: Container(
          height: 1,
        ),
        decoration: InputDecoration(
            hintText: 'Enter the loctaion of the Incident',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white))),
        components: [
          Component(Component.country, "usa"),
          Component(Component.country, "in")
        ]);

    selectedLocation = p!.terms[0].value;
    postList = [];
    for (var post in initPostList) {
      if (post.location == selectedLocation) {
        postList.add(post);
      }
    }

    setState(() {
      if (postList.isEmpty) {
        Fluttertoast.showToast(msg: "No post for such location");
      } else {
        print(postList[0].location);
        getPostCard(postList);
      }
    });
  }
}
