# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Flutter Play Store Split Application (deferred components — not used but referenced)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Hive
-keep class com.hivedb.** { *; }
-keepclassmembers class * extends com.hivedb.hive.HiveObject { *; }

# flutter_local_notifications
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# App classes
-keep class com.openquit.openquit.** { *; }

# Prevent stripping of annotations used by injectable/hive
-keepattributes *Annotation*
-keepattributes Signature
