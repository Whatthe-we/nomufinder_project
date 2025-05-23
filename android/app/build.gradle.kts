plugins {
    id("com.android.application")
    id("kotlin-android")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ Firebase용 plugin
}

android {
    namespace = "com.example.project_nomufinder"
    compileSdk = 35 // ✅ 35로 명시
    //ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = false  // 이 줄을 추가
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.project_nomufinder"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23                              // ✅ SOK 버전 상향
        targetSdk = 35   // ✅ 함께 상향
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // ✅ FCM 기본 알림 채널 설정
        resValue("string", "default_notification_channel_id", "high_importance_channel")
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

dependencies {
    // ✅ Firebase BoM (Bill of Materials)
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))

    // ✅ Firestore SDK 추가
    implementation("com.google.firebase:firebase-firestore")

    // ✅ Firebase Messaging (필수)
    implementation("com.google.firebase:firebase-messaging")

    // (선택) Firebase Analytics 등 다른 기능을 쓰려면 여기에 추가 가능
    // implementation("com.google.firebase:firebase-analytics")

    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.9.0")
}