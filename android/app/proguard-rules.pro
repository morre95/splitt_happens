# ML Kit text recognition bundles only the Latin script in this app. The plugin
# references the optional Chinese, Devanagari, Japanese, and Korean recognizer
# option classes, which are not on the classpath, so R8 reports them as missing
# during release minification. We don't use those scripts, so it is safe to tell
# R8 to ignore the dangling references.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
