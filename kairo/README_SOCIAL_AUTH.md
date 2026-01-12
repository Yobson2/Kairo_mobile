# 🔐 Social Authentication - Quick Reference

## Current Status: ✅ Code Complete, ⏳ Configuration Pending

Your Kairo app has **production-ready social authentication code**, but needs OAuth credentials configuration to function.

---

## ⚡ Quick Start (2-3 hours)

### 1️⃣ Google Sign-In Setup (60 min)

**What you need**: Google account

**Steps**:
1. Open [`docs/GOOGLE_OAUTH_SETUP.md`](docs/GOOGLE_OAUTH_SETUP.md)
2. Create Google Cloud project
3. Create 3 OAuth clients (Web, Android, iOS)
4. Update `.env` with client IDs
5. Update `ios/Runner/Info.plist`
6. Configure Supabase dashboard

**Result**: Google Sign-In works on Android and iOS ✅

### 2️⃣ Apple Sign-In Setup (90 min)

**What you need**: Apple Developer Account ($99/year) + Physical iOS device

**Steps**:
1. Open [`docs/APPLE_SIGNIN_COMPLETE_SETUP.md`](docs/APPLE_SIGNIN_COMPLETE_SETUP.md)
2. Create App ID + Service ID in Apple Developer Portal
3. Generate Private Key (.p8)
4. Configure Xcode
5. Configure Supabase dashboard

**Result**: Apple Sign-In works on iOS (native) and Android (web) ✅

### 3️⃣ Test (30 min)

```bash
flutter clean && flutter pub get
flutter run --release -d [device]
```

Test both Google and Apple sign-in on physical devices.

---

## 📂 Documentation

| File | Purpose | Time |
|------|---------|------|
| [`FIXES_APPLIED.md`](FIXES_APPLIED.md) | What was fixed and why | 5 min read |
| [`docs/SETUP_INSTRUCTIONS.md`](docs/SETUP_INSTRUCTIONS.md) | Master setup guide | 10 min read |
| [`docs/GOOGLE_OAUTH_SETUP.md`](docs/GOOGLE_OAUTH_SETUP.md) | Complete Google setup | 60 min follow |
| [`docs/APPLE_SIGNIN_COMPLETE_SETUP.md`](docs/APPLE_SIGNIN_COMPLETE_SETUP.md) | Complete Apple setup | 90 min follow |

---

## 🔑 Configuration Files You Need to Update

### 1. `.env` (Root directory)

```env
# Currently has placeholders - UPDATE WITH REAL VALUES
GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
GOOGLE_ANDROID_CLIENT_ID=YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com
GOOGLE_IOS_CLIENT_ID=YOUR_IOS_CLIENT_ID.apps.googleusercontent.com
```

