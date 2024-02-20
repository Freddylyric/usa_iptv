import 'package:hive/hive.dart';

part 'channels_model.g.dart';

@HiveType(typeId: 1)
class ChannelModel {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String country;

  @HiveField(3)
  late String logo;

  @HiveField(4)
  late String streamingLink;

  ChannelModel({
    required this.id,
    required this.name,
    required this.country,
    required this.logo,
    required this.streamingLink,
  });
}