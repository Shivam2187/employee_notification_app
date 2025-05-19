// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_login_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserLoginInfoAdapter extends TypeAdapter<UserLoginInfo> {
  @override
  final int typeId = 0;

  @override
  UserLoginInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserLoginInfo(
      mobileNumber: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserLoginInfo obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.mobileNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLoginInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
