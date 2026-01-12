# Apple Sign-In Setup Guide

This guide will walk you through setting up Apple Sign-In (Sign in with Apple) for the Kairo mobile app on iOS, Android, and Web platforms.

## Prerequisites

- Apple Developer Account (required, $99/year)
- Xcode installed (for iOS development)
- Access to Apple Developer Portal
- Your app's Bundle ID

---

## Part 1: Apple Developer Portal Setup

### 1. Register App ID

1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Click **Identifiers** → **+** (to add new)
4. Select **App IDs** → Click **Continue**
5. Fill in:
   - **Description**: Kairo Mobile
   - **Bundle ID**: `com.example.kairo` (use your actual bundle ID)
6. Under **Capabilities**, enable **Sign in with Apple**
7. Click **Continue** → **Register**

### 2. Create Service ID (for Web/Android)

1. In **Identifiers**, click **+** to add new
2. Select **Services IDs** → Click **Continue**
3. Fill in:
   - **Description**: Kairo Web Service
   - **Identifier**: `com.example.kairo.service` (must be unique)
4. Click **Continue** → **Register**
5. Click on the newly created Service ID
6. Enable **Sign in with Apple**
7. Click **Configure** next to "Sign in with Apple"
8. Fill in:
   - **Primary App ID**: Select your app ID from step 1
   - **Domains and Subdomains**: Add your Supabase domain (e.g., `your-project.supabase.co`)
   - **Return URLs**: Add `https://your-project.supabase.co/auth/v1/callback`
9. Click **Save** → **Continue** → **Save**

### 3. Create Private Key for Sign in with Apple

1. Go to **Keys** in the left sidebar
2. Click **+** to create a new key
3. Fill in:
   - **Key Name**: Kairo Apple Sign In Key
4. Enable **Sign in with Apple**
5. Click **Configure** next to "Sign in with Apple"
6. Select your **Primary App ID**
7. Click **Save** → **Continue** → **Register**
8. **Download the .p8 key file** (you can only download once!)
9. Note down:
   - **Key ID** (10 characters, e.g., `ABC123DEFG`)
   - **Team ID** (found in the top right of Developer Portal)

**IMPORTANT**: Keep the `.p8` file secure and never commit it to version control!

---

## Part 2: iOS Setup

### 1. Enable Sign in with Apple in Xcode

1. Open your project in Xcode: `open ios/Runner.xcworkspace`
2. Select **Runner** in the project navigator
3. Select **Runner** under TARGETS
4. Go to **Signing & Capabilities** tab
5. Click **+ Capability**
6. Add **Sign in with Apple**

### 2. Update Info.plist (Already configured)

The `sign_in_with_apple` package handles most of the configuration automatically. Verify your Bundle ID matches the one registered in Apple Developer Portal.

### 3. Update Entitlements

Xcode should automatically create `Runner.entitlements` with:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>
</dict>
</plist>
```

---

## Part 3: Android Setup

Apple Sign-In on Android uses a web-based flow.

### 1. Update AndroidManifest.xml

Add the following to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <application>
        <!-- Add this activity for Apple Sign-In web flow -->
        <activity
            android:name="com.aboutyou.dart_packages.sign_in_with_apple.SignInWithAppleCallback"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />

                <data android:scheme="signinwithapple" />
                <data android:path="callback" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### 2. Configure Redirect URI

The redirect URI for Android will be: `signinwithapple://callback`

Make sure this is added to your Service ID configuration in Apple Developer Portal (see Part 1, Step 2).

---

## Part 4: Supabase Configuration

### 1. Enable Apple Provider in Supabase

1. Go to your Supabase project dashboard
2. Navigate to **Authentication** → **Providers**
3. Find **Apple** and enable it
4. Fill in the required fields:
   - **Enabled**: Toggle ON
   - **Service ID**: Your Service ID from Part 1, Step 2 (e.g., `com.example.kairo.service`)
   - **Team ID**: Your Team ID from Apple Developer Portal
   - **Key ID**: Your Key ID from Part 1, Step 3
   - **Private Key**: Paste the contents of your `.p8` file
5. Under **Redirect URL**, add:
   - `https://your-project.supabase.co/auth/v1/callback`
6. Click **Save**

### 2. Configure Authorized Domains

In Supabase, go to **Authentication** → **URL Configuration**:
- Add your production domain (if you have one)
- The callback URL is automatically configured

---

## Part 5: Testing Configuration

### Create a Test User

Apple requires that you test Sign in with Apple before releasing to production:

1. Go to **App Store Connect**
2. Navigate to **Users and Access** → **Sandbox Testers**
3. Click **+** to create a test user
4. Fill in the required information
5. Use this test account to sign in during development

### Test on iOS:
1. Run the app: `flutter run`
2. Click "Continue with Apple"
3. Sign in with your Apple ID (or sandbox tester)
4. Grant permissions
5. Verify the authentication flow

