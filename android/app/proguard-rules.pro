# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Dart VM Service
-keep class org.dartlang.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Hive database specific rules
-keep class hive.** { *; }
-keep class **.g.dart

# Keep model classes for Hive
-keep class com.example.noteapp.** { *; }

# PDF generation (printing package)
-keep class printing.** { *; }
-keep class android.print.** { *; }

# Path provider
-keep class path_provider.** { *; }

# URL launcher
-keep class url_launcher.** { *; }

# Google Fonts
-keep class google_fonts.** { *; }

# Table Calendar
-keep class table_calendar.** { *; }

# Share Plus
-keep class share_plus.** { *; }

# Provider state management
-keep class provider.** { *; }

# Keep Flutter engine
-keep class io.flutter.embedding.** { *; }

# Keep platform channels
-keep class io.flutter.plugin.platform.** { *; }

# Handle missing Play Core classes (for deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Keep Flutter Play Store split application classes
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Ignore missing classes that are optional
-dontnote com.google.android.play.core.**

# Preserve annotations
-keepattributes *Annotation*

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Prevent obfuscation of Flutter plugin registrants
-keep class io.flutter.plugins.** { *; }
-keep class GeneratedPluginRegistrant { *; }

# Additional rules for better optimization
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontpreverify
-verbose

# Remove debug logs in release
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}
