import 'dart:async';
import 'dart:io' show InternetAddress, Platform, RawDatagramSocket;

import 'package:flutter/foundation.dart';

/// Performs a tiny UDP multicast to force iOS to evaluate the
/// `NSLocalNetworkUsageDescription` entitlement in debug builds.
bool _probeInFlight = false;
bool _probeCompleted = false;
const bool _probeEnabled = bool.fromEnvironment(
  'ENABLE_LOCAL_NETWORK_PROBE',
  defaultValue: true,
);

Future<void> ensureLocalNetworkPermission() async {
  if (!_probeEnabled || _probeCompleted) {
    return;
  }

  if (!kDebugMode || kIsWeb) {
    return;
  }

  if (!(Platform.isIOS || Platform.isMacOS)) {
    return;
  }

  if (_probeInFlight) {
    return;
  }

  _probeInFlight = true;
  try {
    await runZonedGuarded<Future<void>>(
      () async {
        try {
          final RawDatagramSocket socket = await RawDatagramSocket.bind(
            InternetAddress.anyIPv4,
            0,
            reuseAddress: true,
          );

          try {
            final InternetAddress mdnsGroup = InternetAddress('224.0.0.251');
            socket.joinMulticast(mdnsGroup);
            socket.send(const <int>[0x00], mdnsGroup, 5353);

            await Future<void>.delayed(const Duration(milliseconds: 200));
          } finally {
            socket.close();
          }
        } on Object catch (error, stackTrace) {
          debugPrint('UDP probe failed: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      },
      (Object error, StackTrace stackTrace) {
        debugPrint('Local network probe crashed: $error');
        debugPrintStack(stackTrace: stackTrace);
      },
    );
  } finally {
    _probeInFlight = false;
    _probeCompleted = true;
    if (kDebugMode) {
      debugPrint('[Bootstrap] Local network probe completed.');
    }
  }
}
