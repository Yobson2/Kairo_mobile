-- Migration: Allocation Schema for Kairo Financial Management
-- Date: 2024-01-11
-- Description: Creates tables for allocation categories, strategies, and income tracking

-- ============================================================================
-- ALLOCATION CATEGORIES
-- ============================================================================

-- Allocation categories represent where money should go (e.g., Family Support, Savings)
CREATE TABLE public.allocation_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    color TEXT NOT NULL, -- Hex color code for visual distinction
    icon TEXT, -- Icon identifier (e.g., 'family', 'savings', 'emergency')
    is_default BOOLEAN NOT NULL DEFAULT false, -- System-provided defaults vs user-created
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_allocation_categories_user_id ON public.allocation_categories(user_id);
CREATE INDEX idx_allocation_categories_display_order ON public.allocation_categories(user_id, display_order);

-- Trigger for updated_at
CREATE TRIGGER update_allocation_categories_updated_at
    BEFORE UPDATE ON public.allocation_categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE public.allocation_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own allocation categories"
    ON public.allocation_categories FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own allocation categories"
    ON public.allocation_categories FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own allocation categories"
    ON public.allocation_categories FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own allocation categories"
    ON public.allocation_categories FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================================
-- ALLOCATION STRATEGIES
-- ============================================================================

-- Allocation strategies define percentage splits across categories
CREATE TABLE public.allocation_strategies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL, -- e.g., "My Regular Month", "Emergency Strategy"
    is_active BOOLEAN NOT NULL DEFAULT false, -- Only one active strategy at a time
    is_template BOOLEAN NOT NULL DEFAULT false, -- System templates vs user-created
    allocations JSONB NOT NULL DEFAULT '[]', -- Array of {category_id, percentage}
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT valid_allocations CHECK (jsonb_typeof(allocations) = 'array')
);

-- Indexes
CREATE INDEX idx_allocation_strategies_user_id ON public.allocation_strategies(user_id);
CREATE INDEX idx_allocation_strategies_active ON public.allocation_strategies(user_id, is_active);
CREATE INDEX idx_allocation_strategies_allocations ON public.allocation_strategies USING GIN(allocations);

-- Trigger for updated_at
CREATE TRIGGER update_allocation_strategies_updated_at
    BEFORE UPDATE ON public.allocation_strategies
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE public.allocation_strategies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own allocation strategies"
    ON public.allocation_strategies FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own allocation strategies"
    ON public.allocation_strategies FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own allocation strategies"
    ON public.allocation_strategies FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own allocation strategies"
    ON public.allocation_strategies FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================================
-- INCOME ENTRIES
-- ============================================================================

-- Income entries track money coming in (supports variable income)
CREATE TABLE public.income_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    amount DECIMAL(15, 2) NOT NULL CHECK (amount >= 0),
    income_type TEXT NOT NULL CHECK (income_type IN ('fixed', 'variable', 'mixed')),
    source TEXT, -- e.g., "Salary", "Freelance", "Side Hustle"
    received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_income_entries_user_id ON public.income_entries(user_id);
CREATE INDEX idx_income_entries_received_at ON public.income_entries(user_id, received_at DESC);

-- Trigger for updated_at
CREATE TRIGGER update_income_entries_updated_at
    BEFORE UPDATE ON public.income_entries
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE public.income_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own income entries"
    ON public.income_entries FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own income entries"
    ON public.income_entries FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own income entries"
    ON public.income_entries FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own income entries"
    ON public.income_entries FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================================
-- ALLOCATED AMOUNTS
-- ============================================================================

-- Allocated amounts track how much was allocated to each category from an income entry
CREATE TABLE public.allocated_amounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    income_entry_id UUID NOT NULL REFERENCES public.income_entries(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES public.allocation_categories(id) ON DELETE CASCADE,
    strategy_id UUID REFERENCES public.allocation_strategies(id) ON DELETE SET NULL,
    allocated_amount DECIMAL(15, 2) NOT NULL CHECK (allocated_amount >= 0),
    percentage DECIMAL(5, 2) NOT NULL CHECK (percentage >= 0 AND percentage <= 100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_allocated_amounts_user_id ON public.allocated_amounts(user_id);
CREATE INDEX idx_allocated_amounts_income_entry ON public.allocated_amounts(income_entry_id);
CREATE INDEX idx_allocated_amounts_category ON public.allocated_amounts(category_id);

-- Trigger for updated_at
CREATE TRIGGER update_allocated_amounts_updated_at
    BEFORE UPDATE ON public.allocated_amounts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE public.allocated_amounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own allocated amounts"
    ON public.allocated_amounts FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own allocated amounts"
    ON public.allocated_amounts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own allocated amounts"
    ON public.allocated_amounts FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own allocated amounts"
    ON public.allocated_amounts FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================================
-- DEFAULT CATEGORIES SEED FUNCTION
-- ============================================================================

-- Function to create default allocation categories for new users
CREATE OR REPLACE FUNCTION create_default_categories(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
    INSERT INTO public.allocation_categories (user_id, name, color, icon, is_default, display_order)
    VALUES
        (p_user_id, 'Family Support', '#EF4444', 'family', true, 1),
        (p_user_id, 'Emergencies', '#F97316', 'emergency', true, 2),
        (p_user_id, 'Savings', '#10B981', 'savings', true, 3),
        (p_user_id, 'Daily Needs', '#F59E0B', 'daily', true, 4),
        (p_user_id, 'Community Contributions', '#8B5CF6', 'community', true, 5);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to automatically create default categories when a new user signs up
CREATE OR REPLACE FUNCTION handle_new_user_categories()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM create_default_categories(NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_user_created_categories
    AFTER INSERT ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user_categories();

-- ============================================================================
-- STRATEGY TEMPLATE SEED DATA
-- ============================================================================

-- Insert default strategy templates (these are system-wide, not user-specific)
-- Note: For templates, user_id should be a system user or NULL with special RLS handling
-- For simplicity in MVP, we'll create these on-demand in the app rather than seed here
