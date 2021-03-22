import 'package:flutter/material.dart';
import 'package:ihikepakistan/purchase.dart';

void showUpgradeSnackbar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    behavior: SnackBarBehavior.floating,
    elevation: 5,
    backgroundColor: Color(0xfffff3d6),
    content: Text(
      text,
      style: TextStyle(color: Colors.black),
    ),
    action: SnackBarAction(
      onPressed: () {
        purchase();
      },
      label: 'Upgrade!',
    ),
  ));
}
