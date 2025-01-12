-keep class com.example.chatsta.** { *; }
-keep class com.example.chatsta.data.** { *; }
-keepclassmembers class com.example.chatsta.** { *; }

# Keep http related classes
-keep class com.android.okhttp.** { *; }
-keep interface com.android.okhttp.** { *; }
-dontwarn com.android.okhttp.**

# Keep retrofit related classes
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }