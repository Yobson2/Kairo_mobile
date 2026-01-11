# Kairo Database Setup Guide

## Quick Start: Apply Migrations to Supabase

Since you're using Supabase Cloud, you can apply migrations directly through the dashboard. Follow these steps:

---

## Option 1: Supabase Dashboard (Recommended - No CLI Needed)

### Step 1: Access SQL Editor

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your Kairo project
3. Click **SQL Editor** in the left sidebar
4. Click **New Query**

### Step 2: Apply Migration 1 - Initial Schema

Copy the entire contents of `supabase/migrations/20260111000001_initial_schema.sql` and paste into the SQL Editor.

**What this creates:**
- 7 tables: `profiles`, `allocation_categories`, `allocation_strategies`, `strategy_allocations`, `income_entries`, `allocations`, `insights`
- All necessary indexes
- Foreign key constraints
- Check constraints
- Default values

Click **Run** to execute.

**Expected Result:**
```
Success. No rows returned
```

### Step 3: Apply Migration 2 - RLS Policies

Copy the entire contents of `supabase/migrations/20260111000002_rls_policies.sql` and paste into a new query.

**What this creates:**
- Row Level Security (RLS) policies for all 7 tables
- User isolation (users can only access their own data)
- Admin read-only access

Click **Run** to execute.

**Expected Result:**
```
Success. No rows returned
```

### Step 4: Apply Migration 3 - Default Categories Function

Copy the entire contents of `supabase/migrations/20260111000003_default_categories_function.sql` and paste into a new query.

**What this creates:**
- Trigger function to auto-create default categories
- Trigger on user signup
- 5 default categories: Family Support, Emergencies, Savings, Daily Needs, Community Contributions

Click **Run** to execute.

**Expected Result:**
```
Success. No rows returned
```

### Step 5: Verify Setup

Run this verification query:

```sql
-- Check if all tables exist
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Expected result: 7 tables
-- allocations
-- allocation_categories
-- allocation_strategies
-- income_entries
-- insights
-- profiles
-- strategy_allocations
```

**Next, verify RLS is enabled:**

```sql
-- Check RLS status
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';

-- Expected: All tables should have rowsecurity = true
```

**Finally, verify the trigger exists:**

```sql
-- Check trigger function
SELECT trigger_name, event_object_table, action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public';

-- Expected: create_default_categories_trigger on profiles table
```

---

## Option 2: Install Supabase CLI (Optional)

If you want to use the CLI for future migrations:

### For Windows (using Scoop):

```powershell
# Install Scoop (if not already installed)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

# Install Supabase CLI
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

### For Windows (using Chocolatey):

```powershell
# Install Chocolatey (if not already installed)
# Run as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Supabase CLI
choco install supabase
```

### For Windows (Manual Download):

1. Download from [Supabase CLI Releases](https://github.com/supabase/cli/releases)
2. Extract to `C:\Program Files\Supabase\`
3. Add to PATH environment variable

### Using CLI to Apply Migrations:

```bash
# Link to your cloud project
supabase link --project-ref YOUR_PROJECT_REF

# Apply all pending migrations
supabase db push

# Or apply migrations one by one
supabase migration up
```

---

## Verification Checklist

After applying all migrations, verify the setup:

### ✅ Tables Created

Run in SQL Editor:
```sql
SELECT
    t.table_name,
    COUNT(c.column_name) as column_count
FROM information_schema.tables t
LEFT JOIN information_schema.columns c ON c.table_name = t.table_name
WHERE t.table_schema = 'public'
AND t.table_type = 'BASE TABLE'
GROUP BY t.table_name
ORDER BY t.table_name;
```

**Expected Output:**
| table_name | column_count |
|------------|--------------|
| allocation_categories | 8 |
| allocation_strategies | 7 |
| allocations | 6 |
| income_entries | 9 |
| insights | 7 |
| profiles | 7 |
| strategy_allocations | 5 |

### ✅ RLS Policies Active

Run in SQL Editor:
```sql
SELECT
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

**Expected:** ~20 policies across all tables

### ✅ Indexes Created

Run in SQL Editor:
```sql
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
```

**Expected:** Indexes on:
- `user_id` columns (all tables)
- `is_active` (strategies)
- `income_date` (income_entries)
- `created_at` (all tables)

### ✅ Trigger Function Working

Test by creating a test user:

```sql
-- This should automatically create default categories
INSERT INTO auth.users (id, email)
VALUES (gen_random_uuid(), 'test@example.com');

-- Check if categories were created
SELECT * FROM allocation_categories
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'test@example.com');

-- Expected: 5 default categories
-- Clean up test user after verification
```

---

## Troubleshooting

### Error: "permission denied for schema public"

**Solution:** Enable RLS and apply policies first:
```sql
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;
```

### Error: "relation already exists"

**Solution:** Table already created. Either:
- Drop existing tables: `DROP TABLE table_name CASCADE;`
- Or skip to next migration

### Error: "function already exists"

**Solution:** Function already created. Either:
- Drop function: `DROP FUNCTION function_name CASCADE;`
- Or skip to next migration

### Error: "trigger already exists"

**Solution:** Trigger already created. Safe to ignore.

---

## Post-Setup: Configure App

