import 'package:hive/hive.dart';
import 'package:notification_flutter_app/data/models/user_login_info.dart';

class HiveService {
  Future<void> saveMobileNumber({required String number}) async {
    final box = Hive.box<UserLoginInfo>('mobile_users');
    final newUser = UserLoginInfo(mobileNumber: number);
    await box.add(newUser);
  }

  List<UserLoginInfo> getAllMobileNumbers() {
    final box = Hive.box<UserLoginInfo>('mobile_users');
    return box.values.toList();
  }

  Future<void> clearAllMobileUsersData() async {
    final box = Hive.box<UserLoginInfo>('mobile_users');
    await box.clear();
  }
}
