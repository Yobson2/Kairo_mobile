# Kairo - Epics and User Stories

## Epic 1: User Authentication & Onboarding

### Story 1.1: User Registration
**As a** new user
**I want to** create an account with email and password
**So that** I can securely access my financial allocations

**Acceptance Criteria:**
- User can enter email, password, and basic profile information
- Password meets security requirements (min 8 chars, uppercase, lowercase, number)
- Email validation prevents invalid formats
- User receives confirmation after successful registration
- Profile is automatically created in database with default preferences

**Status:** ✅ Complete

---

### Story 1.2: User Login
**As a** returning user
**I want to** log in with my credentials
**So that** I can access my saved allocations

**Acceptance Criteria:**
- User can enter email and password
- Invalid credentials show clear error messages
- Successful login redirects to dashboard or onboarding (if first time)
- Session persists across app restarts

**Status:** ✅ Complete

---

### Story 1.3: Password Recovery
**As a** user who forgot their password
**I want to** reset it via email
**So that** I can regain access to my account

**Acceptance Criteria:**
- User can request password reset via email
- Reset link is valid for 1 hour
- User can set new password meeting security requirements
- Confirmation message shown after successful reset

**Status:** ✅ Complete

---

## Epic 2: Quick Allocation (60-Second Value)

### Story 2.1: Income Entry with Type Selection (FR6)
**As a** new user
**I want to** quickly enter my income amount and type
**So that** I can start allocating immediately

**Acceptance Criteria:**
- Income input accepts numeric values with currency formatting
- User can select income type: Fixed, Variable, or Mixed
- Income type selection uses clear visual indicators (SegmentedButton)
- Input validates for positive numbers
- Income is saved with timestamp

**Status:** ✅ Complete

---

### Story 2.2: Visual Allocation with Sliders (FR1, FR2, FR4, FR5)
**As a** user
**I want to** allocate my income across categories using visual sliders
**So that** I can quickly set my financial priorities

**Acceptance Criteria:**
- 5 default culturally-relevant categories displayed: Family Support, Emergencies, Savings, Daily Needs, Community Contributions
- Each category has a slider with percentage and calculated amount
- Real-time calculation shows remaining unallocated amount
- Visual feedback when total reaches 100%
- Cannot save unless total = 100% (±0.1% tolerance)
- Sliders are large and easy to adjust on mobile

**Status:** ✅ Complete

---

### Story 2.3: Strategy Templates (FR8)
**As a** user
**I want to** choose from pre-built allocation templates
**So that** I can get started with proven strategies quickly

**Acceptance Criteria:**
- 4 templates available: 50/30/20 Balanced, 70/20/10 Conservative, Family Focused, Community Builder
- Each template shows description and percentage breakdown
- Selecting template auto-fills sliders
- User can adjust template percentages before saving
- Templates are culturally relevant for African users

**Status:** ✅ Complete

---

### Story 2.4: Save First Allocation (FR16)
**As a** user
**I want to** save my initial allocation
**So that** I have a starting point for managing my money

**Acceptance Criteria:**
- Save button enabled only when allocation totals 100%
- Loading indicator shown during save
- Success message confirms allocation saved
- User redirected to dashboard after save
- Allocation immediately visible in dashboard

**Status:** ✅ Complete

---

## Epic 3: Category Management

### Story 3.1: View Categories (FR3)
**As a** user
**I want to** see all my allocation categories
**So that** I understand where my money is going

**Acceptance Criteria:**
- All categories displayed with name, color, and icon
- Categories sorted by display_order
- Default categories clearly marked
- Current allocation percentage shown for each

**Status:** ✅ Complete

---

### Story 3.2: Add Custom Category (FR3)
**As a** user
**I want to** create custom allocation categories
**So that** I can track priorities specific to my situation

**Acceptance Criteria:**
- User can tap "Add Category" button
- Dialog allows entering name, selecting color, and choosing icon
- Name is required (max 50 chars)
- Color picker shows palette of options
- Icon picker shows relevant financial icons
- New category saves with user_id and display_order
- Category immediately appears in list

**Status:** ✅ Complete

---

### Story 3.3: Edit Category (FR3)
**As a** user
**I want to** modify existing categories
**So that** I can keep my allocations relevant as priorities change

**Acceptance Criteria:**
- User can tap category to edit
- Dialog pre-fills with current name, color, icon
- Changes save immediately to database
- Updated category reflects in all allocations
- Cannot change system-critical fields for default categories

**Status:** ✅ Complete

---

### Story 3.4: Delete Custom Category (FR3)
**As a** user
**I want to** remove categories I no longer need
**So that** my allocation list stays clean and relevant

