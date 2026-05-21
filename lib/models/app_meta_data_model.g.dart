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
      categoryIndex: fields[2] as int,
      customCategoryIndex: fields[3] as int?,
      isLaunchable: fields[4] as bool?,
      lastSynced: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AppMetaDataModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.categoryIndex)
      ..writeByte(3)
      ..write(obj.customCategoryIndex)
      ..writeByte(4)
      ..write(obj.isLaunchable)
      ..writeByte(5)
      ..write(obj.lastSynced);
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
