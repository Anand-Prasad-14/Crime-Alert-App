import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:secure_alert/authenticate/components/header_widget.dart';
import 'package:secure_alert/service/firebase.dart';
import 'package:secure_alert/service/global.dart';
import 'package:secure_alert/utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final double _headerHeight = 250;
  final Key _formKey = GlobalKey<FormState>();

  String email = "";
  String passwd = "";
  String? uId;

  Map? userInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: _headerHeight,
            child: HeaderWidget(_headerHeight),
          ),
          SafeArea(
              child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(children: [
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Sign In to your account',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(
                height: 30.0,
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      getTextField(
                          text: 'Email address',
                          hint: 'Enter your email',
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Please enter your email!';
                            } else if (val.isNotEmpty &&
                                !RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                    .hasMatch(val)) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              email = value;
                            });
                          }),
                      getTextField(
                          text: 'Password',
                          hint: 'Enter your password',
                          obscureText: true,
                          valError: 'Please enter your password',
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Please enter the password";
                            } else if (val.length <= 5) {
                              return "Password should be 6 characters or more";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              passwd = value;
                            });
                          }),
                      const SizedBox(
                        height: 15.0,
                      ),
                      getSignInButton(),
                      redirectToRegister()
                    ],
                  ))
            ]),
          ))
        ]),
      ),
    );
  }

  getTextField(
      {String? text,
      String? hint,
      String? valError,
      Function(String)? onChanged,
      String? Function(String?)? validator,
      bool? obscureText}) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
      child: TextFormField(
        obscureText: obscureText ?? false,
        decoration: ThemeHelper().textInputDecoration(text!, hint!),
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

  redirectToRegister() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: Text.rich(TextSpan(children: [
        const TextSpan(text: "Don't have an account? "),
        TextSpan(
            text: 'Create',
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushNamed(context, "/register");
              },
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.redAccent.shade700))
      ])),
    );
  }

  getSignInButton() {
    return Container(
      decoration: ThemeHelper().buttonBoxDecoration(context),
      child: ElevatedButton(
        style: ThemeHelper().buttonStyle(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
          child: Text(
            'Sign In'.toUpperCase(),
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        onPressed: () async {
          var value = await signIn(email, passwd);
          if (value != false) {
            uId = value;
            userInfo = await getUserData(uId!);
            Global.instance.user!.setUserInfo(uId!, userInfo!);

            Fluttertoast.showToast(msg: "User Logged In Successfully");
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/account', (route) => false);
          }
        },
      ),
    );
  }
}
