import 'package:flutter/material.dart';

PreferredSizeWidget Navbar(){
  return AppBar(
    actions: [Padding(child: Icon(Icons.settings),padding: EdgeInsets.all(10))],
    automaticallyImplyLeading: false,
    elevation: 0,
    scrolledUnderElevation: 0,
    shadowColor: Colors.transparent,
    backgroundColor: Colors.transparent,
  );
}