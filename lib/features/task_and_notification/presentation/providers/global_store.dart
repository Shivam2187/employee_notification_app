// ignore_for_file: avoid_print

import 'package:collection/collection.dart';
import 'package:notification_flutter_app/core/debug_print.dart';
import 'package:notification_flutter_app/core/locator.dart';
import 'package:notification_flutter_app/core/sanity_service.dart';
import 'package:notification_flutter_app/features/task_and_notification/data/models/secret_key.dart';
import 'package:notification_flutter_app/features/task_and_notification/data/models/selected_task_detail_with_url.dart';

class GlobalStore {
  // Singleton instance
  GlobalStore._privateConstructor();
  static final GlobalStore _instance = GlobalStore._privateConstructor();
  factory GlobalStore() {
    return _instance;
  }

  List<SecretKey> _secretKeyList = [];
  bool needToAddNotification = true;
  SelectedTaskDetailWithUrl? selectedTaskDetailWithUrl;

  void init() async {
    await fetchSecretValue();
  }

  Future<void> fetchSecretValue() async {
    try {
      _secretKeyList = await locator.get<SanityService>().fetchSecretKey();
    } catch (e) {
      debugprint('Error creating post: $e');
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
