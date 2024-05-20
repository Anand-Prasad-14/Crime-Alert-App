import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secure_alert/authenticate/models/user_model.dart';
import 'package:secure_alert/service/firebase.dart';
import 'package:secure_alert/service/global.dart';
import 'package:secure_alert/social_feed/views/my_post_view.dart';
import 'package:secure_alert/social_feed/views/post_feed_view.dart';
import 'package:secure_alert/utils/custom_widgets.dart';
import 'package:secure_alert/utils/theme.dart';

import '../../service/api.dart';

class EditPost extends StatefulWidget {
  var isEdit;

  EditPost({required this.isEdit, Key? key}) : super(key: key);

  @override
  State<EditPost> createState() => _EditPostState();
}

const kGoogleApiKey = 'AIzaSyBZFVz_dHpmtiJbjIyipcJgiCQ173xYylE';

class _EditPostState extends State<EditPost> {
  final _formKey = GlobalKey<FormState>();

  User user = Global.instance.user!;
  String? postId;
  String? fname, avatar, title, content, dateCreated;
  String? location;
  String? priority;
  List<String> media = [];

  bool haveImage = false;
  bool haveEditImage = false;

  bool isEdit = false;
  final ImagePicker imagePicker = ImagePicker();
  List<XFile> imageFileList = [];
  List<String> imageFileListEdit = [];

  void selectImages() async {
    final List<XFile> selectImages = await imagePicker.pickMultiImage();
    if (selectImages.isNotEmpty) {
      imageFileList.addAll(selectImages);
    }
    print("Image List Length:${imageFileList.length}");
    setState(() {
      haveImage = true;
    });
  }

  List<String> priorityList = [
    'Missing Person',
    'Missing Pet',
    'Missing Vehicle / Product',
    'Alert',
    'Informative',
    'Charity / Donation'
        'Announcements'
  ];

  final Mode mode = Mode.overlay;

  getPostDataDetails() async {
    var data = await getPostData(postId!);
    title = data["title"];
    content = data["content"];
    priority = priorityList[data["priority"]];
    location = data["location"];
    if (data['media'] != null) {
      for (var i = 0; i < data['media'].length; i++) {
        if (data['media'][i] != null) {
          imageFileListEdit.add(data["media"][i]["file"]);
        }
      }
      haveEditImage = true;
      print(imageFileListEdit);
    }
    setState(() {
      isEdit = true;
    });
  }

