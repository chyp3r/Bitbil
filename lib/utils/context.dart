import 'package:flutter/material.dart';

extension Context on BuildContext {
  void navigateBack() => Navigator.pop(this);
  Future navigate(String routeName) => Navigator.pushNamed(this, routeName);
  Future navigateRemoveUntil(String routeName) =>
      Navigator.of(this).pushNamedAndRemoveUntil(routeName, (_) => false);
  void showMessage(String text) =>
      ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(text)));
}
