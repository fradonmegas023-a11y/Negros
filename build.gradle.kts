import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
    id("org.jetbrains.kotlin.plugin.serialization")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use(localProperties::load)
}
val backendProperties = Properties()
val backendPropertiesFile = rootProject.file("negros.backend.properties")
if (backendPropertiesFile.exists()) {
    backendPropertiesFile.inputStream().use(backendProperties::load)
}
fun String.toBuildConfigLiteral(): String = "\"" + replace("\\", "\\\\").replace("\"", "\\\"") + "\""

android {
    namespace = "com.negros.society"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.negros.society"
        minSdk = 26
        targetSdk = 35
        versionCode = 4
        versionName = "0.5.0-alpha"
        val supabaseUrl = localProperties.getProperty("SUPABASE_URL")
            ?: backendProperties.getProperty("SUPABASE_URL")
            ?: System.getenv("SUPABASE_URL") ?: ""
        val supabasePublishableKey = localProperties.getProperty("SUPABASE_PUBLISHABLE_KEY")
            ?: backendProperties.getProperty("SUPABASE_PUBLISHABLE_KEY")
            ?: System.getenv("SUPABASE_PUBLISHABLE_KEY") ?: ""
        buildConfigField("String", "SUPABASE_URL", supabaseUrl.toBuildConfigLiteral())
        buildConfigField("String", "SUPABASE_PUBLISHABLE_KEY", supabasePublishableKey.toBuildConfigLiteral())
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation(platform("androidx.compose:compose-bom:2024.12.01"))
    implementation("androidx.activity:activity-compose:1.10.0")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")

    implementation(platform("io.github.jan-tennert.supabase:bom:3.5.0"))
    implementation("io.github.jan-tennert.supabase:auth-kt")
    implementation("io.github.jan-tennert.supabase:postgrest-kt")
    implementation("io.github.jan-tennert.supabase:realtime-kt")
    implementation("io.github.jan-tennert.supabase:storage-kt")
    implementation("io.ktor:ktor-client-android:3.0.3")

    debugImplementation("androidx.compose.ui:ui-tooling")
}
