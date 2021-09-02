
import 'dart:async';

import 'package:flutter/services.dart';

class ScannerView {
  static const MethodChannel _channel = MethodChannel('scanner_view');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
