import 'package:flutter/material.dart';
import 'package:secure_alert/utils/theme.dart';

import '../models/info_model.dart';

class EditInfoPopup extends StatefulWidget {
  final Function(Info) onAdd;

  const EditInfoPopup({Key? key, required this.onAdd}) : super(key: key);

  @override
  State<EditInfoPopup> createState() => _EditInfoPopupState();
}

class _EditInfoPopupState extends State<EditInfoPopup> {
  String? description;
  String? type;

  Info? info;
  List<String> infoType = ['Medical', 'Other'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Additional Content'),
      scrollable: true,
      content: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Form(
            child: Column(
          children: <Widget>[selectTypeField(), getContentField()],
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
              info = Info(type!, description!);
              widget.onAdd(info!);
              Navigator.of(context).pop();
            },
            child: const Text(
              "Add",
              style: TextStyle(color: Colors.white),
            ))
      ],
    );
  }

  selectTypeField() {
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
                hint: const Text("Select type of detail"),
                items: infoType.map((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
                validator: (value) {
                  if (type == null) {
                    return "Please select the type of info";
                  }
                  return null;
                },
                onChanged: (value) {
                  type = value.toString();
                })),
      ),
    );
  }

  getContentField() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
      child: TextFormField(
        minLines: 3,
        maxLines: 5,
        keyboardType: TextInputType.multiline,
        decoration: ThemeHelper().textInputDecoReport(
            "Enter the additional details content to attach in the SOS SMS"),
        onChanged: (value) {
          setState(() {
            description = value;
          });
        },
        validator: (value) {
          if (value!.isEmpty) {
            return "Content is required";
          }
          return null;
        },
      ),
    );
  }
}
