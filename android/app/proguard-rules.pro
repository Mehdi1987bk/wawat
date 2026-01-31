# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# SLF4J - fix missing class warnings
-dontwarn org.slf4j.**
-keep class org.slf4j.** { *; }

# Keep annotations
-keepattributes *Annotation*
