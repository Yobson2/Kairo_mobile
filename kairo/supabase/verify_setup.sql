-- ============================================================================
-- Kairo Database Setup Verification Script
-- Run this in Supabase SQL Editor after applying migrations
-- ============================================================================

-- ============================================================================
-- 1. CHECK TABLES EXIST
-- ============================================================================
SELECT
    'Table Check' as test_category,
    COUNT(*) as tables_created,
    CASE
        WHEN COUNT(*) = 7 THEN '✅ PASS - All 7 tables exist'
        ELSE '❌ FAIL - Missing tables'
    END as status
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN (
    'profiles',
    'allocation_categories',
    'allocation_strategies',
    'strategy_allocations',
    'income_entries',
    'allocations',
    'insights'
);

-- ============================================================================
-- 2. CHECK RLS ENABLED
-- ============================================================================
SELECT
    'RLS Check' as test_category,
    COUNT(*) as tables_with_rls,
    CASE
        WHEN COUNT(*) = 7 THEN '✅ PASS - RLS enabled on all tables'
        ELSE '❌ FAIL - Some tables missing RLS'
    END as status
FROM pg_tables
WHERE schemaname = 'public'
AND rowsecurity = true
AND tablename IN (
    'profiles',
    'allocation_categories',
    'allocation_strategies',
    'strategy_allocations',
    'income_entries',
    'allocations',
    'insights'
);

-- ============================================================================
-- 3. CHECK POLICIES EXIST
-- ============================================================================
SELECT
    'Policies Check' as test_category,
    COUNT(*) as total_policies,
    CASE
        WHEN COUNT(*) >= 20 THEN '✅ PASS - Policies created'
        ELSE '❌ FAIL - Missing policies'
    END as status
FROM pg_policies
WHERE schemaname = 'public';

-- ============================================================================
-- 4. CHECK FUNCTIONS EXIST
-- ============================================================================
SELECT
    'Functions Check' as test_category,
    COUNT(*) as functions_created,
    CASE
        WHEN COUNT(*) >= 6 THEN '✅ PASS - All helper functions exist'
        ELSE '❌ FAIL - Missing functions'
    END as status
FROM pg_proc
WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
AND proname IN (
    'handle_new_user',
    'ensure_single_active_strategy',
    'create_default_categories',
    'create_default_balanced_strategy',
    'initialize_new_user',
    'auto_initialize_user',
    'expire_temporary_allocations',
    'update_updated_at_column'
);

-- ============================================================================
-- 5. CHECK TRIGGERS EXIST
-- ============================================================================
SELECT
    'Triggers Check' as test_category,
    COUNT(DISTINCT tgname) as triggers_created,
    CASE
        WHEN COUNT(DISTINCT tgname) >= 8 THEN '✅ PASS - Triggers created'
        ELSE '❌ FAIL - Missing triggers'
    END as status
FROM pg_trigger
WHERE tgname LIKE '%user%' OR tgname LIKE '%updated%';

-- ============================================================================
-- 6. DETAILED TABLE LIST
-- ============================================================================
SELECT
    '=== TABLES DETAIL ===' as section,
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns
     WHERE table_schema = 'public' AND table_name = t.table_name) as column_count,
    pg_size_pretty(pg_total_relation_size(quote_ident(table_name)::regclass)) as size
FROM information_schema.tables t
WHERE table_schema = 'public'
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- ============================================================================
-- 7. DETAILED POLICIES LIST
-- ============================================================================
SELECT
    '=== POLICIES DETAIL ===' as section,
    schemaname,
    tablename,
    policyname,
    cmd as operation
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- ============================================================================
-- 8. DETAILED FUNCTIONS LIST
-- ============================================================================
SELECT
    '=== FUNCTIONS DETAIL ===' as section,
    proname as function_name,
    pronargs as num_arguments,
    pg_get_function_result(oid) as return_type
FROM pg_proc
WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
AND proname IN (
    'handle_new_user',
    'ensure_single_active_strategy',
    'create_default_categories',
    'create_default_balanced_strategy',
    'initialize_new_user',
    'auto_initialize_user',
    'expire_temporary_allocations',
    'update_updated_at_column'
)
ORDER BY proname;

-- ============================================================================
-- 9. CHECK CONSTRAINTS
-- ============================================================================
SELECT
    '=== CONSTRAINTS CHECK ===' as section,
    COUNT(*) as total_constraints,
    CASE
        WHEN COUNT(*) >= 15 THEN '✅ PASS - Constraints applied'
        ELSE '⚠️  WARNING - Few constraints found'
    END as status
FROM information_schema.table_constraints
WHERE constraint_schema = 'public'
AND constraint_type IN ('CHECK', 'FOREIGN KEY', 'UNIQUE');

-- ============================================================================
-- 10. CHECK INDEXES
-- ============================================================================
SELECT
    '=== INDEXES CHECK ===' as section,
    COUNT(*) as total_indexes,
    CASE
        WHEN COUNT(*) >= 15 THEN '✅ PASS - Indexes created'
        ELSE '⚠️  WARNING - Few indexes found'
    END as status
FROM pg_indexes
WHERE schemaname = 'public';

-- ============================================================================
-- 11. SAMPLE USER TEST (Run after creating a test user)
-- ============================================================================
-- Uncomment and replace YOUR_USER_ID after creating a test user

/*
SELECT
    '=== USER DATA CHECK ===' as section,
    (SELECT COUNT(*) FROM profiles WHERE id = 'YOUR_USER_ID') as profile_created,
    (SELECT COUNT(*) FROM allocation_categories WHERE user_id = 'YOUR_USER_ID') as categories_created,
    (SELECT COUNT(*) FROM allocation_strategies WHERE user_id = 'YOUR_USER_ID') as strategies_created,
    (SELECT COUNT(*) FROM strategy_allocations
     WHERE strategy_id IN (SELECT id FROM allocation_strategies WHERE user_id = 'YOUR_USER_ID')) as allocations_created;
*/

-- ============================================================================
-- SUMMARY
-- ============================================================================
SELECT
    '=== FINAL SUMMARY ===' as section,
    'Database setup verification complete' as message,
    'Check all sections above for ✅ PASS status' as instruction;

-- ============================================================================
-- EXPECTED RESULTS:
-- ============================================================================
-- All checks should show ✅ PASS
--
-- Tables: 7
-- RLS Enabled: 7
-- Policies: 20+
-- Functions: 6+
-- Triggers: 8+
--
-- If any checks fail, re-run the corresponding migration file
-- ============================================================================