  @override
  void initState() {
    super.initState();
    fname = user.firstName;
    avatar = user.avatar;
    if (widget.isEdit != false) {
      postId = widget.isEdit;
      getPostDataDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: isEdit ? "Edit Post" : "Add New Post",
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    getLocationField(),
                    selectPurposeField(),
                    getTextField(
                      text: title,
                      isEdit: isEdit,
                      decoration: ThemeHelper().textInputDecoReport(
                          'Enter title of the post',
                          null,
                          Colors.grey.shade200),
                      onChanged: (value) {
                        title = value;
                      },
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: getTextField(
                            minLines: 5,
                            maxLines: 8,
                            text: content,
                            isEdit: isEdit,
                            keyboardType: TextInputType.multiline,
                            decoration: ThemeHelper().textInputDecoReport(
                                'Write the post content..',
                                null,
                                Colors.grey.shade200),
                            onChanged: (value) {
                              content = value;
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter the content";
                              }
                              return null;
                            },
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    selectImages();
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.image_outlined,
                                        color: Colors.red.shade900,
                                      ),
                                      Text(
                                        "Attach Images",
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.red.shade900),
                                      ),
                                    ],
                                  ))
                            ],
                          ),
                        ),
                        Visibility(
                            visible: haveImage,
                            child: Container(
                              height: 250,
                              padding: const EdgeInsets.only(bottom: 20),
                              child: GridView.builder(
                                  itemCount: imageFileList.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Stack(
                                        children: <Widget>[
                                          Image.file(
                                            File(imageFileList[index].path),
                                            fit: BoxFit.cover,
                                          ),
                                          Positioned(
                                              top: 0,
                                              right: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    imageFileList
                                                        .removeAt(index);
                                                  });
                                                },
                                                child: const Icon(Icons.clear),
                                              ))
                                        ],
                                      ),
                                    );
                                  }),
                            )),
                        Visibility(
                            visible: haveEditImage,
                            child: Container(
                              height: 250,
                              padding: const EdgeInsets.only(bottom: 20),
                              child: GridView.builder(
                                  itemCount: imageFileListEdit.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Stack(
                                        children: <Widget>[
                                          Image.network(
                                            (imageFileListEdit[index]),
                                            fit: BoxFit.cover,
                                          ),
                                          Positioned(
                                              top: 0,
                                              right: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    imageFileListEdit
                                                        .removeAt(index);
                                                  });
                                                },
                                                child: const Icon(Icons.clear),
                                              ))
                                        ],
                                      ),
                                    );
                                  }),
                            )),
                        getSubmitCancelButton()
                      ],
                    )
                  ],
                )),
          )
        ],
      ),
    );
  }

  getSubmitCancelButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ThemeHelper().getCustomButton(
          text: "Cancel",
          padding: 45,
          background: Colors.black,
          fontSize: 16,
          onPressed: () {
            setState(() {
              if (isEdit) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const PostScreen()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PostFeedScreen()),
                );
              }
            });
          },
        ),
        ThemeHelper().getCustomButton(
            text: isEdit ? "Save" : "Upload",
            padding: 45,
            background: Colors.red.shade900,
            fontSize: 16,
            onPressed: isEdit
                ? () async {
                    if (_formKey.currentState!.validate()) {
                      String uID = user.uId!;

                      DatabaseReference postRef = FirebaseDatabase.instance
                          .ref()
                          .child('post')
                          .child(postId!);

                      int prior = priorityList.indexOf(priority!);

                      await postRef.update({
                        'location': location,
                        'priority': prior,
                        'title': title,
                        'content': content
                      });

                      DatabaseReference mediaRef = postRef.child('media');

                      //check if post has previous images
                      int index = 0;
                      if (haveEditImage) {
                        index = imageFileListEdit.length;
                      } else {
                        index = 0;
                      }

                      //upload if new media is added
                      if (imageFileList.isNotEmpty) {
                        var url;
                        imageFileList.forEach((file) async {
                          url = await uploadXImage(file: file);
                          await mediaRef
                              .child(index.toString())
                              .set({'file': url});
                          index++;
                        });
                      }

                      Fluttertoast.showToast(msg: "Post Updated successfully");
                      setState(() {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PostScreen()));
                      });
                    }
                  }
                : () async {
                    if (_formKey.currentState!.validate()) {
                      String uID = user.uId!;

                      DatabaseReference postRef =
                          FirebaseDatabase.instance.ref().child('post');
                      String postID = postRef.push().key!;

                      int prior = priorityList.indexOf(priority!);

                      //upload post data in database
                      await postRef.child(postID).set({
                        'userID': uID,
                        'userName': fname,
                        'avatar': avatar,
                        'location': location,
                        'dateCreated': DateTime.now().toString(),
                        'priority': prior,
                        'title': title,
                        'content': content
                      });

                      //upload media if post have
                      if (imageFileList.isNotEmpty) {
                        DatabaseReference mediaRef =
                            postRef.child(postID).child('media');
                        var url;
                        int index = 0;
                        imageFileList.forEach((file) async {
                          url = await uploadXImage(file: file);
                          await mediaRef
                              .child(index.toString())
                              .set({'file': url});
                          index++;
                        });
                      }

                      Fluttertoast.showToast(
                          msg: "New Post Uploaded successfully");
                      setState(() {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PostFeedScreen()));
                      });
                    }
                  })
      ],
    );
  }

  selectPurposeField() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: 400,
        padding: const EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.grey.shade400)),
        child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedBorder: InputBorder.none),
                isExpanded: true,
                hint: const Text(
                  "Please select the purpose of the post",
                  style: TextStyle(fontSize: 15),
                ),
                value: priority,
                items: priorityList.map((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
                validator: (value) {
                  if (priority == null) {
                    return "Please select the purpose";
                  }
                  return null;
                },
                onChanged: (value) {
                  priority = value.toString();
                })),
      ),
    );
  }

  getLocationField() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
          onPressed: _handlePressButton,
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.grey.shade900))),
              backgroundColor: MaterialStateProperty.all(Colors.grey.shade200),
              padding: MaterialStateProperty.all(const EdgeInsets.all(15))),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.red.shade900,
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                height: 18,
                width: 255,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Text(
                      location ?? "Enter the Location of the Incident",
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 15),
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        language: 'en',
        mode: mode,
        strictbounds: false,
        types: [""],
        logo: Container(
          height: 1,
        ),
        decoration: InputDecoration(
            hintText: 'Enter the Location of the Incident',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white))),
        components: [
          Component(Component.country, "usa"),
          Component(Component.country, "in")
        ]);
     if (p != null) {
    setState(() {
      location = p.terms[0].value;
      print(p);
    });
  }
  }
}
