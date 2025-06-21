import 'package:hive/hive.dart';

part 'user_login_info.g.dart';

@HiveType(typeId: 0)
class UserLoginInfo extends HiveObject {
  @HiveField(0)
  String mobileNumber;

  UserLoginInfo({
    required this.mobileNumber,
  });
}
