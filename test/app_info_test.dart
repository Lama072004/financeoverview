import 'dart:io';

import 'package:financeoverview/core/app_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shown version matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(r'^version:\s*([0-9.]+)\+(\d+)', multiLine: true).firstMatch(pubspec)!;
    expect(appVersion, version.group(1));
  });
}
