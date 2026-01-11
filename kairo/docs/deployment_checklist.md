# Kairo Deployment Checklist

**Date Created:** 2026-01-11
**Phase:** Phase 2 - Database Setup & Testing
**Status:** Ready for Deployment

---

## Prerequisites

- [ ] Supabase account created
- [ ] Supabase project created
- [ ] `.env` file configured with Supabase credentials
- [ ] Flutter environment working (verified with `flutter doctor`)

---

## Step 1: Supabase Project Setup

### 1.1 Create Supabase Project

1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Click "New Project"
3. Fill in:
   - **Project Name:** Kairo (or kairo-dev/kairo-staging/kairo-prod)
   - **Database Password:** (save this securely!)
   - **Region:** Choose closest to your users (e.g., eu-central-1 for Europe, us-east-1 for US)
4. Wait for project to provision (~2 minutes)

### 1.2 Get Project Credentials

1. Go to **Settings** → **API**
2. Copy:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key** (starts with `eyJhbGci...`)
3. Update `.env` file:

```env
ENVIRONMENT=development
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
SENTRY_DSN=  # Leave empty for now
```

---

## Step 2: Apply Database Migrations

### Option A: Using Supabase CLI (Recommended)

**Install CLI:**
```bash
# Windows (with Scoop)
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase

# macOS
brew install supabase/tap/supabase

# Or download from: https://github.com/supabase/cli/releases
```

**Apply Migrations:**
```bash
# 1. Login to Supabase
supabase login

# 2. Link to your project
cd c:\Users\yobou\Desktop\Kairo_mobile\kairo
supabase link --project-ref YOUR_PROJECT_REF

# 3. Push migrations
supabase db push
```

**Verify:**
```bash
supabase migration list
```

### Option B: Manual Migration (Via Dashboard)

If you don't have CLI access:

1. Go to Supabase Dashboard → **SQL Editor**
2. Create a new query
3. Copy contents of `supabase/migrations/20260111000001_initial_schema.sql`
4. Paste and click **Run**
5. Repeat for:
   - `20260111000002_rls_policies.sql`
   - `20260111000003_default_categories_function.sql`
6. Verify no errors in execution

**Expected Output:**
- ✅ 7 tables created
- ✅ RLS enabled on all tables
- ✅ Policies created
- ✅ Triggers created
- ✅ Functions created

---

## Step 3: Verify Database Setup

### 3.1 Check Tables

Go to **Table Editor** and verify these tables exist:

- [ ] `profiles`
- [ ] `allocation_categories`
- [ ] `allocation_strategies`
- [ ] `strategy_allocations`
- [ ] `income_entries`
- [ ] `allocations`
- [ ] `insights`

### 3.2 Check RLS Policies

Go to **Authentication** → **Policies**

Verify each table has RLS **enabled** with policies:
- [ ] `profiles` - 3 policies (view, insert, update)
- [ ] `allocation_categories` - 4 policies (CRUD)
- [ ] `allocation_strategies` - 4 policies (CRUD)
- [ ] `strategy_allocations` - 4 policies (CRUD)
- [ ] `income_entries` - 4 policies (CRUD)
- [ ] `allocations` - 4 policies (CRUD)
- [ ] `insights` - 4 policies (view, insert, update, delete)

### 3.3 Test Functions

Go to **SQL Editor** and run:

```sql
-- Check that functions exist
SELECT proname FROM pg_proc WHERE proname LIKE '%kairo%' OR proname LIKE '%category%';

-- Expected to see:
-- - handle_new_user
-- - ensure_single_active_strategy
-- - create_default_categories
-- - create_default_balanced_strategy
-- - initialize_new_user
-- - auto_initialize_user
```

---

## Step 4: Test User Signup Flow

### 4.1 Create Test User

Go to **Authentication** → **Users** → **Add User**

Create test user:
- Email: `test@kairo.app`
- Password: `Test123!@#`
- Auto Confirm User: ✅ Checked

### 4.2 Verify Auto-Initialization

Go to **Table Editor** and check:

**1. Profile Created:**
```sql
SELECT * FROM profiles WHERE email = 'test@kairo.app';
```
Expected: 1 row with user data

