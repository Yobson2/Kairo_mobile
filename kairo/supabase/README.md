# Kairo Supabase Database Setup

This directory contains all database migrations and setup scripts for the Kairo application.

## Quick Start

### 1. Install Supabase CLI

```bash
# macOS
brew install supabase/tap/supabase

# Windows (with Scoop)
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase

# Or download from: https://github.com/supabase/cli/releases
```

### 2. Link to Your Supabase Project

```bash
# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref YOUR_PROJECT_REF
```

You can find your project ref in your Supabase dashboard URL:
`https://app.supabase.com/project/YOUR_PROJECT_REF`

### 3. Run Migrations

```bash
# Apply all pending migrations to your Supabase project
supabase db push
```

## Migration Files

### 20260111000001_initial_schema.sql
Creates the core database schema:
- `profiles` - User profile data extending auth.users
- `allocation_categories` - User-defined categories (Family Support, Savings, etc.)
- `allocation_strategies` - Saved allocation strategies
- `strategy_allocations` - Junction table for strategy-category percentages
- `income_entries` - User income records
- `allocations` - Actual money allocations
- `insights` - Learning insights for positive psychology

**Key Features:**
- Proper foreign key constraints
- Indexes for performance
- Auto-updating `updated_at` triggers
- Validation constraints (percentages, amounts, etc.)

### 20260111000002_rls_policies.sql
Implements Row Level Security (RLS) policies:
- User data isolation (users can only access their own data)
- Helper functions:
  - Auto-create profile on user signup
  - Ensure only one active strategy per user
  - Auto-expire temporary allocations

### 20260111000003_default_categories_function.sql
Creates default categories and strategy for new users:
- 5 default cultural categories:
  1. Family Support (20%)
  2. Emergencies (15%)
  3. Savings (15%)
  4. Daily Needs (40%)
  5. Community Contributions (10%)
- Default "Balanced Allocation" strategy
- Auto-initialization trigger on user signup

## Database Schema Overview

```
auth.users (Supabase managed)
    ↓
profiles (1:1)
    ↓
├── allocation_categories (1:many)
│       ↓
│   allocations (many:1)
│
├── allocation_strategies (1:many)
│       ↓
│   strategy_allocations (many:many with categories)
│
├── income_entries (1:many)
│       ↓
│   allocations (many:1)
│
└── insights (1:many)
```

## Environment Variables

Make sure your `.env` file contains:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

## Manual Migration (Alternative)

If you prefer to run migrations manually:

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Copy and paste each migration file in order:
   - `20260111000001_initial_schema.sql`
   - `20260111000002_rls_policies.sql`
   - `20260111000003_default_categories_function.sql`
4. Execute each one

## Development vs Production

### Development
```bash
# Use local Supabase instance
supabase start
supabase db reset  # Resets local DB and applies all migrations
```

### Production
```bash
# Link to production project
supabase link --project-ref YOUR_PROD_PROJECT_REF

# Push migrations
supabase db push
```

## Testing the Setup

After running migrations, you can test:

1. **Create a test user** via Supabase Auth
2. **Verify auto-creation** of:
   - Profile in `profiles` table
   - 5 default categories in `allocation_categories`
   - 1 default strategy in `allocation_strategies`
   - 5 strategy allocations in `strategy_allocations`

## Troubleshooting

### Migration fails with "relation already exists"
```bash
# Reset local database (dev only!)
supabase db reset
```

### RLS policies blocking queries
Check that:
- User is authenticated (`auth.uid()` returns valid UUID)
- Queries use authenticated Supabase client
- Service role key is NOT used in client code (only for admin operations)

### Default categories not created
Check trigger execution:
```sql
SELECT * FROM public.profiles WHERE id = 'YOUR_USER_ID';
SELECT * FROM public.allocation_categories WHERE user_id = 'YOUR_USER_ID';
```

## Useful Commands

```bash
# Check migration status
supabase migration list

# Create new migration
supabase migration new migration_name

# Pull remote schema changes
supabase db pull

# Generate TypeScript types from DB
supabase gen types typescript --local > lib/types/database.types.ts
```

## Security Notes

- ✅ RLS enabled on all tables
- ✅ Users can only access their own data
- ✅ Auth required for all operations
- ✅ Validation constraints prevent bad data
- ✅ Soft deletes preserve data integrity
- ✅ Triggers enforce business logic

## Support

For Supabase CLI help:
```bash
supabase help
supabase db --help
```

Documentation:
- [Supabase CLI Docs](https://supabase.com/docs/guides/cli)
- [Supabase Migrations](https://supabase.com/docs/guides/cli/local-development#database-migrations)
