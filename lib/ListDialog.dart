import 'package:flutter/material.dart';

class ListDialog {
  final List<String> items;
  final int currentValue;
  final String title;
  final BuildContext context;
  int newValue;

  ListDialog({this.items, this.title, this.currentValue, this.context});

  Future<int> show() async {
    await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: items
            .map((option) => RadioListTile(
                  value: option,
                  title: Text(option),
                  groupValue: items[currentValue],
                  onChanged: (String value) {
                    newValue = items.indexOf(value);
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
    return newValue;
  }
}
