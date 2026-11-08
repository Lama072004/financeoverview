import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../l10n/gen/app_localizations.dart';

enum BiometricKind { fingerprint, face, generic }

class BiometricService {
  final _auth = LocalAuthentication();

  /// Null when the device has no usable (enrolled) biometrics.
  Future<BiometricKind?> available() async {
    try {
      if (!await _auth.isDeviceSupported() || !await _auth.canCheckBiometrics) return null;
      final types = await _auth.getAvailableBiometrics();
      if (types.isEmpty) return null;
      if (types.contains(BiometricType.face)) return BiometricKind.face;
      if (types.contains(BiometricType.fingerprint)) return BiometricKind.fingerprint;
      // Android reports classes ("strong"/"weak"); class 3 is typically a fingerprint sensor.
      if (Platform.isAndroid && types.contains(BiometricType.strong)) return BiometricKind.fingerprint;
      return BiometricKind.generic;
    } catch (_) {
      return null;
    }
  }

  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}

final biometricServiceProvider = Provider<BiometricService>((ref) => BiometricService());

final biometricAvailabilityProvider = FutureProvider<BiometricKind?>(
  (ref) => ref.watch(biometricServiceProvider).available(),
);

String biometricLabel(AppLocalizations l, BiometricKind? kind) => switch (kind) {
      BiometricKind.face => l.biometricFace,
      BiometricKind.fingerprint => l.biometricFingerprint,
      _ => l.biometricGeneric,
    };
