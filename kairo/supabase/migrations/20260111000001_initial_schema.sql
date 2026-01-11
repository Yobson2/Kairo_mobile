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
