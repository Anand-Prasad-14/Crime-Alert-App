import 'package:flutter/material.dart';
import 'package:secure_alert/utils/theme.dart';

class SendEmail extends StatefulWidget {
  String title;

  SendEmail({
    Key? key,
    required this.title
  }) : super(key: key);
  

  @override
  State<SendEmail> createState() => _SendEmailState();
}

class _SendEmailState extends State<SendEmail> {
  String? message;
  String? email;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('send ${widget.title}'),
      scrollable: true,
      content: Padding(padding: const EdgeInsets.all(5.0),
      child: Form(child: Column(
        children: <Widget>[
          getEmailField(),
          getMessageField()
        ],
      )),),
      actions: [
        ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
        child: const Text("Cancel", style: TextStyle(
          color: Colors.white
        ),),
        onPressed: () {
          Navigator.of(context).pop();
        },
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.red.shade900)
          ),
          child: const Text("Send", style: TextStyle(
            color: Colors.white
          ),),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  getEmailField(){
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: ThemeHelper().textInputDecoration("Email Address", "Enter the email address"),
        onChanged: (val){
          setState(() {
            email = val;
          });
        },
        validator: (val) {
          if (val!.isEmpty){
            return "Emial Address is required";
          }
          return null;
        },
      ),
    );
  }

  getMessageField(){
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
      child: TextFormField(
        minLines: 8,
        maxLines: 12,
        keyboardType: TextInputType.multiline,
        decoration: ThemeHelper().textInputDecoReport("Enter the ${widget.title} message"),
        onChanged: (val) {
          setState(() {
            message = val;
          });
        },
        validator: (val) {
          if (val!.isEmpty) {
            return "Message Content is empty";
          }
          return null;
        },
      ),
    );
  }
}