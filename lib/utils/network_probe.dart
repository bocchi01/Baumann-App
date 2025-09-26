import 'dart:async';
import 'dart:io' show InternetAddress, Platform, RawDatagramSocket;

import 'package:flutter/foundation.dart';
import 'package:multicast_dns/multicast_dns.dart';

/// Performs a tiny Bonjour lookup to force iOS to evaluate the
/// `NSLocalNetworkUsageDescription` entitlement in debug builds.
bool _probeInFlight = false;
const bool _probeEnabled = bool.fromEnvironment(
  'ENABLE_LOCAL_NETWORK_PROBE',
  defaultValue: true,
);

Future<void> ensureLocalNetworkPermission() async {
  if (!_probeEnabled) {
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
        final MDnsClient client = MDnsClient();
        StreamSubscription<PtrResourceRecord>? subscription;

        try {
          await client.start();

          subscription = client
              .lookup<PtrResourceRecord>(
                ResourceRecordQuery.service('_dartobservatory._tcp'),
              )
              .listen(
            (PtrResourceRecord record) {
              debugPrint('mDNS probe discovered: ${record.domainName}');
            },
            onError: (Object error, StackTrace stackTrace) {
              debugPrint('mDNS probe error: $error');
              debugPrintStack(stackTrace: stackTrace);
            },
          );

          await Future<void>.delayed(const Duration(seconds: 2));
        } on Object catch (error, stackTrace) {
          debugPrint('mDNS probe failed: $error');
          debugPrintStack(stackTrace: stackTrace);
        } finally {
          await subscription?.cancel();
          client.stop();
        }

        try {
          final RawDatagramSocket socket = await RawDatagramSocket.bind(
            InternetAddress.anyIPv4,
            0,
            reusePort: true,
            reuseAddress: true,
          );

          final InternetAddress mdnsGroup = InternetAddress('224.0.0.251');
          socket.joinMulticast(mdnsGroup);
          socket.send(const <int>[0x00], mdnsGroup, 5353);

          await Future<void>.delayed(const Duration(milliseconds: 500));
          socket.close();
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
  }
}
