-- ============================================================================
-- Kairo Initial Database Schema
-- Migration: 20260111000001
-- Description: Creates core tables for allocation management system
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- USERS TABLE (extends Supabase auth.users)
-- ============================================================================
-- Note: Supabase auth.users is managed automatically
-- We'll add a profiles table for additional user data

CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    full_name TEXT,
    phone TEXT,
    preferred_currency TEXT DEFAULT 'KES',
    preferred_language TEXT DEFAULT 'en',
    onboarding_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- ALLOCATION CATEGORIES TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.allocation_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    color TEXT NOT NULL DEFAULT '#6366F1',
    icon TEXT DEFAULT 'category',
    is_default BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    CONSTRAINT category_name_not_empty CHECK (LENGTH(TRIM(name)) > 0),
    CONSTRAINT valid_hex_color CHECK (color ~ '^#[0-9A-Fa-f]{6}$')
);

-- Index for faster user queries
CREATE INDEX idx_allocation_categories_user_id ON public.allocation_categories(user_id);
CREATE INDEX idx_allocation_categories_user_active ON public.allocation_categories(user_id, is_deleted);

-- ============================================================================
-- ALLOCATION STRATEGIES TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.allocation_strategies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT FALSE,
    is_template BOOLEAN DEFAULT FALSE,
    template_type TEXT, -- 'balanced', 'high_savings', 'emergency_focus', 'cultural_priority'
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    CONSTRAINT strategy_name_not_empty CHECK (LENGTH(TRIM(name)) > 0),
    CONSTRAINT valid_template_type CHECK (
        template_type IS NULL OR
        template_type IN ('balanced', 'high_savings', 'emergency_focus', 'cultural_priority')
    )
);

-- Index for faster user queries
CREATE INDEX idx_allocation_strategies_user_id ON public.allocation_strategies(user_id);
CREATE INDEX idx_allocation_strategies_user_active ON public.allocation_strategies(user_id, is_active, is_deleted);

-- Unique constraint: Only one active strategy per user
CREATE UNIQUE INDEX idx_one_active_strategy_per_user
ON public.allocation_strategies(user_id)
WHERE is_active = TRUE AND is_deleted = FALSE;

-- ============================================================================
-- STRATEGY ALLOCATIONS TABLE (Junction table)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.strategy_allocations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    strategy_id UUID NOT NULL REFERENCES public.allocation_strategies(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES public.allocation_categories(id) ON DELETE CASCADE,
    percentage DECIMAL(5, 2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    CONSTRAINT percentage_range CHECK (percentage >= 0 AND percentage <= 100),
    CONSTRAINT unique_strategy_category UNIQUE(strategy_id, category_id)
);

-- Index for faster strategy queries
CREATE INDEX idx_strategy_allocations_strategy_id ON public.strategy_allocations(strategy_id);
CREATE INDEX idx_strategy_allocations_category_id ON public.strategy_allocations(category_id);

-- ============================================================================
-- INCOME ENTRIES TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.income_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    amount DECIMAL(12, 2) NOT NULL,
    currency TEXT NOT NULL DEFAULT 'KES',
    income_date DATE NOT NULL DEFAULT CURRENT_DATE,
    income_type TEXT NOT NULL DEFAULT 'variable', -- 'fixed', 'variable', 'mixed'
    income_source TEXT, -- 'cash', 'mobile_money', 'formal_salary', 'gig_income', 'other'
    description TEXT,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    CONSTRAINT amount_positive CHECK (amount > 0),
    CONSTRAINT valid_income_type CHECK (income_type IN ('fixed', 'variable', 'mixed')),
    CONSTRAINT valid_income_source CHECK (
        income_source IS NULL OR
        income_source IN ('cash', 'mobile_money', 'formal_salary', 'gig_income', 'other')
    ),
    CONSTRAINT valid_currency CHECK (currency IN ('KES', 'NGN', 'GHS', 'ZAR', 'USD', 'EUR'))
);

-- Indexes for faster queries
CREATE INDEX idx_income_entries_user_id ON public.income_entries(user_id);
CREATE INDEX idx_income_entries_user_date ON public.income_entries(user_id, income_date DESC);
CREATE INDEX idx_income_entries_user_active ON public.income_entries(user_id, is_deleted);

