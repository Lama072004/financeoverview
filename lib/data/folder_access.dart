import 'package:flutter/services.dart';

class PickedFolder {
  const PickedFolder({required this.uri, required this.name});

  final String uri;
  final String name;
}

/// Access to one folder chosen by the user (Android Storage Access Framework,
/// see MainActivity.kt). The app only ever sees that folder.
class FolderAccess {
  const FolderAccess();

  static const _channel = MethodChannel('at.mathiaslampert.finanzuebersicht/folder');

  /// Opens the system folder picker; null when cancelled.
  Future<PickedFolder?> pick() async {
    final r = await _channel.invokeMapMethod<String, Object?>('pick');
    if (r == null) return null;
    final uri = r['uri'] as String;
    return PickedFolder(uri: uri, name: r['name'] as String? ?? Uri.decodeComponent(uri.split('%3A').last));
  }

  Future<void> release(String uri) => _channel.invokeMethod('release', {'uri': uri});

  Future<bool> canWrite(String uri) async => await _channel.invokeMethod<bool>('canWrite', {'uri': uri}) ?? false;

  /// Names of the files in the folder.
  Future<List<String>> list(String uri) async =>
      (await _channel.invokeListMethod<String>('list', {'uri': uri})) ?? const [];

  /// Creates the file or replaces its content.
  Future<void> write(String uri, String name, Uint8List bytes) =>
      _channel.invokeMethod('write', {'uri': uri, 'name': name, 'bytes': bytes});

  Future<void> delete(String uri, String name) => _channel.invokeMethod('delete', {'uri': uri, 'name': name});
}
