import 'package:flutter/material.dart';
import 'package:secure_alert/utils/bottom_navigation.dart';
import 'package:secure_alert/utils/custom_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: 'Home Page'),
      // ignore: avoid_unnecessary_containers
      body: Container(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              homepageButton(
                  "Crime Alerts",
                  'Locate the crimes in the nearby areas',
                  '/crimeAlert',
                  Icons.map)
            ],
          ),
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              homepageButton(
                  "Post Feed",
                  'Get and share the latest info, missing reports, alerts and more',
                  '/postFeed',
                  Icons.person)
            ],
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(10, 30, 10, 0),
            child: Text(
              "For further information or assistance,",
              style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
          ),
          redirectToHelpCenter(),
        ]),
      ),
      bottomNavigationBar:
          const CustomBottomNavigationBar(defaultSelectedIndex: 2),
    );
  }

  Widget homepageButton(
      String text, String info, String routeName, IconData icon) {
    return GestureDetector(
      child: Container(
        width: 180,
        height: 200,
        decoration: BoxDecoration(
            color: Colors.red.shade900.withOpacity(0.1),
            borderRadius: const BorderRadius.all(Radius.circular(10.0))),
        child: Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 15, right: 10),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30, right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [iconDesign(icon)],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            text,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            width: 155,
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(
                              info,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade700),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ]),
        ),
      ),
      onTap: () async {
        Navigator.of(context).pushNamed(routeName);
      },
    );
  }

  Widget iconDesign(IconData icon) {
    return Container(
      width: 55,
      height: 55,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(40.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: Colors.red.shade900,
          )
        ],
      ),
    );
  }

  redirectToHelpCenter() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/helpCenter');
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: Text(
          'Go To Help Center',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.redAccent.shade700),
        ),
      ),
    );
  }
}
