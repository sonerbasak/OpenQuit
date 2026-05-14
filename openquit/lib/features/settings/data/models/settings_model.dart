import 'package:hive/hive.dart';

import '../../domain/entities/app_settings.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 1)
class SettingsModel extends HiveObject {
  @HiveField(0)
  String currencyCode;

  @HiveField(1)
  String currencySymbol;

  @HiveField(2)
  bool dailyMotivationEnabled;

  @HiveField(3)
  int notificationHour;

  @HiveField(4)
  int notificationMinute;

  @HiveField(5)
  bool milestoneNotificationsEnabled;

  SettingsModel({
    this.currencyCode = 'USD',
    this.currencySymbol = '\$',
    this.dailyMotivationEnabled = false,
    this.notificationHour = 9,
    this.notificationMinute = 0,
    this.milestoneNotificationsEnabled = true,
  });

  AppSettings toDomain() => AppSettings(
        currencyCode: currencyCode,
        currencySymbol: currencySymbol,
        dailyMotivationEnabled: dailyMotivationEnabled,
        notificationHour: notificationHour,
        notificationMinute: notificationMinute,
        milestoneNotificationsEnabled: milestoneNotificationsEnabled,
      );

  static SettingsModel fromDomain(AppSettings s) => SettingsModel(
        currencyCode: s.currencyCode,
        currencySymbol: s.currencySymbol,
        dailyMotivationEnabled: s.dailyMotivationEnabled,
        notificationHour: s.notificationHour,
        notificationMinute: s.notificationMinute,
        milestoneNotificationsEnabled: s.milestoneNotificationsEnabled,
      );
}
