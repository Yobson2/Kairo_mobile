# Google Sign-In Setup Guide

This guide will walk you through setting up Google Sign-In for the Kairo mobile app on both Android and iOS platforms.

## Prerequisites

- A Google Cloud Project
- Supabase project
- Access to Google Cloud Console

---

## Part 1: Google Cloud Console Setup

### 1. Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a project" → "New Project"
3. Enter project name: `Kairo Mobile`
4. Click "Create"

### 2. Enable Google Sign-In API

1. In your Google Cloud Project, go to **APIs & Services** → **Library**
2. Search for "Google+ API" or "Google Identity"
3. Click **Enable**

### 3. Configure OAuth Consent Screen

1. Go to **APIs & Services** → **OAuth consent screen**
2. Select **External** (or Internal if you have a Google Workspace)
3. Click **Create**
4. Fill in the required fields:
   - **App name**: Kairo
   - **User support email**: Your email
   - **Developer contact email**: Your email
5. Click **Save and Continue**
6. For **Scopes**, click **Add or Remove Scopes**:
   - Add `email`
   - Add `profile`
   - Add `openid`
7. Click **Save and Continue**
8. Click **Back to Dashboard**

---

## Part 2: Android Setup

### 1. Get SHA-1 Certificate Fingerprint

#### For Debug Build:
```bash
cd android
./gradlew signingReport
```

Look for the **SHA-1** under `Variant: debug` → `Config: debug`

#### For Release Build:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Or if you have a production keystore:
```bash
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-key-alias
```

Copy the **SHA-1 certificate fingerprint**.

### 2. Create Android OAuth Client ID

1. In Google Cloud Console, go to **APIs & Services** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
3. Select **Android**
4. Fill in:
   - **Name**: Kairo Android
   - **Package name**: `com.example.kairo` (or your actual package name from `android/app/build.gradle`)
   - **SHA-1 certificate fingerprint**: Paste the SHA-1 from step 1
5. Click **Create**
6. **Important**: Note down the **Client ID** (you won't need to add it to your code, but keep it for reference)

### 3. Update build.gradle Files

**android/app/build.gradle**:
```gradle
dependencies {
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

**Note**: Since you're using Supabase instead of Firebase, you don't need `google-services.json` or the Google Services Gradle plugin.

---

## Part 3: iOS Setup

### 1. Create iOS OAuth Client ID

1. In Google Cloud Console, go to **APIs & Services** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
3. Select **iOS**
4. Fill in:
   - **Name**: Kairo iOS
   - **Bundle ID**: Get this from `ios/Runner.xcodeproj/project.pbxproj` (usually `com.example.kairo`)
5. Click **Create**
6. **Important**: Copy the **iOS URL scheme** (it looks like: `com.googleusercontent.apps.123456789-xxxxx`)

### 2. Update Info.plist

Open `ios/Runner/Info.plist` and add:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Replace with your iOS URL scheme from Google Cloud Console -->
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>

<key>GIDClientID</key>
<string>YOUR-IOS-CLIENT-ID.apps.googleusercontent.com</string>
```

Replace:
- `YOUR-CLIENT-ID` with your OAuth client ID (numbers only)
- `YOUR-IOS-CLIENT-ID.apps.googleusercontent.com` with your full iOS client ID

**Note**: Since you're using Supabase instead of Firebase, you don't need `GoogleService-Info.plist`.

---

## Part 4: Web Client ID for Supabase Integration (Required)

For Supabase authentication, you need a Web Client ID:

### 1. Create Web OAuth Client ID

1. In Google Cloud Console, go to **APIs & Services** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
3. Select **Web application**
4. Fill in:
   - **Name**: Kairo Web
   - **Authorized JavaScript origins**: Add your Supabase project URL
   - **Authorized redirect URIs**: Add `https://YOUR-PROJECT.supabase.co/auth/v1/callback`
5. Click **Create**
6. Copy the **Client ID**

### 2. Configure in Supabase

1. Go to your Supabase project dashboard
2. Navigate to **Authentication** → **Providers**
3. Enable **Google**
4. Paste your Web Client ID and Client Secret
5. Click **Save**

---

## Part 5: Update Environment Variables

Create/update `.env` file in the project root:

```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# Google Sign-In (Required for Supabase)
GOOGLE_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
GOOGLE_IOS_CLIENT_ID=your-ios-client-id.apps.googleusercontent.com
```

---

## Part 6: Testing

### Test on Android:
1. Make sure you're using the same SHA-1 certificate
2. Run the app: `flutter run`
3. Click "Continue with Google"
4. Select your Google account
5. Verify the authentication flow

### Test on iOS:
1. Open Xcode and ensure the Bundle ID matches
2. Run the app: `flutter run`
3. Click "Continue with Google"
4. Select your Google account
5. Verify the authentication flow

---

## Troubleshooting

### Android Issues

**"PlatformException(sign_in_failed)"**
- Verify SHA-1 certificate matches the one in Google Cloud Console
- Check package name matches
- Ensure Web Client ID is configured in Supabase

**"API not enabled"**
- Enable Google+ API in Google Cloud Console

### iOS Issues

**"Error 400: redirect_uri_mismatch"**
- Verify Bundle ID matches in Google Cloud Console
- Check URL scheme in Info.plist

**"The operation couldn't be completed"**
- Verify `GIDClientID` in Info.plist is correct
- Check URL scheme is properly formatted

### General Issues

**"No user returned"**
- Check Supabase Google provider is enabled
- Verify Web Client ID is correct in Supabase

**User not in database**
- This is expected behavior! New users need to complete registration
- The app will redirect them to the registration screen

---

## Security Best Practices

1. **Never commit** OAuth credentials to version control
2. Use **environment variables** for sensitive data
3. Rotate credentials if they're compromised
4. Use **different credentials** for debug and release builds
5. Enable **2FA** on your Google Cloud account

---

## Additional Resources

- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Supabase Google Auth Docs](https://supabase.com/docs/guides/auth/social-login/auth-google)
