# Google OAuth Setup for Supabase Authentication

## Overview

This guide will help you configure Google Sign-In for your Kairo app using **Supabase** (not Firebase). The setup takes approximately 45-60 minutes.

## Prerequisites

- ✅ Google account
- ✅ Supabase project (URL: `https://zychbbvdrulanzlfoumz.supabase.co`)
- ✅ Android Studio (for getting SHA-1 fingerprint)
- ✅ Xcode (for iOS bundle identifier)

## Important: Supabase vs Firebase

**You are using Supabase**, which means:
- ❌ You do **NOT** need `google-services.json`
- ❌ You do **NOT** need Firebase SDK
- ✅ You **DO** need Google Cloud Console OAuth credentials
- ✅ You **DO** need to configure Supabase dashboard

---

## Step 1: Google Cloud Console Setup (30 minutes)

### 1.1 Create/Select Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click on project dropdown → **New Project**
3. Name: `Kairo Mobile` (or any name)
4. Click **Create**
5. Wait for project creation (~30 seconds)

### 1.2 Enable Google+ API

1. In the left menu, go to **APIs & Services** → **Library**
2. Search for **"Google+ API"**
3. Click on it → Click **Enable**
4. Wait for activation

### 1.3 Configure OAuth Consent Screen

1. Go to **APIs & Services** → **OAuth consent screen**
2. Select **External** (unless you have Google Workspace)
3. Click **Create**

**Fill in the form:**
- **App name**: `Kairo`
- **User support email**: Your email
- **App logo**: (optional, skip for now)
- **Application home page**: Your website or `https://zychbbvdrulanzlfoumz.supabase.co`
- **Authorized domains**: `supabase.co`
- **Developer contact email**: Your email

4. Click **Save and Continue**
5. **Scopes**: Click **Add or Remove Scopes**
   - Select: `email`, `profile`, `openid`
   - Click **Update** → **Save and Continue**
6. **Test users**: (Optional for development)
   - Add your test email addresses
7. Click **Save and Continue**
8. Review and click **Back to Dashboard**

---

## Step 2: Create OAuth 2.0 Client IDs (15 minutes)

You need to create **3 separate OAuth client IDs**:
1. **Web Client** (for Supabase backend)
2. **Android Client** (for Android app)
3. **iOS Client** (for iOS app)

### 2.1 Create Web Client ID (for Supabase)

1. Go to **APIs & Services** → **Credentials**
2. Click **+ Create Credentials** → **OAuth 2.0 Client ID**
3. Application type: **Web application**
4. Name: `Kairo Web Client (Supabase)`

**Authorized JavaScript origins:**
```
https://zychbbvdrulanzlfoumz.supabase.co
```

**Authorized redirect URIs:**
```
https://zychbbvdrulanzlfoumz.supabase.co/auth/v1/callback
```

5. Click **Create**
6. **IMPORTANT**: Copy the **Client ID** (looks like `123456-abc.apps.googleusercontent.com`)
7. Save it as `GOOGLE_WEB_CLIENT_ID` for later

### 2.2 Create Android Client ID

First, get your SHA-1 fingerprint:

**On Windows (PowerShell):**
```powershell
cd android
.\gradlew signingReport
```

**On Mac/Linux:**
```bash
cd android
./gradlew signingReport
```

Look for the output under `> Task :app:signingReport`:
```
Variant: debug
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
```

Copy the **SHA1** value.

**Create the credential:**
1. Back in Google Cloud Console → **Credentials**
2. Click **+ Create Credentials** → **OAuth 2.0 Client ID**
3. Application type: **Android**
4. Name: `Kairo Android Client`
5. **Package name**: `com.example.kairo`
6. **SHA-1 certificate fingerprint**: Paste your SHA-1 from above
7. Click **Create**
8. **IMPORTANT**: Copy the **Client ID**
9. Save it as `GOOGLE_ANDROID_CLIENT_ID` for later

### 2.3 Create iOS Client ID

First, get your iOS Bundle Identifier:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** (blue icon) in the left panel
3. Under **General** tab, find **Bundle Identifier**
4. It should be: `com.example.kairo`

**Create the credential:**
1. Back in Google Cloud Console → **Credentials**
2. Click **+ Create Credentials** → **OAuth 2.0 Client ID**
3. Application type: **iOS**
4. Name: `Kairo iOS Client`
5. **Bundle ID**: `com.example.kairo` (from Xcode)
6. Click **Create**
7. **IMPORTANT**: Copy the **Client ID**
8. Save it as `GOOGLE_IOS_CLIENT_ID` for later
9. Also note the **iOS URL scheme** (reversed client ID)

**Example:**
- Client ID: `123456-abc.apps.googleusercontent.com`
- iOS URL scheme: `com.googleusercontent.apps.123456-abc`

---

## Step 3: Configure Your Flutter App (10 minutes)

### 3.1 Update `.env` File

Open `.env` in your project root and update:

```env
# Supabase Configuration (already configured)
SUPABASE_URL=https://zychbbvdrulanzlfoumz.supabase.co
SUPABASE_ANON_KEY=sb_publishable_jMsnxXl8Co464-LXFE6j3A_wmg8d_Uw

# Google Sign-In - REPLACE WITH YOUR VALUES
GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
GOOGLE_ANDROID_CLIENT_ID=YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com
GOOGLE_IOS_CLIENT_ID=YOUR_IOS_CLIENT_ID.apps.googleusercontent.com
```

**Replace:**
- `YOUR_WEB_CLIENT_ID` → from Step 2.1
- `YOUR_ANDROID_CLIENT_ID` → from Step 2.2
- `YOUR_IOS_CLIENT_ID` → from Step 2.3

### 3.2 Update iOS `Info.plist`

