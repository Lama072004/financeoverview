import 'dart:convert';

import 'package:http/http.dart' as http;

/// The app's only network access: on explicit request, fetch the last price
/// of an ETF from Tradegate. Only the ISIN is sent.
class PriceService {
  PriceService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<double?> fetchLastPrice(String isin) async {
    final cleaned = isin.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{2}[A-Z0-9]{9}[0-9]$').hasMatch(cleaned)) return null;
    final uri = Uri.https('www.tradegate.de', '/refresh.php', {'isin': cleaned});
    final response = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return null;
    return parseLast(response.body);
  }

  /// Tradegate answers with JSON like `{"last": 7.657, ...}`; the value may
  /// also come as a string with a decimal comma.
  static double? parseLast(String body) {
    Object? json;
    try {
      json = jsonDecode(body);
    } catch (_) {
      return null;
    }
    if (json is! Map) return null;
    final last = json['last'];
    if (last is num) return last > 0 ? last.toDouble() : null;
    if (last is String) {
      final v = double.tryParse(last.trim().replaceAll(' ', '').replaceAll(',', '.'));
      return v != null && v > 0 ? v : null;
    }
    return null;
  }
}
