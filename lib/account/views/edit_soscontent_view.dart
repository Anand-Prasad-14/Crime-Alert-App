import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:secure_alert/account/models/info_model.dart';
import 'package:secure_alert/account/views/account_screen.dart';
import 'package:secure_alert/service/firebase.dart';
import 'package:secure_alert/service/global.dart';
import 'package:secure_alert/utils/custom_widgets.dart';
import 'package:secure_alert/utils/theme.dart';

import '../../authenticate/models/user_model.dart';
import '../components/edit_info_popup.dart';

class EditSOSContent extends StatefulWidget {
  const EditSOSContent({super.key});

  @override
  State<EditSOSContent> createState() => _EditSOSContentState();
}

class _EditSOSContentState extends State<EditSOSContent> {
  final _formKey = GlobalKey<FormState>();

  DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref().child('sos');

  List<Info> infoList = [];
  bool haveInfo = false;

  String? sample;
  String? location;
  User user = Global.instance.user!;
  String message = "SOS! Immediate Help required:";
  String additionalInfo = "";

  getInfo() async {
  var data = await getSOSData(user.uId!);

  if (data != null && data.containsKey("info") && data["info"] is List) {
    List<dynamic> infoData = data["info"];
    for (var dt in infoData) {
      Map<dynamic, dynamic> info = dt;
      if (info.isNotEmpty) {
        infoList.add(Info(info.keys.first.toString(), info.values.first.toString()));
      }
    }
    setState(() {
      haveInfo = true;
    });
  } else {
    // Handle the case where data["info"] is null or not in the expected format
    print("Error: 'info' data is null or not in the expected format.");
  }
}


  getMessage() async {
    location = await getLocation();
    setState(() {
      message += "\nName: ${user.firstName!} \n$location";
    });
  }

  getLocation() async {
    final position = await _determinePosition();
    return "Longitude: ${position.longitude} and Latitude: ${position.latitude}";
  }

  @override
  void initState() {
    getMessage();
    getInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: 'Edit SOS Content'),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(25, 50, 25, 10),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                      child: Column(
                    children: [
                      getTextField(
                          text: message!, label: 'Message', readonly: true),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          color: Colors.grey.shade200,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Add Additional Content",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        getPopUp();
                                      },
                                      icon: Icon(
                                        Icons.add_circle,
                                        size: 30,
                                        color: Colors.red.shade900,
                                      ))
                                ],
                              ),
                              getAddedList()
                            ],
                          ),
                        ),
                      ),
                      showSampleMessage(),
                      getSubmitButton(),
                    ],
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  getSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
      child: Container(
        decoration: ThemeHelper().buttonBoxDecoration(context),
        child: ElevatedButton(
          style: ThemeHelper().buttonStyle(),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              DatabaseReference sosRef = databaseReference.child(user.uId!);
              await sosRef.child('info').remove();

              for (var i = 0; i < infoList.length; i++) {
                sosRef
                    .child('info')
                    .child("$i")
                    .set({infoList[i].type: infoList[i].description});
              }

              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const AccountScreen()),
                  (route) => false);
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
            child: Text(
              "Submit".toUpperCase(),
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  getPopUp() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return EditInfoPopup(onAdd: (value) {
            setState(() {
              infoList.add(value);
              print(infoList);
              haveInfo = true;
              additionalInfo += "\n${value.type}:"
                  "\n${value.description},";
            });
          });
        });
  }

  getAddedList() {
    return Visibility(
        visible: haveInfo,
        child: Container(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            height: 150,
            color: Colors.white,
            child: ListView.builder(
                itemCount: infoList.length,
                itemBuilder: (BuildContext context, int index) {
                  additionalInfo = "";
                  for (var element in infoList) {
                    additionalInfo += "\n${element.type}: "
                        "\n${element.description}";
                  }

                  return Card(
                    child: ListTile(
                      title: Text(infoList[index].type),
                      subtitle: Text(infoList[index].description),
                      trailing: IconButton(
                          onPressed: () {
                            setState(() {
                              infoList.removeAt(index);

                              infoList = infoList
                                  .where((element) => element != null)
                                  .toList();

                              additionalInfo = "";
                              for (var element in infoList) {
                                additionalInfo += "\n${element.type}: "
                                    "\n${element.description},";
                              }
                            });
                          },
                          icon: const Icon(Icons.cancel_outlined)),
                    ),
                  );
                }),
          ),
        ));
  }

  showSampleMessage() {
    sample = message + additionalInfo;
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              "Sample Message",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            color: Colors.white,
            child: Text(sample!),
          )
        ],
      ),
    );
  }

  getTextField({String? text, String? label, bool? readonly}) {
    TextEditingController controller = TextEditingController();
    controller.text = text!;
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
      child: TextFormField(
        controller: controller,
        minLines: 4,
        maxLines: 6,
        readOnly: readonly ?? false,
        decoration: ThemeHelper().textInputDecoration(),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Location permission are denied ');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }
}
