// ignore_for_file: avoid_print

import 'package:collection/collection.dart';
import 'package:notification_flutter_app/core/locator.dart';
import 'package:notification_flutter_app/core/sanity_service.dart';
import 'package:notification_flutter_app/data/models/secret_key.dart';

class GlobalStroe {
  String? userMobileNumber;
  List<SecretKey> _secretKeyList = [];
  bool needToAddNotification = true;

  void init() async {
    await fetchSecretValue();
  }

  Future<void> fetchSecretValue() async {
    try {
      _secretKeyList = await locator.get<SanityService>().fetchSecretKey();
    } catch (e) {
      print('Error creating post: $e');
    }
  }

  String getSecretValue({
    required String key,
  }) {
    final value =
        _secretKeyList.firstWhereOrNull((element) => element.key == key)?.value;

    return value ?? '';
  }
}
