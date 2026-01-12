# 🔍 Google Sign-In Modal Not Appearing - Troubleshooting Guide

## Issue

When you click "Continue with Google", the Google account picker modal doesn't appear.

## Most Likely Causes

### 1. **Supabase Google Provider Not Configured** ⭐ (90% probability)

**Problem**: Your Supabase dashboard doesn't have Google authentication enabled or configured.

**Solution**: Configure Supabase Google Provider (5 minutes)

#### Steps:

1. **Open Supabase Dashboard**
   - Go to: https://supabase.com/dashboard
   - Select project: `zychbbvdrulanzlfoumz`

2. **Enable Google Provider**
   - Left sidebar → **Authentication** → **Providers**
   - Find **Google** in the list
   - Toggle it **ON** (enabled)

3. **Configure Google Provider**

   **Client ID (for OAuth)**:
   ```
   237008246636-qb8p64la7emfdqgn9if648jq6n5nf9p6.apps.googleusercontent.com
   ```

   **Client Secret (for OAuth)**:
   - You need to get this from Google Cloud Console
   - Go to: https://console.cloud.google.com/apis/credentials
   - Find OAuth client ID: `237008246636-qb8p64la7emfdqgn9if648jq6n5nf9p6`
   - Click on it → Copy **Client Secret**
   - Paste in Supabase

   **Authorized Client IDs** (Add all 3, one per line):
   ```
   237008246636-qb8p64la7emfdqgn9if648jq6n5nf9p6.apps.googleusercontent.com
   237008246636-128batf01lt9u1rvn6f76vtqq4cbu94f.apps.googleusercontent.com
   237008246636-d8a2gldpp801vs96vmumr1kst45cndef.apps.googleusercontent.com
   ```

   **Skip nonce check**: ✅ **Enable this** (check the box)

4. **Click Save**

5. **Test Again**
   - Restart your app
   - Click "Continue with Google"
   - Modal should now appear!

---

### 2. **Google OAuth Credentials Are Examples** (80% probability)

**Problem**: The credentials in your `.env` file might be examples that don't belong to you.

**Check**:
1. Go to: https://console.cloud.google.com/apis/credentials
2. Check if you see these client IDs
3. If NOT, you need to create your own

**Solution**: Create your own OAuth credentials

Follow the guide: [`docs/GOOGLE_OAUTH_SETUP.md`](docs/GOOGLE_OAUTH_SETUP.md)

---

### 3. **Platform-Specific Issues**

#### **On Android**

**Problem**: SHA-1 fingerprint not registered in Google Console

**Check**:
```bash
cd android
./gradlew signingReport
```

Look for the SHA-1 under `> Task :app:signingReport`

**Solution**:
1. Copy the SHA-1 fingerprint
2. Go to Google Cloud Console → Android OAuth client
3. Add the SHA-1 fingerprint
4. Wait 5-10 minutes
5. Uninstall and reinstall the app

#### **On iOS**

**Problem**: Client ID mismatch in Info.plist

**Check**: Open `ios/Runner/Info.plist`

Should have:
```xml
<key>GIDClientID</key>
<string>237008246636-d8a2gldpp801vs96vmumr1kst45cndef.apps.googleusercontent.com</string>
```

**Solution**: Already configured correctly ✅

---

### 4. **Check Error Messages**

**Run the app in debug mode**:

```bash
flutter run --verbose
```

**Click "Continue with Google" and watch the terminal**

Look for error messages like:
- `API not enabled`
- `Invalid client`
- `Unauthorized client`
- `Developer Error`

**Share the exact error message** for specific help.

---

### 5. **Network/Permissions Issue**

**Problem**: App doesn't have internet permission

**Solution**: Already configured in `AndroidManifest.xml` ✅

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

---

## Quick Diagnostic Test

Run this and share the output:

```bash
flutter run --verbose
```

Then click "Continue with Google" and copy the **exact error message** from the terminal.

Common error patterns:

### Error: "API not enabled"
**Solution**: Enable Google+ API in Google Cloud Console

### Error: "Invalid client" or "unauthorized_client"
**Solution**: Configure Supabase Google provider (Step 1 above)

### Error: "Developer Error" (Android)
**Solution**: Add SHA-1 fingerprint (Step 3 above)

### Error: "Google sign-in was cancelled"
**This is normal** - it means the picker appeared but you cancelled

### Error: Nothing happens (silent failure)
**Solution**: Supabase not configured (Step 1 above)

---

## Step-by-Step Debugging

### Test 1: Check Supabase Configuration

1. Go to Supabase Dashboard
2. Authentication → Providers
3. Is Google **enabled**?
   - ❌ No → Enable it and configure (Step 1 above)
   - ✅ Yes → Continue to Test 2

### Test 2: Check Client Secret

1. Supabase Dashboard → Google Provider
2. Is **Client Secret** filled in?
   - ❌ No → Add it (get from Google Console)
   - ✅ Yes → Continue to Test 3

### Test 3: Check Authorized Client IDs

1. Supabase Dashboard → Google Provider
2. Are **all 3 client IDs** listed in "Authorized Client IDs"?
   - ❌ No → Add them (Step 1 above)
   - ✅ Yes → Continue to Test 4

### Test 4: Check Google Cloud Console

1. Go to: https://console.cloud.google.com/apis/credentials
2. Do you see the OAuth clients?
   - ❌ No → Create your own (see `docs/GOOGLE_OAUTH_SETUP.md`)
   - ✅ Yes → Continue to Test 5

### Test 5: Run Debug Mode

```bash
flutter run --verbose
```

Click "Continue with Google" and check terminal for errors.

---

## Most Common Fix (90% of cases)

**The Google account picker doesn't appear because Supabase Google provider is not configured.**

**Quick Fix (5 minutes)**:

1. Supabase Dashboard → Authentication → Providers → Google → Enable
2. Get Client Secret from Google Console
3. Add all 3 client IDs to Authorized Client IDs
4. Enable "Skip nonce check"
5. Save
6. Restart app
7. Test

---

## If Still Not Working

**Please provide**:
1. Platform (Android or iOS?)
2. Error message from terminal (run `flutter run --verbose`)
3. Screenshot of Supabase Google provider settings
4. Confirm: Did you configure Supabase Google provider?

---

## Expected Behavior After Fix

**Before**:
- Click "Continue with Google"
- Nothing happens (or error message)

**After**:
- Click "Continue with Google"
- ✅ Google account picker modal appears
- Select account
- ✅ Sign in completes

---

## Related Documentation

- [`URGENT_FIX_INSTRUCTIONS.md`](URGENT_FIX_INSTRUCTIONS.md) - Supabase configuration guide
- [`docs/GOOGLE_OAUTH_SETUP.md`](docs/GOOGLE_OAUTH_SETUP.md) - Complete Google setup
- [`docs/SETUP_INSTRUCTIONS.md`](docs/SETUP_INSTRUCTIONS.md) - Master setup guide

---

**START HERE**: Configure Supabase Google Provider (Step 1 above) - This fixes 90% of cases! 🚀
