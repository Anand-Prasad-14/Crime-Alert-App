import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:secure_alert/account/components/contact_popup.dart';
import 'package:secure_alert/account/models/contact_model.dart';
import 'package:secure_alert/service/global.dart';
import 'package:secure_alert/utils/custom_widgets.dart';

class ManageEmergencyContact extends StatefulWidget {
  const ManageEmergencyContact({super.key});

  @override
  State<ManageEmergencyContact> createState() => _ManageEmergencyContactState();
}

class _ManageEmergencyContactState extends State<ManageEmergencyContact> {
  List<Contact> contactList = [];
  bool haveContact = false;
  String uID = Global.instance.user!.uId!;

  var contactRef;

  getContactList() async {
    contactList = [];
    contactRef = FirebaseDatabase.instance.ref().child('contacts').child(uID);
    await contactRef.onValue.listen((event) async {
      for (final child in event.snapshot.children) {
        String id = await json.decode(json.encode(child.key));
        Map data = await json.decode(json.encode(child.value));

        contactList.add(
            Contact(id, data["firstName"], data["relation"], data["phone"]));
      }
      setState(() {
        haveContact = true;
      });
    }, onError: (error) {
      print('Error getting contacts');
    });
  }

  @override
  void initState() {
    super.initState();
    getContactList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppBar(title: "Manage Contacts"),
        body: haveContact
            ? ListView.builder(
                itemCount: contactList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 10),
                    child: Card(
                      child: ListTile(
                        leading: Text(contactList[index].relation!),
                        title: Text(contactList[index].fname!),
                        subtitle: Text(contactList[index].contactNo!),
                        trailing: Container(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    getContactForm(contactList[index]);
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.green.shade900,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      contactRef
                                          .child(contactList[index].id!)
                                          .remove();
                                      Fluttertoast.showToast(
                                          msg: "Contact deleted Successfully");
                                      contactList = [];
                                    });
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red.shade900,
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                })
            : Container(
                child: const Text(
                  'No contacts added yet!',
                  style: TextStyle(fontSize: 20),
                ),
              ));
  }

  getContactForm(Contact contact) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return EmergencyContact(
              mapEdit: contact,
              onEdit: (value) {
                DatabaseReference contactRef = FirebaseDatabase.instance
                    .ref()
                    .child('contacts')
                    .child(uID);

                contactRef.child(value.id!).update({
                  'firstName': value.fname,
                  'relation': value.relation,
                  'phone': value.contactNo
                });
                Fluttertoast.showToast(
                    msg: "Contact Details updated Successfully");
                contactList = [];
              });
        });
  }
}
