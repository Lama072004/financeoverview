import 'dart:math';

final _random = Random.secure();
const _alphabet = '0123456789abcdefghijklmnopqrstuvwxyz';

/// Short unique id: time-ordered prefix plus random suffix.
String newId() {
  final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final suffix = List.generate(6, (_) => _alphabet[_random.nextInt(_alphabet.length)]).join();
  return '$time$suffix';
}
