import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:secure_alert/service/global.dart';

class SosSettingsPopUp extends StatefulWidget {
  const SosSettingsPopUp({super.key});

  @override
  State<SosSettingsPopUp> createState() => _SosSettingsPopUpState();
}

class _SosSettingsPopUpState extends State<SosSettingsPopUp> {
  DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref().child('sos');
  String uID = Global.instance.user!.uId!;

  bool messageEnabled = false;

  fetchUserSetting() async {
    DatabaseReference sosRef = databaseReference.child(uID).child('setting');
    final snapshot = await sosRef.get();
    if (snapshot.exists) {
      return snapshot.value;
    } else {
      return null;
    }
  }

  getMessageEnabled() async {
    Map data = await fetchUserSetting();
    if (data.isNotEmpty) {
      setState(() {
        messageEnabled = data["messageContact"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getMessageEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Additional SOS Settings'),
      scrollable: true,
      content: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Form(
            child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: getCheckBox(),
            )
          ],
        )),
      ),
      actions: [
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black)),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            )),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.red.shade900)),
            onPressed: () {
              setState(() {
                DatabaseReference sosRef =
                    databaseReference.child(uID).child("setting");
                sosRef.set({'messageContact': messageEnabled});
                Navigator.of(context).pop();
              });
            },
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ))
      ],
    );
  }

  getCheckBox() {
    return FormField<bool>(builder: (state) {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: <Widget>[
                Checkbox(
                    activeColor: Colors.red.shade900,
                    value: messageEnabled,
                    onChanged: (value) {
                      setState(() {
                        messageEnabled = value!;
                        state.didChange(value);
                      });
                    }),
                Text(
                  "Also send SOS message"
                  "\nto emergency contacts",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                )
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              state.errorText ?? '',
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 12),
            ),
          )
        ],
      );
    });
  }
}
