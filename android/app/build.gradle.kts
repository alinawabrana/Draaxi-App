import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

fun loadDotEnv(file: java.io.File): Properties {
    val props = Properties()
    if (!file.exists()) return props
    file.forEachLine { raw ->
        val line = raw.trim()
        if (line.isEmpty() || line.startsWith("#")) return@forEachLine
        val idx = line.indexOf('=')
        if (idx <= 0) return@forEachLine
        val key = line.substring(0, idx).trim()
        var value = line.substring(idx + 1).trim()
        if ((value.startsWith("\"") && value.endsWith("\"")) ||
            (value.startsWith("'") && value.endsWith("'"))
        ) {
            value = value.substring(1, value.length - 1)
        }
        props.setProperty(key, value)
    }
    return props
}

android {
    namespace = "com.example.draaxi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.draaxi"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        val env = loadDotEnv(rootProject.file("../.env"))
        val localProperties = Properties().apply {
            val file = rootProject.file("local.properties")
            if (file.exists()) {
                file.inputStream().use { load(it) }
            }
        }

        val mapsApiKey =
            (project.findProperty("MAPS_API_KEY") as String?)
                ?: env.getProperty("GOOGLE_MAPS_API_KEY")
                ?: localProperties.getProperty("MAPS_API_KEY")
                ?: ""
        resValue("string", "google_maps_key", mapsApiKey)

        val placesApiKey =
            (project.findProperty("PLACES_API_KEY") as String?)
                ?: env.getProperty("GOOGLE_PLACES_API_KEY")
                ?: localProperties.getProperty("PLACES_API_KEY")
                ?: mapsApiKey
        resValue("string", "google_places_key", placesApiKey)
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