-- ============================================================================
-- ALLOCATIONS TABLE (Actual money allocations)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.allocations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    income_entry_id UUID REFERENCES public.income_entries(id) ON DELETE SET NULL,
    category_id UUID NOT NULL REFERENCES public.allocation_categories(id) ON DELETE CASCADE,
    strategy_id UUID REFERENCES public.allocation_strategies(id) ON DELETE SET NULL,
    amount DECIMAL(12, 2) NOT NULL,
    percentage DECIMAL(5, 2) NOT NULL,
    allocation_date DATE NOT NULL DEFAULT CURRENT_DATE,
    is_temporary BOOLEAN DEFAULT FALSE, -- For "This month is different" feature
    temporary_expires_at TIMESTAMPTZ, -- Auto-revert date for temporary allocations
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    CONSTRAINT amount_non_negative CHECK (amount >= 0),
    CONSTRAINT percentage_range CHECK (percentage >= 0 AND percentage <= 100),
    CONSTRAINT temporary_expiry_logic CHECK (
        (is_temporary = FALSE AND temporary_expires_at IS NULL) OR
        (is_temporary = TRUE AND temporary_expires_at IS NOT NULL)
    )
);

-- Indexes for faster queries
CREATE INDEX idx_allocations_user_id ON public.allocations(user_id);
CREATE INDEX idx_allocations_user_date ON public.allocations(user_id, allocation_date DESC);
CREATE INDEX idx_allocations_income_entry ON public.allocations(income_entry_id);
CREATE INDEX idx_allocations_category ON public.allocations(category_id);
CREATE INDEX idx_allocations_temporary ON public.allocations(user_id, is_temporary) WHERE is_temporary = TRUE;

-- ============================================================================
-- INSIGHTS TABLE (Learning insights for positive psychology)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.insights (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    insight_type TEXT NOT NULL, -- 'savings_increase', 'emergency_fund_growth', 'allocation_consistency', etc.
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    data JSONB, -- Structured data for the insight
    is_dismissed BOOLEAN DEFAULT FALSE,
    is_actioned BOOLEAN DEFAULT FALSE,
    valid_from TIMESTAMPTZ DEFAULT NOW(),
    valid_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    CONSTRAINT title_not_empty CHECK (LENGTH(TRIM(title)) > 0),
    CONSTRAINT message_not_empty CHECK (LENGTH(TRIM(message)) > 0)
);

-- Indexes
CREATE INDEX idx_insights_user_id ON public.insights(user_id);
CREATE INDEX idx_insights_user_active ON public.insights(user_id, is_dismissed, valid_from, valid_until);

-- ============================================================================
-- UPDATED_AT TRIGGER FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers to all tables
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_allocation_categories_updated_at BEFORE UPDATE ON public.allocation_categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_allocation_strategies_updated_at BEFORE UPDATE ON public.allocation_strategies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_strategy_allocations_updated_at BEFORE UPDATE ON public.strategy_allocations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_income_entries_updated_at BEFORE UPDATE ON public.income_entries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_allocations_updated_at BEFORE UPDATE ON public.allocations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE public.profiles IS 'User profile information extending Supabase auth.users';
COMMENT ON TABLE public.allocation_categories IS 'User-defined allocation categories (Family Support, Savings, etc.)';
COMMENT ON TABLE public.allocation_strategies IS 'Saved allocation strategies with percentage distributions';
COMMENT ON TABLE public.strategy_allocations IS 'Junction table linking strategies to categories with percentages';
COMMENT ON TABLE public.income_entries IS 'User income entries from various sources';
COMMENT ON TABLE public.allocations IS 'Actual money allocations to categories';
COMMENT ON TABLE public.insights IS 'Learning insights for positive psychology messaging';

-- ============================================================================
-- END OF INITIAL SCHEMA MIGRATION
-- ============================================================================
-- ============================================================================
-- Kairo Row Level Security (RLS) Policies
-- Migration: 20260111000002
-- Description: Implements security policies for all tables
-- ============================================================================

-- ============================================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.allocation_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.allocation_strategies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strategy_allocations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.income_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.allocations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.insights ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- PROFILES TABLE POLICIES
-- ============================================================================

