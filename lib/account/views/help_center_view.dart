import 'package:flutter/material.dart';
import 'package:secure_alert/account/components/send_email.dart';
import 'package:secure_alert/utils/custom_widgets.dart';
import 'package:secure_alert/utils/theme.dart';

class HelpCenterView extends StatefulWidget {
  const HelpCenterView({super.key});

  @override
  State<HelpCenterView> createState() => _HelpCenterViewState();
}

class _HelpCenterViewState extends State<HelpCenterView> {
  double height = 0;
  double width = 0;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: customAppBar(
        title: "Help Center",
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
        child: ListView(
          children: [
            Container(
              color: Colors.grey.shade100,
              margin: const EdgeInsets.fromLTRB(25, 40, 25, 10),
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      "FAQs",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  getFAQItem("Homw to get the SOS menu bar?",
                      "SOS menu bar can be enabled by turning on switch in Accounts > Enable SOS Menu"),
                  getFAQItem("Why can't I comment on Posts",
                      "You will recieve an auto-reply from the Official Police email once your crime report is submitted.")
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.fromLTRB(25, 40, 25, 10),
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              alignment: Alignment.center,
              child: Column(children: [
                const Text(
                  "Still not sure of how to use the app? Click here to view"
                  "A step by step guide with pictures",
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: getButton("First time user guide", () {
                    Navigator.of(context).pushNamed('/guide');
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "OR",
                    style: TextStyle(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "Cannot find the solution to your problem in either one of those?"
                    "No worries! Just email us your journey",
                    textAlign: TextAlign.center,
                  ),
                ),
                getButton("Send Inquiry", () {
                  getSendInquiryPopUp();
                })
              ]),
            )
          ],
        ),
      ),
    );
  }

  getFAQItem(String title, String child) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
      textColor: Colors.red.shade900,
      iconColor: Colors.red.shade900,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: Colors.red.shade50,
            padding: const EdgeInsets.all(15),
            child: Text(
              child,
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    );
  }

  getButton(String text, Function()? onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        decoration: ThemeHelper().buttonBoxDecoration(context),
        child: ElevatedButton(
          style: ThemeHelper().buttonStyle(),
            onPressed: onPressed,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Text(
                  text.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ))),
      ),
    );
  }

  getSendInquiryPopUp() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SendEmail(title: "Inquiry");
        });
  }
}