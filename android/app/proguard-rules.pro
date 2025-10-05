# Flutter Unity Widget ProGuard Rules
# Unity 3D entegrasyonu için gerekli koruma kuralları

# Unity core sınıfları
-keep class com.xraph.plugins.flutter_unity_widget.** { *; }
-keep class com.unity3d.player.** { *; }
-keep class com.unity3d.** { *; }

# Unity Native Plugins
-keep class com.unity3d.unityconnect.** { *; }
-keep class com.unity3d.services.** { *; }
-keep class com.unity3d.ads.** { *; }

# Unity Message Manager
-keep class flutter.unity.integration.** { *; }
-keepclassmembers class flutter.unity.integration.** { *; }

# LEO Rocket Simulation specific
-keep class com.spaceapps.leo_rocket.** { *; }

# JSON serialization için
-keep class ** implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Flutter genel koruma
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Android specific optimizations
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontpreverify
-verbose

# Unity IL2CPP native library koruma
-keep class com.unity3d.player.UnityPlayerActivity { *; }
-keep class com.unity3d.player.UnityPlayer { *; }

# NASA Space Apps Challenge - debug bilgileri koru (geliştirme sürümü için)
-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*

# Unity performance için
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