-- Users can view their own profile
CREATE POLICY "Users can view own profile"
ON public.profiles
FOR SELECT
USING (auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile"
ON public.profiles
FOR INSERT
WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
ON public.profiles
FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- ============================================================================
-- ALLOCATION CATEGORIES TABLE POLICIES
-- ============================================================================

-- Users can view their own categories
CREATE POLICY "Users can view own categories"
ON public.allocation_categories
FOR SELECT
USING (auth.uid() = user_id);

-- Users can insert their own categories
CREATE POLICY "Users can insert own categories"
ON public.allocation_categories
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can update their own categories
CREATE POLICY "Users can update own categories"
ON public.allocation_categories
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own categories (soft delete via update)
CREATE POLICY "Users can delete own categories"
ON public.allocation_categories
FOR DELETE
USING (auth.uid() = user_id);

-- ============================================================================
-- ALLOCATION STRATEGIES TABLE POLICIES
-- ============================================================================

-- Users can view their own strategies
CREATE POLICY "Users can view own strategies"
ON public.allocation_strategies
FOR SELECT
USING (auth.uid() = user_id);

-- Users can insert their own strategies
CREATE POLICY "Users can insert own strategies"
ON public.allocation_strategies
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can update their own strategies
CREATE POLICY "Users can update own strategies"
ON public.allocation_strategies
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own strategies
CREATE POLICY "Users can delete own strategies"
ON public.allocation_strategies
FOR DELETE
USING (auth.uid() = user_id);

-- ============================================================================
-- STRATEGY ALLOCATIONS TABLE POLICIES
-- ============================================================================

-- Users can view strategy allocations for their own strategies
CREATE POLICY "Users can view own strategy allocations"
ON public.strategy_allocations
FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.allocation_strategies
        WHERE id = strategy_allocations.strategy_id
        AND user_id = auth.uid()
    )
);

-- Users can insert strategy allocations for their own strategies
CREATE POLICY "Users can insert own strategy allocations"
ON public.strategy_allocations
FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.allocation_strategies
        WHERE id = strategy_allocations.strategy_id
        AND user_id = auth.uid()
    )
);

-- Users can update strategy allocations for their own strategies
CREATE POLICY "Users can update own strategy allocations"
ON public.strategy_allocations
FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM public.allocation_strategies
        WHERE id = strategy_allocations.strategy_id
        AND user_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.allocation_strategies
        WHERE id = strategy_allocations.strategy_id
        AND user_id = auth.uid()
    )
);

-- Users can delete strategy allocations for their own strategies
CREATE POLICY "Users can delete own strategy allocations"
ON public.strategy_allocations
FOR DELETE
USING (
    EXISTS (
        SELECT 1 FROM public.allocation_strategies
        WHERE id = strategy_allocations.strategy_id
        AND user_id = auth.uid()
    )
);

-- ============================================================================
-- INCOME ENTRIES TABLE POLICIES
-- ============================================================================

-- Users can view their own income entries
CREATE POLICY "Users can view own income entries"
ON public.income_entries
FOR SELECT
USING (auth.uid() = user_id);

-- Users can insert their own income entries
CREATE POLICY "Users can insert own income entries"
ON public.income_entries
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can update their own income entries
CREATE POLICY "Users can update own income entries"
ON public.income_entries
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own income entries
CREATE POLICY "Users can delete own income entries"
ON public.income_entries
FOR DELETE
USING (auth.uid() = user_id);

-- ============================================================================
-- ALLOCATIONS TABLE POLICIES
-- ============================================================================

-- Users can view their own allocations
CREATE POLICY "Users can view own allocations"
ON public.allocations
FOR SELECT
USING (auth.uid() = user_id);

-- Users can insert their own allocations
CREATE POLICY "Users can insert own allocations"
ON public.allocations
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can update their own allocations
CREATE POLICY "Users can update own allocations"
ON public.allocations
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own allocations
CREATE POLICY "Users can delete own allocations"
ON public.allocations
FOR DELETE
USING (auth.uid() = user_id);

-- ============================================================================
-- INSIGHTS TABLE POLICIES
-- ============================================================================

-- Users can view their own insights
CREATE POLICY "Users can view own insights"
ON public.insights
FOR SELECT
USING (auth.uid() = user_id);

-- Service role can insert insights (generated by backend functions)
CREATE POLICY "Service can insert insights"
ON public.insights
FOR INSERT
WITH CHECK (true); -- Will be restricted to service_role in Supabase settings

-- Users can update their own insights (dismiss, action)
CREATE POLICY "Users can update own insights"
ON public.insights
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can delete their own insights
CREATE POLICY "Users can delete own insights"
ON public.insights
FOR DELETE
USING (auth.uid() = user_id);

-- ============================================================================
-- HELPER FUNCTION: Auto-create profile on user signup
-- ============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', '')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to auto-create profile when user signs up
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- HELPER FUNCTION: Ensure only one active strategy per user
-- ============================================================================

