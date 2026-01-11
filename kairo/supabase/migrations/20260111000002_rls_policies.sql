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