**Acceptance Criteria:**
- User can delete custom categories via trash icon
- Confirmation dialog prevents accidental deletion
- Default categories cannot be deleted (trash icon disabled)
- Deletion removes category from database
- Any allocations to deleted category are redistributed or cleared

**Status:** ✅ Complete (with default category protection)

---

### Story 3.5: Reorder Categories (FR3)
**As a** user
**I want to** change the order of categories
**So that** my most important priorities appear first

**Acceptance Criteria:**
- User can drag and drop categories to reorder
- Visual feedback during drag (elevation, opacity)
- New order saves automatically to database (display_order field)
- Order persists across app sessions

**Status:** ✅ Complete

---

## Epic 4: Multiple Allocation Strategies

### Story 4.1: Create Named Strategy (FR9)
**As a** user
**I want to** save multiple allocation strategies with names
**So that** I can switch between different financial plans

**Acceptance Criteria:**
- User can create strategy from allocation screen
- Strategy requires a name (e.g., "Regular Month", "Tight Month", "Bonus Month")
- Strategy saves current allocation percentages
- Strategy marked as active by default if it's the first one
- Strategy stores income type preference

**Status:** ✅ Complete

---

### Story 4.2: View All Strategies (FR9)
**As a** user
**I want to** see all my saved strategies
**So that** I can choose which one to use

**Acceptance Criteria:**
- Strategies screen accessible from dashboard
- Each strategy card shows name and allocation breakdown
- Active strategy clearly indicated with badge/color
- Strategies sorted by last_used_at (most recent first)
- Empty state message if no strategies exist

**Status:** ✅ Complete

---

### Story 4.3: Switch Active Strategy (FR9)
**As a** user
**I want to** activate a different strategy
**So that** I can adjust my allocation for current circumstances

**Acceptance Criteria:**
- User can tap "Set Active" on any strategy
- Only one strategy can be active at a time
- Active strategy immediately used for new allocations
- Confirmation message shown after switch
- Dashboard updates to show new active strategy

**Status:** ✅ Complete

---

### Story 4.4: Edit Strategy (FR9)
**As a** user
**I want to** modify an existing strategy
**So that** I can refine my allocation plans over time

**Acceptance Criteria:**
- User can tap "Edit" on any strategy
- Opens allocation screen pre-filled with strategy percentages
- Changes save to existing strategy (not create new one)
- last_used_at updates if strategy is active
- Confirmation shown after save

**Status:** ✅ Complete

---

### Story 4.5: Delete Strategy (FR9)
**As a** user
**I want to** remove strategies I no longer use
**So that** my strategy list stays manageable

**Acceptance Criteria:**
- User can delete any non-active strategy
- Active strategy cannot be deleted (protection)
- Confirmation dialog prevents accidental deletion
- Strategy removed from database
- If only one strategy exists, cannot delete

**Status:** ✅ Complete (with active strategy protection)

---

## Epic 5: Temporary Allocation Adjustments

### Story 5.1: One-Time Allocation Override (FR10)
**As a** user
**I want to** temporarily adjust my allocation without changing my saved strategy
**So that** I can handle unusual months without losing my standard plan

**Acceptance Criteria:**
- Option to "Adjust for this allocation only" when entering income
- Adjusted percentages don't overwrite saved strategy
- Clear visual indicator this is temporary (e.g., "One-time adjustment")
- Next allocation reverts to saved strategy
- Temporary allocation stored with is_temporary flag

**Status:** ⏳ Pending

---

### Story 5.2: View Allocation History (FR10)
**As a** user
**I want to** see my past allocations
**So that** I can understand my allocation patterns over time

**Acceptance Criteria:**
- History screen accessible from dashboard
- Shows list of all income entries with dates
- Each entry shows amount, type, and allocation breakdown
- Entries sorted by date (newest first)
- Can tap entry to see full details
- Temporary allocations clearly marked

**Status:** ⏳ Pending

---

## Epic 6: Dashboard and Summary

### Story 6.1: Allocation Overview Dashboard (FR12)
**As a** user
**I want to** see a summary of my current allocation
**So that** I can quickly understand my financial plan

**Acceptance Criteria:**
- Dashboard shows latest income amount and date
- Total allocated amount displayed prominently
- Active strategy name shown
- All categories listed with allocated amounts
- Visual progress indicators for each category
- Pull-to-refresh updates data

**Status:** ✅ Complete

---

### Story 6.2: Navigation to Management Screens (FR12)
**As a** user
**I want to** access category and strategy management from dashboard
**So that** I can make adjustments as needed

**Acceptance Criteria:**
- "Manage Categories" button navigates to category management screen
- "Manage Strategies" button navigates to strategies screen
- "New Allocation" button navigates to allocation entry screen
- Bottom navigation (if implemented) provides quick access

