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
