# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep SLF4J classes to fix R8 missing classes error
-dontwarn org.slf4j.**
-keep class org.slf4j.** { *; }
-keepclassmembers class org.slf4j.** { *; }

# Keep SLF4J impl classes
-dontwarn org.slf4j.impl.**
-keep class org.slf4j.impl.** { *; }
-keepclassmembers class org.slf4j.impl.** { *; }

# Keep LoggerFactory
-keep class org.slf4j.LoggerFactory { *; }
-keep class org.slf4j.Logger { *; }
-keep class org.slf4j.ILoggerFactory { *; }
-keep class org.slf4j.spi.** { *; }
-keep class org.slf4j.helpers.** { *; }

# Keep common logging implementations
-dontwarn org.apache.commons.logging.**
-keep class org.apache.commons.logging.** { *; }

# Keep Apache HTTP client classes
-dontwarn org.apache.http.**
-keep class org.apache.http.** { *; }

# Keep OkHttp and Retrofit
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn retrofit2.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-keep class retrofit2.** { *; }
-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}

# Keep Dio
-keep class dio.** { *; }
-dontwarn dio.**

# Keep Firebase and other native library classes
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep for Flutter plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Flutter Downloader
-keep class vn.hunghd.flutterdownloader.** { *; }
-dontwarn vn.hunghd.flutterdownloader.**

# Keep annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes SourceFile,LineNumberTable

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Gson/Jackson for JSON serialization
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
-keep class com.fasterxml.jackson.** { *; }
-dontwarn com.fasterxml.jackson.**

# Ignore warnings
-ignorewarnings
