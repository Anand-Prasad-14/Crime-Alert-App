import 'package:flutter/material.dart';

AppBar customAppBar(
    {String? title,
    IconButton? iconButton,
    Color? textColor,
    PreferredSizeWidget? bottomBar}) {
  return AppBar(
    leading: iconButton,
    title: Center(
        child: Text(
      title!,
      style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
    )),
    backgroundColor: Colors.red[900],
    iconTheme: const IconThemeData(color: Colors.white),
    bottom: bottomBar,
  );
}

AppBar customAppBarAction(
    {String? title,
    IconButton? iconButton,
    Color? textColor,
    PreferredSizeWidget? bottomBar,
    Widget? actions}) {
  return AppBar(
    leading: iconButton,
    title: Center(
        child: Text(
      title!,
      style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
    )),
    backgroundColor: Colors.red.shade900,
    iconTheme: const IconThemeData(color: Colors.white),
    bottom: bottomBar,
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: actions ??
            const IconButton(
              icon: Icon(Icons.arrow_left_rounded),
              iconSize: 0,
              onPressed: null,
            ),
      )
    ],
  );
}
