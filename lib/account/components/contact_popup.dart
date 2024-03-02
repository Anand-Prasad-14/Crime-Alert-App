import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:secure_alert/service/global.dart';
import 'package:secure_alert/utils/theme.dart';

import '../models/contact_model.dart';

class EmergencyContact extends StatefulWidget {
  final mapEdit;
  final Function(Contact) onEdit;

  const EmergencyContact(
      {Key? key, required this.mapEdit, required this.onEdit})
      : super(key: key);

  @override
  State<EmergencyContact> createState() => _EmergencyContactState();
}

class _EmergencyContactState extends State<EmergencyContact> {
  bool isEdit = false;

  String? id;
  String? fname = "";
  String? relation = "";
  String? mobileNo = "";

  String uID = Global.instance.user!.uId!;

  Contact? contact;
  List<String> type = [
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Husband',
    'Wife',
    'Son',
    'Daughter',
    'Guardian',
    'other'
  ];

  @override
  void initState() {
    if (widget.mapEdit != null) {
      isEdit = true;
      id = widget.mapEdit.id;
      fname = widget.mapEdit.fname;
      relation = widget.mapEdit.relation;
      mobileNo = widget.mapEdit.mobileNo;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: isEdit
          ? const Text('Edit Emergency Contact')
          : const Text('Add Emergency Contact'),
      scrollable: true,
      content: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Form(
            child: Column(
          children: <Widget>[
            getTextField(
                text: fname,
                label: 'Full Name',
                hint: 'Enter the name of the person',
                valError: 'Please enter the name',
                onChanged: (value) {
                  fname = value;
                }),
            isEdit ? editRelationField() : relationField(),
            getTextField(
                text: mobileNo,
                label: 'Mobile No',
                hint: 'Enter the contact no. of the person',
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Please enter the contact no.";
                  } else if ((val.isNotEmpty) &&
                      !RegExp(r"^(\d+)*$").hasMatch(val)) {
                    return "Enter a valid mobile no.";
                  }
                  return null;
                },
                onChanged: (value) {
                  mobileNo = value;
                })
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
          ),
        ),
        isEdit
            ? ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.red.shade900)),
                onPressed: () {
                  setState(() {
                    var contact = Contact(id!, fname!, relation!, mobileNo);
                    widget.onEdit(contact);
                    Navigator.of(context).pop();
                  });
                },
                child:
                    const Text("Update", style: TextStyle(color: Colors.white)))
            : ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.red.shade900)),
                onPressed: () {
                  setState(() {
                    DatabaseReference contactRef = FirebaseDatabase.instance
                        .ref()
                        .child('contact')
                        .child(uID);

                    String contactID = contactRef.push().key!;

                    contactRef.child(contactID).set({
                      'fname': fname,
                      'relation': relation,
                      'mobileNo': mobileNo,
                    });

                    Fluttertoast.showToast(
                        msg: "New Contact Added Successfully");
                    Navigator.of(context).pop();
                  });
                },
                child: const Text(
                  "Add",
                  style: TextStyle(color: Colors.white),
                ))
      ],
    );
  }

  relationField() {
    return Container(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          width: 400,
          padding: const EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.grey.shade400)),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedBorder: InputBorder.none),
              isExpanded: true,
              hint: const Text("Please select your relation"),
              items: type.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              validator: (value) {
                if (relation == null) {
                  return "Please select your relation";
                }
                return null;
              },
              onChanged: (value) {
                relation = value.toString();
              },
            ),
          ),
        ));
  }

  editRelationField() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: 400,
        padding: const EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.grey.shade400)),
        child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                isExpanded: true,
                value: relation!,
                hint: const Text("Please select your relation"),
                items: type.map((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (relation == null) {
                    return "Please select your relation";
                  }
                  return null;
                },
                onChanged: (value) {
                  relation = value.toString();
                })),
      ),
    );
  }

  getTextField(
      {String? text,
      String? label,
      String? hint,
      String? valError,
      Function(String)? onChanged,
      bool? obsureText,
      String? Function(String?)? validator}) {
    TextEditingController controller = TextEditingController();
    controller.text = text!;

    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: isEdit ? controller : null,
        decoration: ThemeHelper().textInputDecoration(label!, hint!),
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
}
