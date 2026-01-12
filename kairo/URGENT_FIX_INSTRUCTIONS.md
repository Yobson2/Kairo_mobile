# 🚨 URGENT: Fix Google & Apple Sign-In Errors

## What I Just Fixed

✅ **Fixed .env file** - Removed typo (double dots in GOOGLE_WEB_CLIENT_ID)
✅ **iOS credentials** - Already properly configured

## ⚠️ Critical Issue: Supabase Configuration Required

Your error messages are appearing because **Supabase doesn't recognize these OAuth credentials yet**. You must configure your Supabase dashboard NOW.

---

## 🔥 IMMEDIATE ACTIONS (15 minutes)

### Step 1: Configure Google in Supabase (5 minutes)

1. **Open Supabase Dashboard**:
   - Go to: https://supabase.com/dashboard
   - Select your project: `zychbbvdrulanzlfoumz`

2. **Navigate to Authentication**:
   - Left sidebar → **Authentication**
   - Click **Providers**

3. **Enable Google**:
   - Find **Google** in the list
   - Toggle it **ON** (enabled)

4. **Configure Google Provider**:

   **Client ID (for OAuth)**:
   ```
   237008246636-qb8p64la7emfdqgn9if648jq6n5nf9p6.apps.googleusercontent.com
   ```

   **Client Secret (for OAuth)**:
   - You need to get this from Google Cloud Console
   - Go to: https://console.cloud.google.com/apis/credentials
   - Find the OAuth 2.0 Client ID: `237008246636-qb8p64la7emfdqgn9if648jq6n5nf9p6`
   - Click on it → You'll see **Client Secret**
   - Copy and paste it here

   **Authorized Client IDs** (Add all 3, one per line):
   ```
   237008246636-qb8p64la7emfdqgn9if648jq6n5nf9p6.apps.googleusercontent.com
   237008246636-128batf01lt9u1rvn6f76vtqq4cbu94f.apps.googleusercontent.com
   237008246636-d8a2gldpp801vs96vmumr1kst45cndef.apps.googleusercontent.com
   ```

   **Skip nonce check**: ✅ **Enable this** (check the box)

5. **Click Save**

---

### Step 2: Verify Google Cloud Console (5 minutes)

These credentials appear to be example/demo credentials. You may need to create your own:

1. **Go to Google Cloud Console**: https://console.cloud.google.com/apis/credentials

2. **Check if project exists**:
   - Look for project with ID starting with `237008246636`
   - If it doesn't exist, you need to create your own (see docs/GOOGLE_OAUTH_SETUP.md)

3. **If project exists, verify OAuth clients**:
   - You should see 3 OAuth 2.0 Client IDs:
     - Web client
     - Android client
     - iOS client

4. **Get the Client Secret**:
   - Click on the Web client
   - Copy the **Client Secret**
   - You'll need this for Step 1 above

---

### Step 3: Test the Fix (5 minutes)

After configuring Supabase:

```bash
# Restart your app
flutter run --hot-restart
```

**Test Google Sign-In**:
1. Click "Continue with Google"
2. ✅ Should open Google account picker
3. Select account
4. ✅ Should sign in successfully

---

## 🎯 Expected Behavior After Fix

### Before (Current - Error):
```
Click "Continue with Google"
  ↓
Error: "Google sign-in failed: [error message]"
  ↓
Red error snackbar appears
```

### After (Fixed):
```
Click "Continue with Google"
  ↓
Google account picker appears
  ↓
Select account
  ↓
✅ Success! "Welcome back!" or "Complete registration"
```

---

## 🐛 If Still Getting Errors

### Error: "Invalid OAuth credentials"

**Cause**: Client Secret not configured in Supabase

**Solution**:
1. Get Client Secret from Google Cloud Console
2. Add it to Supabase → Authentication → Providers → Google
3. Save

### Error: "Unauthorized client"

**Cause**: Client IDs not in "Authorized Client IDs" list

**Solution**:
1. Supabase → Authentication → Providers → Google
2. Scroll to **Authorized Client IDs**
3. Add all 3 client IDs (one per line)
4. Save

### Error: "Developer Error" (Android)

**Cause**: SHA-1 fingerprint not registered

**Solution**:
```bash
cd android
./gradlew signingReport
```
Copy the SHA-1 and add it to Google Cloud Console → Android OAuth client

### Error: "These credentials are not yours"

**Cause**: Using example credentials that belong to someone else

**Solution**: Create your own OAuth credentials:
1. Follow: `docs/GOOGLE_OAUTH_SETUP.md`
2. Create your own Google Cloud project
3. Generate your own client IDs
4. Update `.env` and `ios/Runner/Info.plist`

---

## 📱 Platform-Specific Notes

### Android
- Works with the current `.env` configuration
- Requires Supabase to be configured
- May need SHA-1 fingerprint in Google Console

### iOS
- Already configured in `Info.plist`
- Requires Supabase to be configured
- Test on **physical device** only

---

## ⚡ Quick Checklist

Before testing, ensure:

- [ ] `.env` file has no typos (fixed ✅)
- [ ] iOS `Info.plist` has correct client ID (fixed ✅)
- [ ] Supabase Google provider is **enabled**
- [ ] Supabase has **Client Secret** configured
- [ ] Supabase has **all 3 client IDs** in Authorized Client IDs
- [ ] **Skip nonce check** is enabled in Supabase
- [ ] App is restarted after changes

---

## 🆘 Still Not Working?

### Check Supabase Logs

1. Supabase Dashboard → **Logs** → **Auth**
2. Look for error messages when you try to sign in
3. Common errors:
   - "Invalid client secret" → Add Client Secret
   - "Unauthorized client" → Add client IDs to Authorized list
   - "Invalid redirect URI" → Contact me with the exact error

### Get the Exact Error

If you're still seeing errors, I need to know the **exact error message**.

Run the app in debug mode:
```bash
flutter run --verbose
```

Then click "Continue with Google" and copy the **entire error message** from the terminal.

---

## 🎯 Most Likely Issue

**90% chance**: Supabase Google provider is either:
1. Not enabled
2. Missing Client Secret
3. Missing Authorized Client IDs

**Fix**: Follow Step 1 above carefully. This should resolve the error.

---

## 📞 Need More Help?

If you're still stuck after following Step 1:

1. **Share the exact error message** you see on screen
2. **Share any console logs** from `flutter run`
3. **Screenshot of Supabase Google provider settings**

This will help me pinpoint the exact issue.

---

**START HERE**: Step 1 - Configure Google in Supabase Dashboard (5 minutes)

Once Step 1 is complete, test again. The errors should disappear! 🎉
