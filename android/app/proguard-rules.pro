# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Hive database rules
-keep class * extends com.google.protobuf.GeneratedMessageLite { *; }
-keep class * implements androidx.sqlite.db.SupportSQLiteOpenHelper { *; }
-keep class * implements androidx.sqlite.db.SupportSQLiteOpenHelper$Factory { *; }
-keep class * implements androidx.sqlite.db.SupportSQLiteOpenHelper$Callback { *; }

# Keep Hive adapters
-keep class * extends com.isar.isar.generated.** { *; }
-keep class * implements com.isar.isar.IsarGenerated { *; }

# Keep model classes
-keep class com.appverse.healthverse.models.** { *; }
-keep class * extends com.appverse.healthverse.models.** { *; }

# Keep Hive type adapters
-keep class * extends com.appverse.healthverse.models.** { *; }
-keepclassmembers class * extends com.appverse.healthverse.models.** {
    @hive.** *;
}

# Permission handler
-keep class com.baseflow.permissionhandler.** { *; }

# Pedometer
-keep class com.example.pedometer.** { *; }

# Image picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Dynamic color
-keep class androidx.core.graphics.** { *; }

# Material 3 - Keep all Material Design classes and resources
-keep class com.google.android.material.** { *; }
-keep class com.google.android.material.R$** { *; }

# Play Core - Keep Play Store related classes
-keep class com.google.android.play.core.** { *; }

# Keep all R classes (resource classes)
-keep class **.R$* {
    public static <fields>;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable implementations
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

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}

# Optimize string operations
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification

# Remove unused code
-dontwarn android.support.**
-dontwarn androidx.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# Keep essential Android components
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.preference.Preference
-keep public class * extends android.view.View
-keep public class * extends android.app.Fragment

# Keep custom views
-keep public class * extends android.view.View {
    *** get*();
    void set*(***);
    *** findViewById(int);
}

# Keep onClick methods
-keepclassmembers class * extends android.app.Activity {
    public void *(android.view.View);
}

# Keep native libraries
-keep class * {
    native <methods>;
}

# Remove debug information
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable,*Annotation*

# Optimize for size
-repackageclasses ''
-allowaccessmodification
