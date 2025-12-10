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

# Keep common logging implementations
-dontwarn org.apache.commons.logging.**
-keep class org.apache.commons.logging.** { *; }

# Keep Firebase and other native library classes
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep for Flutter plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
