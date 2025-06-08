import java.util.Properties import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

fun loadProperties(): Properties { 
    val properties = Properties() 
    val propertiesFile = project.rootProject.file("key.properties") 
    if (propertiesFile.exists()) { 
        properties.load(FileInputStream(propertiesFile)) 
    } else { 
        throw GradleException("key.properties file not found at key.properties") 
    } 
    return properties 
}

val keyProperties = loadProperties()

android {
    namespace = "com.example.what_for_meal"
    // compileSdk = flutter.compileSdkVersion
    // ndkVersion = flutter.ndkVersion
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    signingConfigs {
        create("release") {
            storeFile = file(keyProperties["RELEASE_FILE_PATH"] as String)
            keyAlias = keyProperties["RELEASE_KEY_ALIAS"] as String
            storePassword = keyProperties["RELEASE_STORE_PASSWORD"] as String
            keyPassword = keyProperties["RELEASE_KEY_PASSWORD"] as String
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.what_for_meal"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // minSdk = flutter.minSdkVersion
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true      // 啟用程式碼縮減
            isShrinkResources = true    // 明確啟用資源縮減
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        getByName("debug") {
            isMinifyEnabled = false     // 禁用程式碼縮減
            isShrinkResources = false   // 明確禁用資源縮減
            signingConfig = signingConfigs.getByName("release") // debug 模式使用 release keystore
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
}