CREATE OR REPLACE FUNCTION public.ensure_single_active_strategy()
RETURNS TRIGGER AS $$
BEGIN
    -- If setting this strategy as active, deactivate all others for this user
    IF NEW.is_active = TRUE THEN
        UPDATE public.allocation_strategies
        SET is_active = FALSE
        WHERE user_id = NEW.user_id
        AND id != NEW.id
        AND is_active = TRUE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to ensure single active strategy
DROP TRIGGER IF EXISTS ensure_single_active_strategy_trigger ON public.allocation_strategies;
CREATE TRIGGER ensure_single_active_strategy_trigger
    BEFORE INSERT OR UPDATE ON public.allocation_strategies
    FOR EACH ROW
    WHEN (NEW.is_active = TRUE)
    EXECUTE FUNCTION public.ensure_single_active_strategy();

-- ============================================================================
-- HELPER FUNCTION: Auto-expire temporary allocations
-- ============================================================================

CREATE OR REPLACE FUNCTION public.expire_temporary_allocations()
RETURNS void AS $$
BEGIN
    UPDATE public.allocations
    SET is_temporary = FALSE,
        temporary_expires_at = NULL
    WHERE is_temporary = TRUE
    AND temporary_expires_at < NOW()
    AND is_deleted = FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Note: This function should be called by a cron job or scheduled task
-- In Supabase, use pg_cron or call it periodically from the app

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON FUNCTION public.handle_new_user() IS 'Auto-creates profile when new user signs up';
COMMENT ON FUNCTION public.ensure_single_active_strategy() IS 'Ensures only one strategy is active per user';
COMMENT ON FUNCTION public.expire_temporary_allocations() IS 'Expires temporary allocations past their expiry date';

-- ============================================================================
-- END OF RLS POLICIES MIGRATION
-- ============================================================================
-- ============================================================================
-- Kairo Default Categories Setup
-- Migration: 20260111000003
-- Description: Function to create default cultural categories for new users
-- ============================================================================

-- ============================================================================
-- FUNCTION: Create default categories for new user
-- ============================================================================

CREATE OR REPLACE FUNCTION public.create_default_categories(p_user_id UUID)
RETURNS void AS $$
DECLARE
    v_category_count INTEGER;
BEGIN
    -- Check if user already has categories
    SELECT COUNT(*) INTO v_category_count
    FROM public.allocation_categories
    WHERE user_id = p_user_id AND is_deleted = FALSE;

    -- Only create defaults if user has no categories
    IF v_category_count = 0 THEN
        -- 1. Family Support (Cultural priority)
        INSERT INTO public.allocation_categories (user_id, name, description, color, icon, is_default, sort_order)
        VALUES (
            p_user_id,
            'Family Support',
            'Support for extended family members and dependents',
            '#EF4444', -- Red
            'family_restroom',
            TRUE,
            1
        );

        -- 2. Emergencies (Security)
        INSERT INTO public.allocation_categories (user_id, name, description, color, icon, is_default, sort_order)
        VALUES (
            p_user_id,
            'Emergencies',
            'Emergency fund for unexpected expenses',
            '#F59E0B', -- Amber
            'emergency',
            TRUE,
            2
        );

        -- 3. Savings (Future planning)
        INSERT INTO public.allocation_categories (user_id, name, description, color, icon, is_default, sort_order)
        VALUES (
            p_user_id,
            'Savings',
            'Long-term savings and investments',
            '#10B981', -- Green
            'savings',
            TRUE,
            3
        );

        -- 4. Daily Needs (Essential spending)
        INSERT INTO public.allocation_categories (user_id, name, description, color, icon, is_default, sort_order)
        VALUES (
            p_user_id,
            'Daily Needs',
            'Food, transport, utilities, and daily essentials',
            '#3B82F6', -- Blue
            'shopping_cart',
            TRUE,
            4
        );

        -- 5. Community Contributions (Social/cultural obligations)
        INSERT INTO public.allocation_categories (user_id, name, description, color, icon, is_default, sort_order)
        VALUES (
            p_user_id,
            'Community Contributions',
            'Church, community events, and social obligations',
            '#8B5CF6', -- Purple
            'group',
            TRUE,
            5
        );

    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- FUNCTION: Create default balanced strategy for new user
-- ============================================================================

CREATE OR REPLACE FUNCTION public.create_default_balanced_strategy(p_user_id UUID)
RETURNS void AS $$
DECLARE
    v_strategy_id UUID;
    v_category_family UUID;
    v_category_emergencies UUID;
    v_category_savings UUID;
    v_category_daily UUID;
    v_category_community UUID;
    v_strategy_count INTEGER;
