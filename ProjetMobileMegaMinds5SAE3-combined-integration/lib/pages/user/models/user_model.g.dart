// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      age: fields[3] as int,
      weight: fields[4] as double,
      height: fields[5] as double,
      gender: fields[6] as String,
      fitnessLevel: fields[7] as String,
      goal: fields[8] as String,
      avatarUrl: fields[9] as String?,
      createdAt: fields[10] as DateTime,
      lastUpdated: fields[11] as DateTime,
      weightHistory: (fields[12] as List?)?.cast<WeightEntry>(),
      badges: (fields[13] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.weight)
      ..writeByte(5)
      ..write(obj.height)
      ..writeByte(6)
      ..write(obj.gender)
      ..writeByte(7)
      ..write(obj.fitnessLevel)
      ..writeByte(8)
      ..write(obj.goal)
      ..writeByte(9)
      ..write(obj.avatarUrl)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.lastUpdated)
      ..writeByte(12)
      ..write(obj.weightHistory)
      ..writeByte(13)
      ..write(obj.badges);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeightEntryAdapter extends TypeAdapter<WeightEntry> {
  @override
  final int typeId = 1;

  @override
  WeightEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeightEntry(
      date: fields[0] as DateTime,
      weight: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, WeightEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.weight);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
