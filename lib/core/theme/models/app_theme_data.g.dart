// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_theme_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppThemeDataAdapter extends TypeAdapter<AppThemeData> {
  @override
  final int typeId = 30;

  @override
  AppThemeData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppThemeData(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      isSystem: fields[3] as bool,
      colors: (fields[4] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, AppThemeData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isSystem)
      ..writeByte(4)
      ..write(obj.colors);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppThemeDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
