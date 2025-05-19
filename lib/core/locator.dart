import 'package:get_it/get_it.dart';
import 'package:notification_flutter_app/core/hive_service.dart';
import 'package:notification_flutter_app/core/sanity_service.dart';
import 'package:notification_flutter_app/presentation/providers/global_store.dart';

final locator = GetIt.instance;

class DependencyInjection {
  void setupLocator() {
    locator.registerSingleton(GlobalStroe());
    locator.registerSingleton(SanityService());
    locator.registerSingleton(HiveService());
  }
}
