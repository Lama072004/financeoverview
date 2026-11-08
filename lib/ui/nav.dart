import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<T?> push<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));

/// Selected tab of the home shell.
class HomeTab extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final homeTabProvider = NotifierProvider<HomeTab, int>(HomeTab.new);

abstract final class Tabs {
  static const home = 0;
  static const accounts = 1;
  static const history = 2;
  static const more = 3;
}