**Status:** ✅ Complete

---

### Story 6.3: Allocation Summary Widget (FR11)
**As a** user
**I want to** see how much I've allocated to each category
**So that** I can track my financial priorities

**Acceptance Criteria:**
- Each category shows total allocated amount
- Percentage of income displayed
- Visual bar or chart shows proportion
- Color-coded by category
- Updates in real-time as allocations change

**Status:** ✅ Complete (integrated into dashboard)

---

## Epic 7: Financial Source Management

### Story 7.1: Distinguish Cash vs Mobile Money (FR13)
**As a** user
**I want to** specify if income is cash or mobile money
**So that** I can track different money sources

**Acceptance Criteria:**
- Income entry includes source selection: Cash, Mobile Money (M-Pesa, MTN, Airtel, etc.), Bank
- Source stored with income entry
- Dashboard shows breakdown by source
- Filters available to view allocations by source

**Status:** ✅ Complete (source selection implemented, dashboard breakdown pending)

---

## Epic 8: Learning and Insights

### Story 8.1: Positive Messaging (FR14)
**As a** user
**I want to** see encouraging messages as I allocate
**So that** I feel supported in managing my money

**Acceptance Criteria:**
- Success messages are positive and affirming
- No negative language about money management
- Cultural sensitivity in all messaging
- Celebratory messages for milestones (first allocation, 10 allocations, etc.)
- Loading states use encouraging text

**Status:** ⏳ Pending

---

### Story 8.2: Simple Learning Insights (FR15)
**As a** user
**I want to** receive basic financial insights
**So that** I can improve my allocation decisions

**Acceptance Criteria:**
- Insights based on user's own patterns (not comparisons to others)
- Simple, actionable suggestions (e.g., "Your emergency fund is growing!")
- Insights shown on dashboard or after allocation
- Educational content culturally relevant
- No judgment or pressure

**Status:** ⏳ Pending

---

## Epic 9: Data Security and Privacy

### Story 9.1: Row-Level Security (Technical)
**As a** developer
**I want to** implement RLS policies
**So that** users can only access their own data

**Acceptance Criteria:**
- All tables have RLS enabled
- Policies enforce user_id = auth.uid()
- Service role bypasses RLS for admin functions
- No data leakage between users tested
- RLS policies tested in Supabase console

**Status:** ✅ Complete

---

### Story 9.2: Data Export (FR11 extension)
**As a** user
**I want to** export my allocation data
**So that** I can use it in other tools or keep backups

**Acceptance Criteria:**
- Export button on dashboard or settings
- Formats available: CSV, JSON
- Export includes categories, strategies, income entries, allocations
- Timestamps preserved
- Download directly to device

**Status:** ⏳ Pending

---

## Epic 10: Offline Support

### Story 10.1: Offline Allocation Entry
**As a** user
**I want to** create allocations without internet
**So that** I can use the app anywhere

**Acceptance Criteria:**
- Allocations save to local Drift database when offline
- Queue system tracks pending sync operations
- Auto-sync when connection restored
- Visual indicator when offline
- No data loss during offline usage

**Status:** ⏳ Pending (architecture ready with Drift/Hive)

---

### Story 10.2: Conflict Resolution
**As a** user
**I want to** have my offline changes merged intelligently
**So that** I don't lose data when syncing

**Acceptance Criteria:**
- Last-write-wins for most fields
- Conflicts logged for review
- User notified if manual resolution needed
- Critical fields (allocation totals) validated after merge

**Status:** ⏳ Pending

---

## Summary Status

### By Epic:
1. **Authentication & Onboarding**: 3/3 stories (100%) ✅
2. **Quick Allocation**: 4/4 stories (100%) ✅
3. **Category Management**: 5/5 stories (100%) ✅
4. **Multiple Strategies**: 5/5 stories (100%) ✅
5. **Temporary Adjustments**: 0/2 stories (0%)
6. **Dashboard and Summary**: 3/3 stories (100%) ✅
7. **Financial Source Management**: 1/1 stories (100%) ✅
8. **Learning and Insights**: 0/2 stories (0%)
9. **Data Security and Privacy**: 1/2 stories (50%)
10. **Offline Support**: 0/2 stories (0%)

### Overall Progress:
**22 of 29 stories completed (76%)**

### Immediate Priority Stories (to reach MVP):
1. ~~Story 1.2: User Login (authentication flow)~~ ✅ Complete
2. ~~Story 4.1: Create Named Strategy (complete FR9)~~ ✅ Complete
3. ~~Story 4.4: Edit Strategy (complete FR9)~~ ✅ Complete
4. ~~Story 7.1: Cash vs Mobile Money (FR13)~~ ✅ Complete
5. Story 8.1: Positive Messaging (FR14)
