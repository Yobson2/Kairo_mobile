# Quick Start: Social Authentication Testing

This is a quick guide to get Google and Apple Sign-In working for **local testing**. For production setup, see the detailed guides.

## Prerequisites
- Flutter installed
- Android Studio or Xcode
- Physical device or emulator
- Supabase project

---

## Step 1: Install Dependencies (Already Done ✅)

The dependencies have been added to `pubspec.yaml`:
```yaml
google_sign_in: ^6.2.1
sign_in_with_apple: ^6.1.0
crypto: ^3.0.3
```

Run:
```bash
flutter pub get
```

---

## Step 2: Quick Google Sign-In Setup (Android)

### 2.1 Get SHA-1 Fingerprint
```bash
cd android
./gradlew signingReport
```

Copy the SHA-1 under **Variant: debug** → **Config: debug**

### 2.2 Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project: "Kairo Mobile"
3. Enable "Google+ API"

### 2.3 Configure OAuth Consent
1. Go to **APIs & Services** → **OAuth consent screen**
2. Choose **External**, fill in app name and email
3. Add scopes: `email`, `profile`, `openid`

### 2.4 Create Android OAuth Client
1. Go to **APIs & Services** → **Credentials**
2. Create **OAuth client ID** → **Android**
3. Enter:
   - Package name: `com.example.kairo` (from `android/app/build.gradle`)
   - SHA-1: Paste from step 2.1
4. Click **Create**

### 2.5 Configure Supabase
1. Go to Supabase dashboard → **Authentication** → **Providers**
2. Enable **Google**
3. Enter Web Client ID (create one if needed)
4. Save

**Test it:**
```bash
flutter run
```
Click "Continue with Google" - it should work!

---

## Step 3: Quick Apple Sign-In Setup (iOS - Requires Apple Developer Account)

### 3.1 Enable in Xcode
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** → **Signing & Capabilities**
3. Click **+ Capability** → Add **Sign in with Apple**

### 3.2 Apple Developer Portal
1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. **Identifiers** → Create App ID with Bundle ID (e.g., `com.example.kairo`)
3. Enable **Sign in with Apple** capability
4. Create **Service ID** for web auth
5. Create **Private Key** (.p8 file) - **DOWNLOAD AND SAVE IT**

### 3.3 Configure Service ID
1. Edit your Service ID
2. Enable **Sign in with Apple**
3. Configure:
   - Domain: `your-project.supabase.co`
   - Redirect URL: `https://your-project.supabase.co/auth/v1/callback`

### 3.4 Configure Supabase
1. Supabase dashboard → **Authentication** → **Providers**
2. Enable **Apple**
3. Enter:
   - Service ID: `com.example.kairo.service`
   - Team ID: (from Apple Developer Portal)
   - Key ID: (from .p8 key file)
   - Private Key: (paste .p8 file contents)
4. Save

**Test it:**
```bash
flutter run
```
Click "Continue with Apple" - it should work!

---

## Step 4: Verify Implementation

### Test Flow for Existing User:
1. Click "Continue with Google" or "Continue with Apple"
2. Sign in with your account
3. If you're in the database → You see "Welcome back!"
4. Router redirects you to **Dashboard**

### Test Flow for New User:
1. Click "Continue with Google" or "Continue with Apple"
2. Sign in with a NEW account
3. You see "Please complete your registration"
4. You're redirected to **Registration Screen**
5. Complete profile
6. Router redirects you to **Dashboard**

---

## Troubleshooting

### Google Sign-In Issues

**Error: "PlatformException(sign_in_failed)"**
- ✅ Check SHA-1 matches in Google Cloud Console
- ✅ Verify package name is correct
- ✅ Make sure Google+ API is enabled

**Error: "API not enabled"**
- ✅ Enable Google+ API in Google Cloud Console

### Apple Sign-In Issues

**Error: "invalid_client"**
- ✅ Check Bundle ID matches in Apple Developer Portal
- ✅ Verify Sign in with Apple capability is enabled in Xcode

**Error: "User cancelled"**
- ✅ This is normal, user cancelled the sign-in

### Supabase Issues

**User signs in but not redirected**
- ✅ Check Supabase auth logs for errors
- ✅ Verify providers are enabled
- ✅ Check redirect URLs are correct

---

## Quick Configuration Files Reference

### Environment Variables (.env)
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### Android (android/app/build.gradle)
```gradle
defaultConfig {
    applicationId "com.example.kairo"  // This is your package name
    // ...
}
```

### iOS Bundle ID
Check in Xcode: **Runner** → **General** → **Bundle Identifier**

---

## Next Steps

Once basic testing works:

1. **Production Setup**:
   - Get production SHA-1 from your release keystore
   - Create production OAuth clients
   - Update Supabase with production credentials

2. **Read Detailed Guides**:
   - [Google Sign-In Setup](./GOOGLE_SIGNIN_SETUP.md)
   - [Apple Sign-In Setup](./APPLE_SIGNIN_SETUP.md)
   - [Implementation Details](./SOCIAL_AUTH_IMPLEMENTATION.md)

3. **Test Edge Cases**:
   - User cancels sign-in
   - Network errors
   - Email privacy (Apple)
   - First-time vs returning users

---

## Expected Behavior

### LoginScreen (`lib/features/auth/presentation/screens/login_screen.dart`)

When user clicks **"Continue with Google"**:
1. Native Google sign-in dialog appears
2. User selects account
3. App checks Supabase database
4. **If user exists**: Shows "Welcome back!" → Routes to dashboard
5. **If new user**: Shows "Please complete registration" → Routes to registration

When user clicks **"Continue with Apple"**:
1. Native Apple sign-in dialog appears
2. User authenticates with Face ID/Touch ID/Password
3. App checks Supabase database
4. **If user exists**: Shows "Welcome back!" → Routes to dashboard
5. **If new user**: Shows "Please complete registration" → Routes to registration

### Error Handling
- Shows user-friendly error messages in red SnackBars
- Handles cancellations gracefully
- Loading states prevent double-clicks

---

## Architecture Overview

```
LoginScreen (UI)
    ↓
GoogleSignInProvider / AppleSignInProvider (State Management)
    ↓
AuthRepository (Domain Layer)
    ↓
AuthRemoteDataSource (Data Layer)
    ↓
Supabase + Google/Apple SDKs
```

---

## Testing Checklist

- [ ] Google Sign-In works on Android
- [ ] Apple Sign-In works on iOS
- [ ] Existing users are redirected to dashboard
- [ ] New users are redirected to registration
- [ ] Error messages appear for failures
- [ ] Loading states show during sign-in
- [ ] User can cancel sign-in without errors
- [ ] Supabase auth logs show successful sign-ins

---

## Support

If you encounter issues:

1. Check the detailed setup guides in `/docs`
2. Verify all configuration steps were followed
3. Check Supabase logs for authentication errors
4. Run `flutter clean && flutter pub get` and try again
5. Test on a physical device (some features don't work on emulators)

---

**Status**: ✅ Implementation Complete - Ready for Configuration and Testing

The code is fully implemented and follows best practices. The only remaining step is to configure the external services (Google Cloud, Apple Developer, Supabase) using the guides provided.