### Test on Android:
1. Run the app: `flutter run`
2. Click "Continue with Apple"
3. You'll be redirected to Apple's web sign-in
4. Sign in with your Apple ID
5. You'll be redirected back to the app

---

## Part 6: Handle User Email Privacy

Apple allows users to hide their email address. Handle this in your app:

### Check for Private Relay Email

When a user signs in with Apple, they might provide a private relay email (e.g., `xyz123@privaterelay.appleid.com`). Your implementation already handles this:

```dart
// In auth_remote_datasource.dart
final credential = await SignInWithApple.getAppleIDCredential(
  scopes: [
    AppleIDAuthorizationScopes.email,
    AppleIDAuthorizationScopes.fullName,
  ],
  nonce: nonce,
);
```

### Important Notes:

1. **Email is only provided on first sign-in**: If the user has already signed in once, Apple won't provide the email again
2. **Store email securely**: Save the email during first sign-in
3. **Handle null email**: Your code should gracefully handle cases where email is null

---

## Part 7: Environment Variables

Update your `.env` file:

```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# Apple Sign-In (for reference, not used in client)
APPLE_SERVICE_ID=com.example.kairo.service
APPLE_TEAM_ID=ABC123DEFG
APPLE_KEY_ID=XYZ789
```

**IMPORTANT**: Never store the `.p8` private key in your app or `.env` file. It should only be stored in Supabase.

---

## Part 8: Production Checklist

Before releasing to production:

### iOS
- [ ] Bundle ID matches Apple Developer Portal
- [ ] Sign in with Apple capability is enabled in Xcode
- [ ] App ID is registered with Sign in with Apple enabled
- [ ] Test with production Apple ID accounts

### Android
- [ ] AndroidManifest.xml includes the callback activity
- [ ] Service ID is configured with correct redirect URIs
- [ ] Test the web-based sign-in flow

### Supabase
- [ ] Apple provider is enabled
- [ ] Service ID, Team ID, Key ID, and Private Key are correctly configured
- [ ] Redirect URLs are whitelisted

### General
- [ ] Test sign-in flow with new users
- [ ] Test sign-in flow with existing users
- [ ] Test email hiding functionality
- [ ] Handle errors gracefully
- [ ] Test on multiple devices

---

## Troubleshooting

### iOS Issues

**"invalid_client"**
- Verify Bundle ID matches App ID in Apple Developer Portal
- Check that Sign in with Apple capability is enabled in Xcode

**"invalid_request"**
- Verify your App ID has Sign in with Apple enabled
- Check that you're using the correct Team ID

**"User cancelled"**
- This is normal user behavior, handle gracefully

### Android Issues

**"redirect_uri_mismatch"**
- Verify Service ID has correct redirect URI configured
- Check AndroidManifest.xml has the callback activity

**"invalid_client"**
- Verify Service ID is correctly configured in Apple Developer Portal
- Check Supabase has correct Service ID

### Supabase Issues

**"Invalid JWT"**
- Verify the .p8 private key is correctly pasted in Supabase
- Check Key ID matches
- Verify Team ID is correct

**"Email not provided"**
- Remember: Email is only provided on first sign-in
- User might have chosen to hide their email
- Check if you're storing email on first sign-in

---

## Security Best Practices

1. **Never commit** the `.p8` private key to version control
2. Add `*.p8` to your `.gitignore`
3. Store the private key only in Supabase
4. Use **different Service IDs** for development and production
5. Enable **2FA** on your Apple Developer account
6. Rotate keys if compromised
7. Monitor sign-in attempts in Supabase logs

---

## Important Notes

### Email Privacy
- Users can choose to hide their email
- Email is only provided on **first sign-in**
- Store user email during first sign-in to your database
- Handle cases where email is `null` or a private relay email

### Name Handling
- User's full name is only provided on first sign-in
- The name might be `null` on subsequent sign-ins
- Store the name in your database during first sign-in

### Testing in Development
- Use Sandbox Testers from App Store Connect
- Real Apple IDs won't work in development mode
- Production users need a production build

---

## Additional Resources

- [Sign in with Apple Documentation](https://developer.apple.com/sign-in-with-apple/)
- [Apple Developer Portal](https://developer.apple.com/account/)
- [sign_in_with_apple Flutter Package](https://pub.dev/packages/sign_in_with_apple)
- [Supabase Apple Auth Docs](https://supabase.com/docs/guides/auth/social-login/auth-apple)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

---

## App Store Requirements

**IMPORTANT**: If you offer any other third-party sign-in options (Google, Facebook, etc.), Apple **requires** you to also offer Sign in with Apple.

From Apple's Human Interface Guidelines:
> "If your app uses a third-party or social login service to set up or authenticate the user's primary account with the app, you must offer Sign in with Apple as an equivalent option."

You've implemented both Google and Apple sign-in, so you're compliant with this requirement!
