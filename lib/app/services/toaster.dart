import 'package:flutter/material.dart';

extension ShowSnack on BuildContext {
  void success(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green.shade400,));
  }

  void error(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red,));
  }
  void toaster(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.black,));
  }
}