import 'package:equatable/equatable.dart';

/// Uygulama geneli ayarlar — para birimi, bildirim tercihleri.
class AppSettings extends Equatable {
  /// ISO 4217 para birimi kodu, örn. "USD", "TRY", "EUR"
  final String currencyCode;

  /// Para birimi sembolü, örn. "$", "₺", "€"
  final String currencySymbol;

  /// Günlük motivasyon bildirimi açık mı?
  final bool dailyMotivationEnabled;

  /// Günlük bildirim saati (0-23)
  final int notificationHour;

  /// Günlük bildirim dakikası (0-59)
  final int notificationMinute;

  /// Milestone kutlama bildirimleri açık mı?
  final bool milestoneNotificationsEnabled;

  const AppSettings({
    this.currencyCode = 'USD',
    this.currencySymbol = '\$',
    this.dailyMotivationEnabled = false,
    this.notificationHour = 9,
    this.notificationMinute = 0,
    this.milestoneNotificationsEnabled = true,
  });

  AppSettings copyWith({
    String? currencyCode,
    String? currencySymbol,
    bool? dailyMotivationEnabled,
    int? notificationHour,
    int? notificationMinute,
    bool? milestoneNotificationsEnabled,
  }) =>
      AppSettings(
        currencyCode: currencyCode ?? this.currencyCode,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        dailyMotivationEnabled:
            dailyMotivationEnabled ?? this.dailyMotivationEnabled,
        notificationHour: notificationHour ?? this.notificationHour,
        notificationMinute: notificationMinute ?? this.notificationMinute,
        milestoneNotificationsEnabled:
            milestoneNotificationsEnabled ?? this.milestoneNotificationsEnabled,
      );

  @override
  List<Object?> get props => [
        currencyCode,
        currencySymbol,
        dailyMotivationEnabled,
        notificationHour,
        notificationMinute,
        milestoneNotificationsEnabled,
      ];
}
