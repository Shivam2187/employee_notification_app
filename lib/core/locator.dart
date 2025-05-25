import 'package:get_it/get_it.dart';
import 'package:notification_flutter_app/core/hive_service.dart';
import 'package:notification_flutter_app/core/sanity_service.dart';

final locator = GetIt.instance;

class DependencyInjection {
  static setupLocator() {
    locator.registerSingleton(SanityService());
    locator.registerSingleton(HiveService());
  }
}