After database is set up, ensure your app is configured:

### 1. Check Environment Variables

Verify `.env` file has correct values:

```env
SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
SENTRY_DSN=your_sentry_dsn_here
```

### 2. Update Supabase Client

The app should already be configured via:
`lib/core/providers/supabase_provider.dart`

### 3. Test Connection

Run the app and check console for:
```
supabase.supabase_flutter: INFO: ***** Supabase init completed *****
```

---

## Database Diagram

```
┌─────────────┐
│   profiles  │
└──────┬──────┘
       │
       ├───────┬───────────────┬──────────────┬─────────────┐
       │       │               │              │             │
       ▼       ▼               ▼              ▼             ▼
┌──────────┐ ┌───────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│allocation│ │allocation_│ │  income_ │ │allocations│ │ insights │
│categories│ │strategies │ │  entries │ │           │ │          │
└────┬─────┘ └─────┬─────┘ └──────────┘ └──────────┘ └──────────┘
     │             │
     │             ▼
     │      ┌──────────────┐
     └─────▶│  strategy_   │
            │ allocations  │
            └──────────────┘
```

### Table Relationships

1. **profiles** (1) → (many) **allocation_categories**
2. **profiles** (1) → (many) **allocation_strategies**
3. **profiles** (1) → (many) **income_entries**
4. **profiles** (1) → (many) **allocations**
5. **profiles** (1) → (many) **insights**
6. **allocation_strategies** (1) → (many) **strategy_allocations**
7. **allocation_categories** (1) → (many) **strategy_allocations**

---

## Migration Files Reference

### Migration 1: Initial Schema
**File:** `supabase/migrations/20260111000001_initial_schema.sql`
**Lines:** 247
**Purpose:** Create all database tables with constraints

### Migration 2: RLS Policies
**File:** `supabase/migrations/20260111000002_rls_policies.sql`
**Lines:** 326
**Purpose:** Implement Row Level Security for data isolation

### Migration 3: Default Categories
**File:** `supabase/migrations/20260111000003_default_categories_function.sql`
**Lines:** 229
**Purpose:** Auto-create default categories on user signup

**Total:** 802 lines of SQL

---

## Next Steps After Setup

1. ✅ **Test User Registration**
   - Sign up through the app
   - Verify profile created in `profiles` table
   - Verify 5 default categories created

2. ✅ **Test Onboarding**
   - Complete 4-step onboarding
   - Verify strategy created in `allocation_strategies`
   - Verify allocations created in `strategy_allocations`

3. ✅ **Test Income Entry**
   - Add income entry
   - Verify saved in `income_entries` table

4. ✅ **Test Data Isolation (RLS)**
   - Create two test users
   - Verify each user only sees their own data

5. ✅ **Performance Test**
   - Create 100+ income entries
   - Verify query performance < 100ms

---

## Backup and Restore

### Create Backup (via Dashboard)

1. Go to **Settings** → **Database**
2. Click **Backup now**
3. Download backup file

### Restore from Backup

1. Go to **Settings** → **Database**
2. Click **Restore**
3. Select backup file

### Automated Backups

Supabase automatically backs up daily. Configure retention:
1. Go to **Settings** → **Database**
2. Configure **Backup retention** (7 days default)

---

## Security Best Practices

### ✅ Already Implemented

- ✅ Row Level Security enabled on all tables
- ✅ User data isolation via RLS policies
- ✅ Foreign key constraints for referential integrity
- ✅ Check constraints for data validation
- ✅ Indexed columns for query performance

### 🔒 Additional Recommendations

1. **Rotate API Keys Regularly**
   - Go to **Settings** → **API**
   - Generate new anon key every 90 days
   - Update app configuration

2. **Monitor Database Activity**
   - Go to **Database** → **Query Performance**
   - Review slow queries
   - Optimize as needed

3. **Set Up Alerts**
   - Go to **Settings** → **Alerts**
   - Configure CPU/Memory alerts
   - Configure connection pool alerts

4. **Enable Audit Logs** (Paid Plan)
   - Go to **Settings** → **Audit Logs**
   - Review security events

---

## Database Maintenance

### Weekly Tasks
- [ ] Review slow queries in Query Performance
- [ ] Check database size and usage
- [ ] Verify backups are running

### Monthly Tasks
- [ ] Analyze table statistics: `ANALYZE;`
- [ ] Vacuum tables: `VACUUM ANALYZE;`
- [ ] Review and archive old data

### Quarterly Tasks
- [ ] Review and update RLS policies
- [ ] Optimize indexes based on usage
- [ ] Update database statistics

---

## Support Resources

- **Supabase Docs:** https://supabase.com/docs
- **SQL Editor:** https://supabase.com/docs/guides/database/sql-editor
- **RLS Guide:** https://supabase.com/docs/guides/auth/row-level-security
- **Community:** https://github.com/supabase/supabase/discussions

---

## Summary

✅ **Database Setup Complete When:**
- All 7 tables created
- All 20+ RLS policies active
- Default categories trigger working
- App connects successfully
- User signup creates profile + categories

🚀 **You're Ready for:** Beta testing and user onboarding!

---

*Last Updated: January 11, 2026*
*Version: 1.0*
