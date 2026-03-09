import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val requestedTasks = gradle.startParameter.taskNames.joinToString(" ").lowercase()
val isReleaseTask = requestedTasks.contains("release")

val configuredApplicationId =
    (project.findProperty("PARENT_ANDROID_APPLICATION_ID") as String?)
        ?.trim()
        ?.takeIf { it.isNotEmpty() }

val mapsApiKey =
    (project.findProperty("PARENT_GOOGLE_MAPS_API_KEY") as String?)
        ?.trim()
        ?.takeIf { it.isNotEmpty() }
        ?: System.getenv("PARENT_GOOGLE_MAPS_API_KEY")
        ?: ""

val releaseStoreFile =
    (project.findProperty("PARENT_RELEASE_STORE_FILE") as String?)
        ?.trim()
        ?.takeIf { it.isNotEmpty() }
val releaseStorePassword =
    (project.findProperty("PARENT_RELEASE_STORE_PASSWORD") as String?)
        ?.trim()
        ?.takeIf { it.isNotEmpty() }
val releaseKeyAlias =
    (project.findProperty("PARENT_RELEASE_KEY_ALIAS") as String?)
        ?.trim()
        ?.takeIf { it.isNotEmpty() }
val releaseKeyPassword =
    (project.findProperty("PARENT_RELEASE_KEY_PASSWORD") as String?)
        ?.trim()
        ?.takeIf { it.isNotEmpty() }

val hasReleaseSigning =
    !releaseStoreFile.isNullOrBlank() &&
        !releaseStorePassword.isNullOrBlank() &&
        !releaseKeyAlias.isNullOrBlank() &&
        !releaseKeyPassword.isNullOrBlank()

if (isReleaseTask) {
    if (configuredApplicationId.isNullOrBlank() || configuredApplicationId.startsWith("com.example")) {
        throw GradleException(
            "Release build requires non-placeholder PARENT_ANDROID_APPLICATION_ID (e.g. -PPARENT_ANDROID_APPLICATION_ID=com.servisnow.parent)."
        )
    }
    if (!hasReleaseSigning) {
        throw GradleException(
            "Release signing config is missing. Set PARENT_RELEASE_STORE_FILE, PARENT_RELEASE_STORE_PASSWORD, PARENT_RELEASE_KEY_ALIAS, PARENT_RELEASE_KEY_PASSWORD."
        )
    }
}

android {
    namespace = "com.servisnow.veli"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") {
            if (hasReleaseSigning) {
                storeFile = file(releaseStoreFile!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    defaultConfig {
        applicationId = configuredApplicationId ?: "com.servisnow.veli"
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = mapsApiKey
    }

    buildTypes {
        release {
            signingConfig =
                if (hasReleaseSigning) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }
        }
    }
}

flutter {
    source = "../.."
}
