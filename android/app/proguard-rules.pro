# Keep all ML Kit vision-related classes
-keep class com.google.mlkit.vision.** { *; }
-keep class com.google.mlkit.common.** { *; }

# Keep all recognizer options for text recognition (multilingual)
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }

# Suppress warnings
-dontwarn com.google.mlkit.**
