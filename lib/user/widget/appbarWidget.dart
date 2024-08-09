import 'package:flutter/material.dart';

import '../listScreen.dart';

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    title: Text(
      'Profile Page',
      style: TextStyle(color: Colors.white),
    ),
    leading: BackButton(
      onPressed: () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ListScreen()));
      },
    ),
    backgroundColor: Colors.indigo[900],
    elevation: 0,
  );
}
