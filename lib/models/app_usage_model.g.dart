// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_usage_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppUsageModelAdapter extends TypeAdapter<AppUsageModel> {
  @override
  final int typeId = 2;

  @override
  AppUsageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUsageModel(
      packageName: fields[0] as String,
      usageMillis: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AppUsageModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.usageMillis);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUsageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