**2. Default Categories Created:**
```sql
SELECT id, name, color, is_default, sort_order
FROM allocation_categories
WHERE user_id = (SELECT id FROM profiles WHERE email = 'test@kairo.app')
ORDER BY sort_order;
```
Expected: 5 rows
1. Family Support (#EF4444)
2. Emergencies (#F59E0B)
3. Savings (#10B981)
4. Daily Needs (#3B82F6)
5. Community Contributions (#8B5CF6)

**3. Default Strategy Created:**
```sql
SELECT * FROM allocation_strategies
WHERE user_id = (SELECT id FROM profiles WHERE email = 'test@kairo.app');
```
Expected: 1 row ("Balanced Allocation", is_active = true)

**4. Strategy Allocations Created:**
```sql
SELECT sa.percentage, ac.name
FROM strategy_allocations sa
JOIN allocation_categories ac ON sa.category_id = ac.id
WHERE sa.strategy_id = (
  SELECT id FROM allocation_strategies
  WHERE user_id = (SELECT id FROM profiles WHERE email = 'test@kairo.app')
)
ORDER BY sa.percentage DESC;
```
Expected: 5 rows (totaling 100%)
- Daily Needs: 40%
- Family Support: 20%
- Emergencies: 15%
- Savings: 15%
- Community Contributions: 10%

✅ **If all checks pass, database is working correctly!**

---

## Step 5: Test Flutter App Connection

### 5.1 Verify .env File

```bash
cat .env
# Should show your Supabase credentials
```

### 5.2 Run Flutter App

```bash
flutter pub get
flutter run -d chrome  # Or your device
```

### 5.3 Test Registration

1. Click "Register"
2. Fill in:
   - Email: `newuser@test.com`
   - Password: `Test123!@#`
   - Confirm Password: `Test123!@#`
3. Click "Sign Up"

**Expected:**
- ✅ User created in Supabase
- ✅ Redirected to onboarding screen
- ✅ Profile auto-created
- ✅ Default categories visible

### 5.4 Test Login

1. Sign out
2. Click "Login"
3. Enter test credentials
4. Click "Sign In"

**Expected:**
- ✅ Login successful
- ✅ Redirected to dashboard
- ✅ User session persists

---

## Step 6: Test Income Management Features

### 6.1 Test Income Entry

1. Navigate to `/dashboard/income/new`
2. Fill in:
   - Amount: 50000
   - Currency: KES
   - Date: Today
   - Type: Variable
   - Source: Gig Income
   - Description: "Freelance project"
3. Click "Add Income"

**Expected:**
- ✅ "Income added successfully" message
- ✅ Entry saved to database
- ✅ Redirected back

**Verify in Database:**
```sql
SELECT * FROM income_entries
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'newuser@test.com')
ORDER BY created_at DESC
LIMIT 1;
```

### 6.2 Test Income History

1. Navigate to `/dashboard/income/history`

**Expected:**
- ✅ Income entry displayed
- ✅ Summary shows: 1 Entry, KSh 50,000.00
- ✅ Entry shows all details (amount, date, type, source, description)

### 6.3 Test Income Edit

1. Click three-dot menu on income entry
2. Click "Edit"
3. Change amount to 60000
4. Click "Update Income"

**Expected:**
- ✅ "Income updated successfully" message
- ✅ History shows updated amount
- ✅ Summary shows KSh 60,000.00

### 6.4 Test Income Delete

1. Click three-dot menu on income entry
2. Click "Delete"
3. Confirm deletion

**Expected:**
- ✅ Confirmation dialog appears
- ✅ "Income entry deleted" message
- ✅ Entry removed from list
- ✅ Empty state shown

---

## Step 7: Test Category Management

### 7.1 View Categories

1. Navigate to `/categories`

**Expected:**
- ✅ 5 default categories displayed
- ✅ Each has correct color and icon
- ✅ Sorted by sort_order

### 7.2 Create Custom Category

1. Click "Add Category" (if available)
2. Fill in:
   - Name: "Education"
   - Color: Blue
   - Icon: book
3. Save

**Expected:**
- ✅ Category created
- ✅ Appears in list
- ✅ Can be used in allocations

---

## Troubleshooting

### Issue: "Failed to connect to Supabase"

**Check:**
- [ ] `.env` file has correct `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- [ ] No spaces or quotes around values in `.env`
- [ ] Internet connection active
- [ ] Supabase project is running (check dashboard)

**Solution:**
```bash
# Restart app after fixing .env
flutter pub get
flutter run
```

### Issue: "RLS policy violation"

**Check:**
- [ ] User is authenticated
- [ ] RLS policies applied correctly
- [ ] Using correct Supabase client (not service role)

**Solution:**
Run in SQL Editor:
```sql
-- Check RLS status
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';

-- Should show rowsecurity = true for all tables
```

### Issue: "Default categories not created"

**Check:**
```sql
-- Check trigger exists
SELECT tgname FROM pg_trigger WHERE tgname LIKE '%user%';

-- Manually trigger initialization
SELECT public.initialize_new_user('YOUR_USER_ID');
```

### Issue: "Cannot read property of undefined"

**Check:**
- [ ] Build runner executed: `flutter pub run build_runner build`
- [ ] All providers generated (check for `.g.dart` files)
- [ ] No TypeScript errors in console

---

## Rollback Plan

If something goes wrong:

### Reset Database (Development Only!)

```bash
# Via CLI
supabase db reset

# Or via Dashboard
# Go to Settings → Database → Reset Database
```

### Restore from Backup (Production)

```bash
# Create backup before changes
supabase db dump -f backup.sql

# Restore if needed
supabase db execute -f backup.sql
```

---

## Success Criteria

✅ **Database Setup:**
- All migrations applied successfully
- All tables created
- RLS policies active
- Triggers and functions working

✅ **App Functionality:**
- User can register
- User can login
- Session persists
- Default categories created automatically

✅ **Income Features:**
- Can add income entries
- Can view income history
- Can edit income entries
- Can delete income entries
- Filters work correctly

✅ **Performance:**
- App launches in <5 seconds
- Database queries return in <500ms
- No console errors

---

## Next Steps After Successful Deployment

1. **Create production Supabase project** (separate from dev)
2. **Set up staging environment**
3. **Configure Sentry** for error tracking
4. **Set up CI/CD** to auto-deploy on PR merge
5. **Enable email confirmations** in Supabase Auth settings
6. **Configure custom email templates**
7. **Set up database backups** (daily)
8. **Monitor RLS performance**

---

## Support Resources

- **Supabase Docs:** https://supabase.com/docs
- **Supabase Discord:** https://discord.supabase.com
- **Flutter Docs:** https://docs.flutter.dev
- **Kairo Docs:** See `docs/` directory

---

*Deployment Checklist v1.0 - Generated 2026-01-11*
