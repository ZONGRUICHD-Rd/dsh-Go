import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Whether this platform can run DSH on the device itself (the PRoot runtime,
/// Android only). On iOS the app talks to remote hosts only: first run offers
/// no 「本机」 and the host list has no 本机 row.
bool get localRuntimeSupported => debugLocalRuntimeSupported ?? !Platform.isIOS;

/// Overrides [localRuntimeSupported] in tests; null follows the platform.
@visibleForTesting
bool? debugLocalRuntimeSupported;
