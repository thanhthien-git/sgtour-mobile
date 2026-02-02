# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}

# Google Sign-In, Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Play Core - optional deferred components (app không dùng split install)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Local Auth (biometrics)
-keep class io.flutter.plugins.localauth.** { *; }

# Google ML Kit Barcode
-keep class com.google.mlkit.** { *; }

# Vietmap, Map
-keep class com.vietmap.** { *; }

# Dio (network)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class com.google.gson.** { *; }
