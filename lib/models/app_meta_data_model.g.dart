// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_meta_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppMetaDataModelAdapter extends TypeAdapter<AppMetaDataModel> {
  @override
  final int typeId = 0;

  @override
  AppMetaDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppMetaDataModel(
      packageName: fields[0] as String,
      name: fields[1] as String,
      lastSynced: fields[2] as DateTime,
      categoryIndex: fields[3] as int?,
      dailyLimit: fields[4] as int?,
      isBlocked: fields[5] as bool?,
      isLaunchable: fields[6] as bool?,
      isTracked: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppMetaDataModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.lastSynced)
      ..writeByte(3)
      ..write(obj.categoryIndex)
      ..writeByte(4)
      ..write(obj.dailyLimit)
      ..writeByte(5)
      ..write(obj.isBlocked)
      ..writeByte(6)
      ..write(obj.isLaunchable)
      ..writeByte(7)
      ..write(obj.isTracked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppMetaDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
