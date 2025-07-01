import 'package:flutter/foundation.dart';

void debugprint(dynamic message) {
  if (kDebugMode) {
    print('***** $message *****');
  }
}