BEGIN
    -- Check if user already has strategies
    SELECT COUNT(*) INTO v_strategy_count
    FROM public.allocation_strategies
    WHERE user_id = p_user_id AND is_deleted = FALSE;

    -- Only create default strategy if user has none
    IF v_strategy_count = 0 THEN
        -- Get category IDs (they should exist from create_default_categories)
        SELECT id INTO v_category_family
        FROM public.allocation_categories
        WHERE user_id = p_user_id AND name = 'Family Support' AND is_deleted = FALSE
        LIMIT 1;

        SELECT id INTO v_category_emergencies
        FROM public.allocation_categories
        WHERE user_id = p_user_id AND name = 'Emergencies' AND is_deleted = FALSE
        LIMIT 1;

        SELECT id INTO v_category_savings
        FROM public.allocation_categories
        WHERE user_id = p_user_id AND name = 'Savings' AND is_deleted = FALSE
        LIMIT 1;

        SELECT id INTO v_category_daily
        FROM public.allocation_categories
        WHERE user_id = p_user_id AND name = 'Daily Needs' AND is_deleted = FALSE
        LIMIT 1;

        SELECT id INTO v_category_community
        FROM public.allocation_categories
        WHERE user_id = p_user_id AND name = 'Community Contributions' AND is_deleted = FALSE
        LIMIT 1;

        -- Only proceed if all categories exist
        IF v_category_family IS NOT NULL AND
           v_category_emergencies IS NOT NULL AND
           v_category_savings IS NOT NULL AND
           v_category_daily IS NOT NULL AND
           v_category_community IS NOT NULL THEN

            -- Create balanced strategy
            INSERT INTO public.allocation_strategies (user_id, name, description, is_active, is_template, template_type)
            VALUES (
                p_user_id,
                'Balanced Allocation',
                'A balanced approach covering all essential categories',
                TRUE, -- Make it active by default
                TRUE,
                'balanced'
            )
            RETURNING id INTO v_strategy_id;

            -- Create allocations for the strategy (total = 100%)
            -- Family Support: 20%
            INSERT INTO public.strategy_allocations (strategy_id, category_id, percentage)
            VALUES (v_strategy_id, v_category_family, 20.00);

            -- Emergencies: 15%
            INSERT INTO public.strategy_allocations (strategy_id, category_id, percentage)
            VALUES (v_strategy_id, v_category_emergencies, 15.00);

            -- Savings: 15%
            INSERT INTO public.strategy_allocations (strategy_id, category_id, percentage)
            VALUES (v_strategy_id, v_category_savings, 15.00);

            -- Daily Needs: 40%
            INSERT INTO public.strategy_allocations (strategy_id, category_id, percentage)
            VALUES (v_strategy_id, v_category_daily, 40.00);

            -- Community Contributions: 10%
            INSERT INTO public.strategy_allocations (strategy_id, category_id, percentage)
            VALUES (v_strategy_id, v_category_community, 10.00);

        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- FUNCTION: Initialize new user with defaults
-- ============================================================================

CREATE OR REPLACE FUNCTION public.initialize_new_user(p_user_id UUID)
RETURNS void AS $$
BEGIN
    -- Create default categories
    PERFORM public.create_default_categories(p_user_id);

    -- Create default balanced strategy
    PERFORM public.create_default_balanced_strategy(p_user_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- TRIGGER: Auto-initialize new user on first login
-- ============================================================================

CREATE OR REPLACE FUNCTION public.auto_initialize_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Initialize user with default categories and strategy
    PERFORM public.initialize_new_user(NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS on_user_first_login ON public.profiles;

-- Create trigger on profiles table (runs after profile is created)
CREATE TRIGGER on_user_first_login
    AFTER INSERT ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.auto_initialize_user();

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON FUNCTION public.create_default_categories(UUID) IS 'Creates 5 default cultural categories for a new user';
COMMENT ON FUNCTION public.create_default_balanced_strategy(UUID) IS 'Creates a default balanced allocation strategy for a new user';
COMMENT ON FUNCTION public.initialize_new_user(UUID) IS 'Initializes a new user with default categories and strategy';
COMMENT ON FUNCTION public.auto_initialize_user() IS 'Trigger function to auto-initialize user on first login';

-- ============================================================================
-- END OF DEFAULT CATEGORIES MIGRATION
-- ============================================================================
