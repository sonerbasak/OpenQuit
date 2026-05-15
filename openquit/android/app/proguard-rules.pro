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

# flutter_local_notifications — scheduled notifications Gson serialization fix
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**
-keepclassmembers class com.dexterous.flutterlocalnotifications.** { *; }

# Gson — generic type parameter fix (Missing type parameter hatası)
-keep class com.google.gson.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# App classes
-keep class com.openquit.openquit.** { *; }
