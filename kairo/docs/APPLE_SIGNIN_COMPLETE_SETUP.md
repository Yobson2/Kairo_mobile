# Apple Sign-In Complete Setup for Supabase

## Overview

This guide will help you configure Apple Sign-In for your Kairo app using **Supabase**. The setup takes approximately 60-90 minutes.

## Prerequisites

- ✅ **Apple Developer Account** ($99/year) - **REQUIRED**
- ✅ Supabase project (URL: `https://zychbbvdrulanzlfoumz.supabase.co`)
- ✅ Xcode installed
- ✅ Physical iOS device (Apple Sign-In doesn't work on simulator)

## Important Notes

- **Apple Developer Account is mandatory** - You cannot test Apple Sign-In without it
- **Physical iOS device required** - Simulator support is limited
- **Android support** - Works via web-based flow (configured in Supabase)

---

## Step 1: Apple Developer Portal Setup (30 minutes)

### 1.1 Create App ID

1. Go to [Apple Developer Portal](https://developer.apple.com/account)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Click **Identifiers** → Click **+** button
4. Select **App IDs** → Click **Continue**

**Configure App ID:**
- **Description**: `Kairo Mobile`
- **Bundle ID**: Select **Explicit**
  - Enter: `com.example.kairo` (must match your Xcode bundle ID)
- **Capabilities**: Scroll down and check **Sign in with Apple**
- Click **Continue** → Click **Register**

### 1.2 Create Service ID

1. Still in **Identifiers**, click **+** button
2. Select **Services IDs** → Click **Continue**

**Configure Service ID:**
- **Description**: `Kairo Sign in with Apple`
- **Identifier**: `com.example.kairo.service` (can be anything, but keep this format)
- Check **Sign in with Apple**
- Click **Continue** → Click **Register**

**Configure Service ID for Web:**
1. Click on the Service ID you just created
2. Check **Sign in with Apple**
3. Click **Configure** next to it

**Web Authentication Configuration:**
- **Primary App ID**: Select `Kairo Mobile` (your App ID from 1.1)
- **Domains and Subdomains**:
  ```
  zychbbvdrulanzlfoumz.supabase.co
  ```
- **Return URLs**:
  ```
  https://zychbbvdrulanzlfoumz.supabase.co/auth/v1/callback
  ```
- Click **Save** → Click **Continue** → Click **Save**

### 1.3 Create Private Key (.p8)

1. In **Certificates, Identifiers & Profiles**, go to **Keys**
2. Click **+** button
3. **Key Name**: `Kairo Sign in with Apple Key`
4. Check **Sign in with Apple**
5. Click **Configure** next to it
6. **Primary App ID**: Select `Kairo Mobile`
7. Click **Save** → Click **Continue** → Click **Register**

**Download the key:**
8. Click **Download** - You'll get a `.p8` file
9. **IMPORTANT**: Save this file securely - you can only download it once!
10. **Note the Key ID** (looks like `ABC123DEF4`)

**Get your Team ID:**
1. Go to **Membership** in the left sidebar
2. Note your **Team ID** (looks like `A1B2C3D4E5`)

---

## Step 2: Configure Xcode (15 minutes)

### 2.1 Open Project in Xcode

```bash
cd ios
open Runner.xcworkspace
```

### 2.2 Add Sign in with Apple Capability

1. Select **Runner** (blue icon) in the left panel
2. Select **Runner** target (under TARGETS)
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability** button
5. Search for **Sign in with Apple**
6. Double-click to add it
7. ✅ You should see "Sign in with Apple" in the capabilities list

### 2.3 Verify Bundle Identifier

1. Stay in **Signing & Capabilities** tab
2. Under **Signing**, verify **Bundle Identifier**: `com.example.kairo`
3. Ensure it matches your App ID from Step 1.1

### 2.4 Configure Deployment Target

1. Go to **General** tab
2. **Deployment Info** → **iOS**: Set to **13.0** or higher
3. Apple Sign-In requires iOS 13+

---

## Step 3: Configure Supabase Dashboard (15 minutes)

### 3.1 Enable Apple Provider

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project: `zychbbvdrulanzlfoumz`
3. Go to **Authentication** → **Providers**
4. Find **Apple** and toggle it **ON**

### 3.2 Configure Apple Provider

You'll need 4 things from Apple Developer Portal:

**1. Service ID (Services ID Identifier)**:
```
com.example.kairo.service
```
(From Step 1.2)

**2. Team ID**:
```
A1B2C3D4E5
```
(From Step 1.3 - Membership page)

**3. Key ID**:
```
ABC123DEF4
```
(From Step 1.3 - When you created the .p8 key)

**4. Private Key (Secret Key)**:
1. Open the `.p8` file you downloaded in Step 1.3
2. Open it with a text editor (Notepad, TextEdit, VS Code)
3. Copy the **entire contents** including the BEGIN and END lines:
```
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg...
[multiple lines of encoded text]
...
-----END PRIVATE KEY-----
```

**Fill in Supabase:**
- **Services ID**: `com.example.kairo.service`
- **Team ID**: `A1B2C3D4E5`
- **Key ID**: `ABC123DEF4`
- **Secret Key**: Paste the entire `.p8` file contents

### 3.3 Save Configuration

Click **Save** at the bottom.

---

## Step 4: iOS App Configuration (Already Done ✅)

Your iOS configuration is already set up in `ios/Runner/Info.plist`:

```xml
<!-- Supabase Deep Link -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.kairo</string>
    </array>
  </dict>
</array>
```

This allows Supabase to redirect back to your app after authentication.

---

## Step 5: Test on iOS Device (20 minutes)

### 5.1 Clean and Rebuild

```bash
flutter clean
flutter pub get
cd ios
pod install
cd ..
```

### 5.2 Run on Physical Device

**CRITICAL**: You **MUST** use a physical iOS device with an active Apple ID.

```bash
flutter run --release -d iPhone
```

### 5.3 Test Apple Sign-In

1. Open the app
2. Click **"Continue with Apple"**
3. ✅ Should see Apple authentication dialog
4. ✅ Touch ID / Face ID prompt
5. Choose to share or hide email
6. ✅ Should redirect back to app
7. ✅ Should show "Welcome back!" or "Complete registration"

**First-time users:**
- You can choose to **Share My Email** or **Hide My Email**
- If you hide your email, Apple will create a relay email like `abc123@privaterelay.appleid.com`

**Returning users:**
- Will see "Continue with Apple ID"
- Should authenticate quickly with Face ID / Touch ID

---

## Step 6: Test on Android (Optional, 15 minutes)

Apple Sign-In on Android works via **web-based flow** (no native SDK).

### 6.1 Run on Android Device

```bash
flutter run --release -d Android
```

### 6.2 Test Flow

1. Click **"Continue with Apple"**
2. ✅ Should open web browser
3. Enter Apple ID credentials
4. ✅ Should redirect back to app
5. ✅ Should show "Welcome back!" or "Complete registration"

**Note**: Android experience is less seamless than iOS (uses browser).

---

## Troubleshooting

### iOS Error: "invalid_client"

**Cause**: Bundle ID mismatch or Service ID not configured

**Solution**:
1. Verify Xcode Bundle ID: `com.example.kairo`
2. Verify Apple Developer App ID: `com.example.kairo`
3. Verify Service ID is configured with correct domains
4. Wait 10-15 minutes for Apple's servers to propagate changes

### iOS Error: "unauthorized_client"

**Cause**: Service ID not properly configured in Apple Developer Portal

**Solution**:
1. Apple Developer Portal → **Service ID**
2. Click **Configure** next to Sign in with Apple
3. Verify **Domains**: `zychbbvdrulanzlfoumz.supabase.co`
4. Verify **Return URL**: `https://zychbbvdrulanzlfoumz.supabase.co/auth/v1/callback`
5. Click **Save**

### iOS Error: "Sign in with Apple capability missing"

**Cause**: Capability not added in Xcode

**Solution**:
1. Open `ios/Runner.xcworkspace`
2. Select Runner → Signing & Capabilities
3. Click **+ Capability** → Add **Sign in with Apple**
4. Clean build: `flutter clean && flutter run`

### Supabase Error: "Invalid private key"

**Cause**: Private key not copied correctly

**Solution**:
1. Open the `.p8` file in a text editor
2. Copy the **ENTIRE** contents including BEGIN/END lines
3. No extra spaces or line breaks
4. Paste into Supabase **Secret Key** field

### Android: Opens browser but fails to redirect

**Cause**: Deep link not configured

**Solution**:
1. Your `AndroidManifest.xml` is already configured ✅
2. Verify Supabase Return URL: `https://zychbbvdrulanzlfoumz.supabase.co/auth/v1/callback`
3. Test in a different browser

### Error: "User cancelled"

**Cause**: User tapped "Cancel" during authentication

**Solution**: This is normal user behavior, no action needed.

---

## Production Checklist

Before releasing to production:

### Apple Developer Portal
- [ ] App ID created with production Bundle ID
- [ ] Service ID configured with production domain
- [ ] Private key (.p8) backed up securely
- [ ] All configurations saved

### Xcode
- [ ] Sign in with Apple capability enabled
- [ ] Bundle Identifier matches App ID exactly
- [ ] Deployment target iOS 13.0+
- [ ] Production signing configured

### Supabase
- [ ] Apple provider enabled
- [ ] All 4 fields correctly filled (Service ID, Team ID, Key ID, Private Key)
- [ ] Return URL matches production domain
- [ ] Configuration saved

### Testing
- [ ] Test on physical iPhone (iOS 13+)
- [ ] Test with multiple Apple IDs
- [ ] Test "Share Email" flow
- [ ] Test "Hide Email" flow
- [ ] Test "Cancel" flow
- [ ] Test on Android (web flow)

---

## Security Best Practices

### 1. Protect Your Private Key (.p8)

- ✅ Store in a secure password manager
- ✅ Never commit to version control
- ✅ Backup in multiple secure locations
- ❌ Never share publicly
- ❌ Never email or message to others

### 2. Key Rotation

- If your `.p8` key is compromised:
  1. Revoke the old key in Apple Developer Portal
  2. Create a new key
  3. Update Supabase with the new key
  4. Re-deploy your app

### 3. Email Privacy

- Users can choose to hide their email
- Apple will provide a relay email: `abc123@privaterelay.appleid.com`
- Your app receives this relay, not the real email
- Emails sent to the relay are forwarded to the user
- User can disable relay at any time

---

## Understanding Apple Sign-In Flow

### iOS Native Flow

```
User clicks "Continue with Apple"
  ↓
Native Apple dialog appears
  ↓
Face ID / Touch ID authentication
  ↓
User chooses email sharing preference
  ↓
Apple returns credentials to app
  ↓
App sends credentials to Supabase
  ↓
Supabase validates with Apple servers
  ↓
User authenticated ✅
```

### Android Web Flow

```
User clicks "Continue with Apple"
  ↓
Browser opens with Apple login page
  ↓
User enters Apple ID credentials
  ↓
2FA if enabled
  ↓
User chooses email sharing preference
  ↓
Browser redirects to Supabase callback
  ↓
Supabase validates credentials
  ↓
Deep link redirects back to app
  ↓
User authenticated ✅
```

---

## FAQ

### Q: Do I really need a paid Apple Developer account?

**A**: Yes, absolutely. Apple Sign-In requires:
- App ID with Sign in with Apple capability
- Service ID for web authentication
- Private key (.p8) for server validation

All of these **require a paid Apple Developer account ($99/year)**.

### Q: Can I test on iOS Simulator?

**A**: Limited support. Apple Sign-In uses system-level authentication that requires:
- Actual Apple ID signed in to the device
- Touch ID / Face ID support
- Keychain access

Use a **physical iOS device** for reliable testing.

### Q: Will Apple Sign-In work on Android?

**A**: Yes! It uses a web-based flow:
1. Opens browser with Apple login
2. User authenticates
3. Redirects back to app

The experience is less seamless than iOS but fully functional.

### Q: What if a user hides their email?

**A**: Apple provides a relay email like `abc123@privaterelay.appleid.com`:
- Your app receives this relay email
- You can send emails to it (forwarded to user)
- User can disable relay anytime
- Store this relay as the user's email in your database

### Q: Can I use the same Service ID for multiple apps?

**A**: No, create a separate Service ID for each app:
- Production app: `com.yourapp.service`
- Staging app: `com.yourapp.staging.service`
- Development app: `com.yourapp.dev.service`

### Q: How do I get a user's real email if they hide it?

**A**: You can't. Apple's privacy feature is intentional:
- Respect user privacy
- Use the relay email for communication
- Don't try to circumvent this (violates Apple guidelines)

---

## Summary

**What you created:**
1. ✅ App ID with Sign in with Apple capability
2. ✅ Service ID configured for web authentication
3. ✅ Private key (.p8) for server-side validation

**What you configured:**
1. ✅ Xcode Sign in with Apple capability
2. ✅ Supabase Apple provider (Service ID, Team ID, Key ID, Private Key)
3. ✅ iOS Info.plist with deep link (already done)
4. ✅ Android manifest with deep link (already done)

**You do NOT need:**
- ❌ Firebase project
- ❌ Additional iOS SDK setup
- ❌ CocoaPods configuration (handled by Flutter)

**You're ready to test!** 🎉

Run `flutter run --release -d iPhone` on a physical iOS device.

---

## Additional Resources

- [Sign in with Apple Documentation](https://developer.apple.com/documentation/sign_in_with_apple)
- [Supabase Apple Auth Guide](https://supabase.com/docs/guides/auth/social-login/auth-apple)
- [Apple Developer Portal](https://developer.apple.com/account)
- [Flutter sign_in_with_apple Package](https://pub.dev/packages/sign_in_with_apple)

---

**Need help?** Check the troubleshooting section or contact Apple Developer Support.
