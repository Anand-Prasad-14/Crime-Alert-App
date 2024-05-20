import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SendEmail extends StatefulWidget {
  final String title;

  SendEmail({Key? key, required this.title}) : super(key: key);

  @override
  State<SendEmail> createState() => _SendEmailState();
}

class _SendEmailState extends State<SendEmail> {
  String? message;
  String? email;

  final databaseReference = FirebaseDatabase.instance.ref().child('feedback');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    _fetchUserEmail();
    super.initState();
  }

  void _fetchUserEmail() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        email = user.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Send ${widget.title}',
        style: const TextStyle(color: Color.fromARGB(255, 192, 43, 43)),
      ),
      scrollable: true,
      content: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Form(
          child: Column(
            children: <Widget>[
              getEmailField(),
              getMessageField(),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
          ),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.red.shade900),
          ),
          child: const Text(
            "Send",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            _uploadFeedback();
          },
        )
      ],
    );
  }

  Widget getEmailField() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        initialValue: email,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: "Email Address",
          hintText: "Enter the email address",
        ),
        onChanged: (val) {
          setState(() {
            email = val;
          });
        },
        validator: (val) {
          if (val!.isEmpty) {
            return "Email Address is required";
          }
          return null;
        },
      ),
    );
  }

  Widget getMessageField() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        minLines: 8,
        maxLines: 12,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          labelText: "Enter the ${widget.title} message",
        ),
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

  void _uploadFeedback() async {
    if (email != null && message != null) {
      try {
        await databaseReference.push().set({
          'email': email,
          'message': message,
          'title': widget.title,
          'timestamp': DateTime.now().toString(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback sent successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and Message are required')),
      );
    }
  }
}
