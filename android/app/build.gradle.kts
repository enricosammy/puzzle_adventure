plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.enrico.puzzle_adventure"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.enrico.puzzle_adventure"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions.add("default")

    productFlavors {
        create("cartoons") {
            dimension = "default"
            applicationIdSuffix = ".cartoons"
            versionNameSuffix = "-cartoons"
            manifestPlaceholders.putAll(
                mutableMapOf(
                    "appIcon" to "@mipmap/ic_cartoon",
                    "appLabel" to "Cartoon Puzzle"
                )
            )
        }
        create("pets") {
            dimension = "default"
            applicationIdSuffix = ".pets"
            versionNameSuffix = "-pets"
            manifestPlaceholders.putAll(
                mutableMapOf(
                    "appIcon" to "@mipmap/ic_pets",
                    "appLabel" to "Pet Puzzle"
                )
            )
        }
        create("women") {
            dimension = "default"
            applicationIdSuffix = ".women"
            versionNameSuffix = "-women"
            manifestPlaceholders.putAll(
                mutableMapOf(
                    "appIcon" to "@mipmap/ic_women",
                    "appLabel" to "Women Puzzle"
                )
            )
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}