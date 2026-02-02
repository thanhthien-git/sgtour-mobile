import java.util.Properties
import java.io.FileInputStream
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.sgtour.sgtourcus"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.sgtour.sgtourcus"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("key.properties")
            val keystoreProperties = Properties()
            if (keystorePropertiesFile.exists()) {
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
            }
            val storePassword = keystoreProperties["storePassword"]?.toString()
                ?: System.getenv("ANDROID_KEYSTORE_PASSWORD")
            val keyPassword = keystoreProperties["keyPassword"]?.toString()
                ?: System.getenv("ANDROID_KEY_PASSWORD")
            val keyAlias = keystoreProperties["keyAlias"]?.toString()
                ?: System.getenv("ANDROID_KEY_ALIAS")
            val storeFileProp = keystoreProperties["storeFile"]?.toString()
            if (storePassword != null && keyPassword != null && keyAlias != null) {
                storeFile = if (storeFileProp != null) rootProject.file(storeFileProp) else file("release.jks")
                this.storePassword = storePassword
                this.keyAlias = keyAlias
                this.keyPassword = keyPassword
            }
        }
    }

    buildTypes {
        getByName("release") {
            val releaseSigningConfig = signingConfigs.getByName("release")
            signingConfig = if (releaseSigningConfig.storeFile != null) {
                releaseSigningConfig
            } else {
                throw GradleException(
                    "Release signing chưa được cấu hình. Tạo file android/key.properties " +
                    "(xem android/key.properties.example) với storePassword, keyPassword, keyAlias, storeFile. " +
                    "Hoặc đặt biến môi trường: ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD."
                )
            }
            isMinifyEnabled = false
            isShrinkResources = false
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

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

configurations.all {
    exclude(group = "com.jakewharton.timber", module = "timber")
}