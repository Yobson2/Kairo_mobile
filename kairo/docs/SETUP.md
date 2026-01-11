# Kairo Setup Guide

Welcome to Kairo! This guide will help you set up the development environment and get the app running locally.

## Prerequisites

- **Flutter SDK** 3.24.0 or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart** 3.2.0 or higher (comes with Flutter)
- **Git**
- **IDE**: VS Code or Android Studio recommended
- **Supabase Account** ([Sign up free](https://supabase.com))
- **Sentry Account** (Optional, for error tracking - [Sign up free](https://sentry.io))

### Platform-Specific Requirements

#### Android
- Android Studio
- Android SDK (API level 21 or higher)
- Java JDK 17

#### iOS (macOS only)
- Xcode 14.0 or higher
- CocoaPods
- iOS 12.0 or higher

## Step 1: Clone the Repository

```bash
git clone https://github.com/your-org/kairo.git
cd kairo
```

## Step 2: Install Dependencies

```bash
flutter pub get
```

## Step 3: Set Up Supabase

### 3.1 Create a Supabase Project

1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Click "New Project"
3. Fill in:
   - **Project name**: kairo-dev (or any name)
   - **Database password**: Choose a strong password
   - **Region**: Select closest to you
4. Wait for project to be created (1-2 minutes)

### 3.2 Get Your Supabase Credentials

1. Go to **Settings** → **API**
2. Copy:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key** (long string starting with `eyJ...`)

### 3.3 Run Database Migrations

#### Option A: Using Supabase CLI (Recommended)

```bash
# Install Supabase CLI
# macOS
brew install supabase/tap/supabase

# Windows (with Scoop)
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase

# Login to Supabase
supabase login

# Link to your project (get project ref from dashboard URL)
supabase link --project-ref YOUR_PROJECT_REF

# Run migrations
supabase db push
```

#### Option B: Manual Migration via Dashboard

1. Go to your Supabase project → **SQL Editor**
2. Run each migration file in order:
   - `supabase/migrations/20260111000001_initial_schema.sql`
   - `supabase/migrations/20260111000002_rls_policies.sql`
   - `supabase/migrations/20260111000003_default_categories_function.sql`
3. Click "Run" for each file

### 3.4 Verify Database Setup

In SQL Editor, run:

```sql
-- Should show 7 tables
SELECT tablename FROM pg_tables WHERE schemaname = 'public';

-- Should show 5 default categories (after first user signup)
SELECT * FROM allocation_categories WHERE is_default = true LIMIT 1;
```

## Step 4: Configure Environment Variables

```bash
# Copy the example file
cp .env.example .env

# Edit .env and fill in your values
```

Your `.env` file should look like:

```env
# Environment
ENVIRONMENT=development

# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Sentry (Optional - leave empty for now)
SENTRY_DSN=

# Firebase Cloud Messaging (Optional - leave empty for now)
FCM_SERVER_KEY=
```

**Important:** Never commit `.env` to version control. It's already in `.gitignore`.

## Step 5: Run Code Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- Riverpod providers (`*.g.dart`)
- JSON serialization code
- Other generated files

## Step 6: Run the App

### Android

```bash
# List available devices
flutter devices

# Run on connected device/emulator
flutter run
```

### iOS (macOS only)

```bash
cd ios
pod install
cd ..

flutter run
```

### Web (for testing)

```bash
flutter run -d chrome
```

## Step 7: Create Your First User

1. App should open to the **Login** screen
2. Click "Create New Account"
3. Fill in:
   - Email: `test@example.com`
   - Password: `Test123!@#`
   - Full name: `Test User`
4. Click "Sign Up"
5. You should be redirected to the **Onboarding** screen
6. Complete the onboarding flow

### Verify Auto-Creation

Check Supabase dashboard → **Table Editor**:

- `profiles` table should have 1 row (your user)
- `allocation_categories` should have 5 rows (default categories)
- `allocation_strategies` should have 1 row (default "Balanced Allocation")
- `strategy_allocations` should have 5 rows (percentages for each category)

## Troubleshooting

### "No environment file found"

**Fix:** Make sure `.env` exists in the project root and contains valid values.

```bash
cp .env.example .env
# Then edit .env with your Supabase credentials
```

### "Table 'profiles' does not exist"

**Fix:** Run database migrations (see Step 3.3).

### "Invalid API key"

**Fix:** Double-check your `SUPABASE_ANON_KEY` in `.env`. It should be the **anon public** key, not the service role key.

### Build errors after pulling latest code

**Fix:** Clean and regenerate:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Code generation fails

**Fix:** Check `build.yaml` and ensure drift is disabled for non-drift files.

### iOS build fails with CocoaPods errors

**Fix:**

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

## Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/presentation/screens/login_screen_test.dart
```

## Code Quality

```bash
# Check formatting
dart format --output=none --set-exit-if-changed .

# Fix formatting
dart format .

# Analyze code
flutter analyze

# Run linter
flutter analyze --no-fatal-infos
```

## Next Steps

Now that you're set up:

1. Read [docs/architecture.md](architecture.md) to understand the codebase structure
2. Read [docs/prd.md](prd.md) to understand product requirements
3. Check [docs/gap_analysis.md](gap_analysis.md) to see what needs to be built
4. Start with Phase 2 features from the gap analysis

## Development Workflow

### Creating a New Feature

1. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow clean architecture (domain → data → presentation)
   - Write tests for new code
   - Update documentation if needed

3. **Run code generation** (if you added providers/models)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run tests and analysis**
   ```bash
   flutter test
   flutter analyze
   dart format .
   ```

5. **Commit and push**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   git push origin feature/your-feature-name
   ```

6. **Create Pull Request**
   - CI will run automatically
   - Wait for code review

## CI/CD

GitHub Actions automatically:
- Runs on push to `main` or `develop`
- Runs on pull requests
- Checks:
  - Code formatting
  - Static analysis
  - Tests
  - Android APK build
  - iOS build (if on PR to main)
- Uploads build artifacts

## Production Deployment

### Android

1. **Create release keystore** (first time only)
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Configure signing** in `android/key.properties`

3. **Build release APK**
   ```bash
   flutter build apk --release
   ```

4. **Upload to Google Play Console**

### iOS

1. **Configure code signing** in Xcode
2. **Build release**
   ```bash
   flutter build ios --release
   ```
3. **Archive and upload** via Xcode

## Getting Help

- **Documentation**: Check `docs/` folder
- **Issues**: [GitHub Issues](https://github.com/your-org/kairo/issues)
- **Architecture questions**: See `docs/architecture.md`
- **PRD questions**: See `docs/prd.md`

## Useful Commands

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file changes)
flutter pub run build_runner watch

# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
dart format .

# Check outdated packages
flutter pub outdated
```

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [Supabase Documentation](https://supabase.com/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

---

**Happy coding! 🚀**

If you encounter issues not covered here, please create a GitHub issue or ask in the team chat.