Get these from: [Google Cloud Console](https://console.cloud.google.com/apis/credentials)

### 2. `ios/Runner/Info.plist`

```xml
<!-- Currently has placeholders - UPDATE WITH REAL VALUES -->
<key>GIDClientID</key>
<string>YOUR_IOS_CLIENT_ID.apps.googleusercontent.com</string>

<string>com.googleusercontent.apps.YOUR_IOS_REVERSED_CLIENT_ID</string>
```

Get these from: Google Cloud Console → iOS OAuth Client

### 3. Supabase Dashboard

**Google Provider**:
- Enable Google authentication
- Add all 3 client IDs to "Authorized Client IDs"
- Add Client Secret

**Apple Provider**:
- Enable Apple authentication
- Add Service ID, Team ID, Key ID, and Private Key (.p8)

---

## ✅ What's Already Fixed

Your codebase now has:

✅ **Environment variable loading** - Loads Google OAuth client IDs from `.env`
✅ **Platform detection** - Android uses web client ID, iOS uses Info.plist
✅ **Configuration validation** - Clear error if credentials not configured
✅ **Android deep links** - OAuth callbacks work on Android
✅ **iOS deep links** - OAuth callbacks work on iOS
✅ **Comprehensive docs** - Step-by-step setup guides
✅ **Error handling** - Helpful error messages with guide references

---

## 🚫 What's NOT Needed

Your app uses **Supabase**, not Firebase, so you do NOT need:

❌ `google-services.json` (Android)
❌ `GoogleService-Info.plist` (iOS)
❌ Firebase SDK
❌ Firebase Console configuration

**Why?** Supabase uses OAuth directly via Google Cloud Console, not Firebase.

---

## 🎯 Testing Checklist

Before testing, ensure:

- [ ] `.env` has real Google client IDs (not "YOUR_...")
- [ ] `ios/Runner/Info.plist` has real iOS client ID
- [ ] Supabase Google provider configured
- [ ] Supabase Apple provider configured (if testing Apple)
- [ ] Using **physical device** (not emulator/simulator)

Then test:

- [ ] Google Sign-In → Account picker appears
- [ ] Google Sign-In → New user redirects to registration
- [ ] Google Sign-In → Existing user redirects to dashboard
- [ ] Apple Sign-In → Authentication dialog appears
- [ ] Apple Sign-In → New user redirects to registration
- [ ] Apple Sign-In → Existing user redirects to dashboard

---

## 🐛 Common Issues

### "Google Sign-In not configured"
**Solution**: Update `.env` with real client IDs from Google Console
**Guide**: `docs/GOOGLE_OAUTH_SETUP.md` Step 3

### "Developer Error" (Android)
**Cause**: SHA-1 fingerprint not added to Google Console
**Solution**: `cd android && ./gradlew signingReport` → Add to Google Console
**Guide**: `docs/GOOGLE_OAUTH_SETUP.md` Step 2.2

### "No ID token" (iOS)
**Cause**: GIDClientID mismatch in Info.plist
**Solution**: Verify client ID matches Google Console iOS client
**Guide**: `docs/GOOGLE_OAUTH_SETUP.md` Step 3.2

### "invalid_client" (Apple)
**Cause**: Service ID not configured properly
**Solution**: Verify domains and return URLs in Apple Developer Portal
**Guide**: `docs/APPLE_SIGNIN_COMPLETE_SETUP.md` Step 1.2

---

## 📞 Support

### Quick Help
- **Setup stuck?** → Check [`docs/SETUP_INSTRUCTIONS.md`](docs/SETUP_INSTRUCTIONS.md)
- **Google issues?** → See [`docs/GOOGLE_OAUTH_SETUP.md`](docs/GOOGLE_OAUTH_SETUP.md) Troubleshooting section
- **Apple issues?** → See [`docs/APPLE_SIGNIN_COMPLETE_SETUP.md`](docs/APPLE_SIGNIN_COMPLETE_SETUP.md) Troubleshooting section

### External Resources
- [Supabase Documentation](https://supabase.com/docs/guides/auth/social-login)
- [Google Sign-In Package](https://pub.dev/packages/google_sign_in)
- [Apple Sign-In Package](https://pub.dev/packages/sign_in_with_apple)

---

## 🎓 How It Works

### Authentication Flow

```
User clicks "Continue with Google/Apple"
         ↓
Native SDK shows picker/dialog
         ↓
User authenticates
         ↓
SDK returns tokens (idToken, accessToken)
         ↓
App sends tokens to Supabase
         ↓
Supabase validates with Google/Apple servers
         ↓
Supabase checks if user exists in database
         ↓
    ┌────┴────┐
    ↓         ↓
Exists    New User
    ↓         ↓
Dashboard  Register
```

### Code Architecture

```
LoginScreen (UI)
    ↓
GoogleSignInProvider / AppleSignInProvider (State)
    ↓
AuthRepository (Domain)
    ↓
AuthRemoteDataSource (Data)
    ↓
Supabase Auth (Backend)
```

---

## 💡 Key Points

### Supabase vs Firebase
Your app uses **Supabase**, which means:
- ✅ OAuth via Google Cloud Console (not Firebase)
- ✅ Full PostgreSQL database access
- ✅ Row-level security
- ✅ No vendor lock-in

### Why Physical Devices?
Social authentication requires:
- Real Google/Apple accounts
- Proper keychain/secure storage
- System-level authentication dialogs
- Deep link handling

Emulators/simulators have limited support.

### Production Deployment
When ready for production:
1. Create **production** OAuth clients (separate from debug)
2. Get **release SHA-1**: `keytool -list -v -keystore release.keystore`
3. Update Supabase with production credentials
4. Test with production builds

---

## 🎉 Next Steps

1. **Read**: [`FIXES_APPLIED.md`](FIXES_APPLIED.md) - Understand what was fixed
2. **Setup Google**: [`docs/GOOGLE_OAUTH_SETUP.md`](docs/GOOGLE_OAUTH_SETUP.md) - 60 minutes
3. **Setup Apple**: [`docs/APPLE_SIGNIN_COMPLETE_SETUP.md`](docs/APPLE_SIGNIN_COMPLETE_SETUP.md) - 90 minutes
4. **Test**: Run on physical devices - 30 minutes

**Total time**: 2-3 hours → **Fully functional social authentication** ✅

---

**Start now**: Open [`docs/GOOGLE_OAUTH_SETUP.md`](docs/GOOGLE_OAUTH_SETUP.md) and follow Step 1.