Open `ios/Runner/Info.plist` and update:

**Find this section:**
```xml
<key>GIDClientID</key>
<string>YOUR_IOS_CLIENT_ID.apps.googleusercontent.com</string>
```

**Replace with:**
```xml
<key>GIDClientID</key>
<string>123456-abc.apps.googleusercontent.com</string>
```
(Use your actual iOS Client ID from Step 2.3)

**Find this section:**
```xml
<string>com.googleusercontent.apps.YOUR_IOS_REVERSED_CLIENT_ID</string>
```

**Replace with:**
```xml
<string>com.googleusercontent.apps.123456-abc</string>
```
(Use your actual reversed client ID from Step 2.3)

---

## Step 4: Configure Supabase Dashboard (10 minutes)

### 4.1 Enable Google Provider

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project: `zychbbvdrulanzlfoumz`
3. Go to **Authentication** → **Providers**
4. Find **Google** and toggle it **ON**

### 4.2 Configure Google Provider

**Fill in the following:**

**Client ID (for OAuth)**: Paste your **Web Client ID** from Step 2.1
```
YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

**Client Secret (for OAuth)**:
1. Go back to Google Cloud Console
2. **Credentials** → Find your Web Client
3. Click on it → You'll see **Client Secret**
4. Copy and paste it into Supabase

**Authorized Client IDs**: Add ALL three client IDs (one per line):
```
YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com
YOUR_IOS_CLIENT_ID.apps.googleusercontent.com
```

**Skip nonce check**: ✅ **Enable this** (required for iOS)

### 4.3 Save Configuration

Click **Save** at the bottom.

---

## Step 5: Test Your Setup (15 minutes)

### 5.1 Clean and Rebuild

```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
```

### 5.2 Run on Android Device

**IMPORTANT**: Use a **physical Android device** (emulators are unreliable for Google Sign-In)

```bash
flutter run --release
```

**Test steps:**
1. Open the app
2. Click **"Continue with Google"**
3. ✅ Should see Google account picker
4. Select an account
5. ✅ Should see consent screen (first time)
6. Grant permissions
7. ✅ Should redirect back to app
8. ✅ Should show "Welcome back!" or "Complete registration"

### 5.3 Run on iOS Device

**IMPORTANT**: Use a **physical iOS device** (simulators don't support Sign in with Apple properly)

```bash
flutter run --release -d iPhone
```

Repeat the test steps from 5.2.

---

## Troubleshooting

### Android Error: "Developer Error" or "Error 10"

**Cause**: SHA-1 fingerprint mismatch or missing

**Solution**:
1. Get debug SHA-1: `cd android && ./gradlew signingReport`
2. Go to Google Cloud Console → Android OAuth client
3. Update the SHA-1 fingerprint
4. Wait 5-10 minutes for changes to propagate
5. Uninstall and reinstall the app

### Android Error: "API not enabled"

**Cause**: Google+ API not enabled

**Solution**:
1. Google Cloud Console → **APIs & Services** → **Library**
2. Search "Google+ API" → Click **Enable**

### iOS Error: "No ID token received"

**Cause**: GIDClientID mismatch

**Solution**:
1. Check `ios/Runner/Info.plist` has correct `GIDClientID`
2. Ensure it matches iOS Client ID from Google Console
3. Clean build: `flutter clean`
4. Rebuild: `flutter run`

### Error: "Google sign-in was cancelled"

**Cause**: User cancelled the flow

**Solution**: This is normal user behavior, no action needed.

### Error: "Invalid client"

**Cause**: Client ID not registered in Supabase

**Solution**:
1. Supabase Dashboard → **Authentication** → **Providers** → **Google**
2. Add ALL three client IDs to **Authorized Client IDs**
3. Click **Save**

### Supabase Error: "Email not confirmed"

**Cause**: Supabase email confirmation required

**Solution**:
1. Supabase Dashboard → **Authentication** → **Settings**
2. Disable **Email Confirmation** (for testing)
3. Or check the user's email for confirmation link

---

## Production Checklist

Before releasing to production:

### Google Cloud Console
- [ ] Create **production** OAuth clients (separate from debug)
- [ ] Get **release SHA-1** fingerprint: `keytool -list -v -keystore release.keystore`
- [ ] Add release SHA-1 to Android OAuth client
- [ ] Verify OAuth consent screen for production
- [ ] Add production app URLs and domains

### App Configuration
- [ ] Update `.env` with production credentials
- [ ] Update iOS `Info.plist` with production client ID
- [ ] Ensure Android release build uses correct SHA-1

### Supabase
- [ ] Add production client IDs to Supabase
- [ ] Verify redirect URLs
- [ ] Enable rate limiting
- [ ] Set up monitoring

### Testing
- [ ] Test on physical Android device (release build)
- [ ] Test on physical iOS device (release build)
- [ ] Test with multiple Google accounts
- [ ] Test error scenarios (cancel, network failure)

---

## Summary

**What you created:**
1. ✅ Google Cloud project
2. ✅ OAuth consent screen
3. ✅ Web client ID (for Supabase)
4. ✅ Android client ID
5. ✅ iOS client ID

**What you configured:**
1. ✅ `.env` file with client IDs
2. ✅ iOS `Info.plist` with GIDClientID
3. ✅ Supabase Google provider
4. ✅ Android manifest (already done in code)

**You do NOT need:**
- ❌ Firebase project
- ❌ `google-services.json`
- ❌ Firebase SDK

**You're ready to test!** 🎉

Run `flutter run --release` on a physical device and test Google Sign-In.

---

## Additional Resources

- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth/social-login/auth-google)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Supabase Dashboard](https://supabase.com/dashboard)

---

**Need help?** Check the troubleshooting section or open an issue in the project repository.
