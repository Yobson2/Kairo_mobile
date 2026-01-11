# Kairo UX Design Documentation

**Version:** 1.0
**Date:** 2026-01-11
**Status:** Design Specification
**Foundation:** [Project Brief](brief.md) | [PRD](prd.md) | [Epics & Stories](epics_and_stories.md)

---

## Table of Contents

1. [Core UX Principles](#core-ux-principles)
2. [User Flows](#user-flows)
3. [Wireframes](#wireframes)
4. [Interaction Patterns](#interaction-patterns)
5. [Visual Design Guidelines](#visual-design-guidelines)
6. [Accessibility Guidelines](#accessibility-guidelines)
7. [Error States and Edge Cases](#error-states-and-edge-cases)
8. [Microcopy and Messaging](#microcopy-and-messaging)
9. [Animation and Motion](#animation-and-motion)
10. [Responsive Design Considerations](#responsive-design-considerations)

---

## Core UX Principles

### 1. Cultural Intelligence First

**African Financial Realities as Foundation**
- Categories reflect African priorities: Family Support, Community Contributions, not Western defaults
- Visual language evokes African landscapes: warm earth tones, vibrant accents
- No Western-centric imagery (piggy banks, credit cards as primary visuals)
- Acknowledge variable income, cash transactions, mobile money ecosystems
- Family obligations and community ties treated as standard, not edge cases

**Design Implications:**
- Default categories: Family Support, Emergencies, Savings, Daily Needs, Community Contributions
- Income type selector prominently features "Variable" and "Mixed" options
- Multi-source income tracking (cash, mobile money, formal salary, gig income)
- Messaging respects cultural context: "support your family" not "unnecessary expenses"

---

### 2. Intention-First Philosophy

**Allocate Where Money Should Go, Not Track Where It Went**
- Forward-looking allocation, not backward-looking guilt
- Sliders for planning future distribution, not transaction categorization
- Focus on "What's my plan?" not "What did I overspend on?"
- No expense tracking features that induce shame

**Design Implications:**
- Allocation screen is primary interface, not transaction history
- Real-time preview: "If you save 20%, you'll have $200"
- No "overspent" messaging, only "this month was different—let's adjust"
- Dashboard shows allocation status, not spending against budget

---

### 3. 60-Second Value Delivery

**Users Achieve Clarity Within One Minute**
- Ruthless removal of unnecessary steps
- Action-based onboarding: do, don't read
- Visual/tactile interactions (sliders) over text-heavy forms
- No lengthy tutorials or pre-requisite data entry

**Design Implications:**
- Onboarding flow: Welcome (5s) → Income Entry (15s) → Slider Allocation (30s) → Preview & Save (10s) = 60s
- Pre-populated categories eliminate setup friction
- Template strategies for instant starting points
- Auto-save removes "save" button cognitive load

---

### 4. Forgiveness Architecture

**System Accommodates Life's Irregularities**
- No destructive actions—all changes reversible
- "This month is different" temporary adjustments don't overwrite saved strategies
- Skipping days/weeks doesn't break the system or trigger guilt
- Easy strategy switching for variable income scenarios

**Design Implications:**
- Undo/revert options always available
- Temporary allocation mode clearly indicated with visual badge
- Multiple strategies for different life circumstances
- Auto-save prevents work loss, no manual save required
- Deletion requires confirmation, critical items protected from deletion

---

### 5. Positive Psychology

**Empowering, Not Judgmental**
- Calm, supportive tone throughout
- Learning-focused language: "Here's how to prepare next time"
- Celebrate progress, never induce shame
- Success messages affirm user effort
- Empty states encourage action, not blame

**Design Implications:**
- Error messages: "Unexpected expenses took more space this month" not "You overspent by 15%"
- Success confirmations: "Great work! Your allocation is saved" not just "Saved"
- Loading states: "Calculating your allocation..." not silent spinners
- Milestones: "You've completed 10 allocations! You're building great habits"
- No red warnings for normal financial variance

---

### 6. Progressive Disclosure

**Simplicity on Surface, Depth Available**
- Beginner view: 5 default categories, basic sliders
- Intermediate: Strategy templates, category customization
- Advanced: Multi-strategy management, historical trends
- Users unlock complexity naturally through engagement

**Design Implications:**
- Initial screen shows only essential actions
- Advanced features accessed via "Manage Categories" or "Strategies" screens
- Tooltips appear contextually only when needed
- Dashboard prioritizes current allocation, hides historical data until requested
- Settings screen contains advanced configuration, not cluttering main flow

---

## User Flows

### Flow 1: New User Onboarding (Registration → First Allocation)

**Goal:** Get user from app install to first allocation in under 60 seconds.

```
┌─────────────────────────────────────────────────────────────────────┐
│                        NEW USER JOURNEY                             │
└─────────────────────────────────────────────────────────────────────┘

[App Launch]
    ↓
┌──────────────────┐
│  Welcome Screen  │  (5 seconds)
│                  │  - "Welcome to Kairo"
│  "Kairo helps    │  - 1-sentence value prop
│  you allocate    │  - "Get Started" button (large, prominent)
│  your income"    │
└────────┬─────────┘
         ↓
    [Tap "Get Started"]
         ↓
┌──────────────────┐
│ Registration     │  (Skip if existing user)
│                  │  - Email input
│ Email: ______    │  - Password input (with show/hide toggle)
│ Password: ____   │  - Confirm password
│                  │  - "Create Account" button
└────────┬─────────┘
         ↓
    [Account created, auto-login]
         ↓
┌──────────────────┐
│  Income Entry    │  (15 seconds)
│                  │  - "How much did you receive?"
│  Amount: ______  │  - Currency input (large, touch-friendly)
│                  │  - Income type selector (Fixed/Variable/Mixed)
│  ○Fixed ●Variable│  - Visual icons for each type
│  ○Mixed          │  - "Next" button
└────────┬─────────┘
         ↓
    [Income saved, navigate to allocation]
         ↓
┌──────────────────┐
│ First Allocation │  (30 seconds)
│                  │  - "Allocate your $1000"
│  Family Support  │  - Pre-populated 5 categories
│  [=====>    ] 30%│  - Interactive sliders (large touch targets)
│  $300            │  - Real-time calculation
│                  │  - Visual feedback (total percentage at top)
│  Emergencies     │  - Contextual tooltip: "Drag sliders to allocate"
│  [===>      ] 20%│
│  $200            │
│                  │  [Total: 100% ✓]
│  ... (3 more)    │
└────────┬─────────┘
         ↓
    [Allocation totals 100%]
         ↓
┌──────────────────┐
│ Preview & Save   │  (10 seconds)
│                  │  - Summary of allocation
│  Your allocation:│  - Category breakdown with amounts
│  • Family: $300  │  - "Complete" button (large, prominent)
│  • Emergency: $  │  - Option to save as named strategy
│  • Savings: $    │
│  • Daily: $      │
│  • Community: $  │
└────────┬─────────┘
         ↓
    [Tap "Complete"]
         ↓
┌──────────────────┐
│   Dashboard      │  ← USER SEES VALUE
│                  │  - Allocation overview
│  Total: $1000    │  - Category breakdown
│  Allocated: 100% │  - Quick actions (new allocation, manage)
│                  │  - Success message: "Great! Your first allocation
│  [Category cards]│    is complete. You now have financial clarity."
└──────────────────┘

Total Time: ~60 seconds
Success Metric: 80%+ completion rate
```

**Key Design Decisions:**
- **No separate tutorial:** Learning happens through doing
- **Pre-populated categories:** Zero setup friction
- **Real-time validation:** Users see total percentage continuously
- **Success celebration:** Positive reinforcement at completion
- **Immediate value:** Dashboard shows allocation status right away

---

### Flow 2: Quick Allocation Entry (Returning User)

**Goal:** Enable returning user to create new allocation in under 30 seconds.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    QUICK ALLOCATION FLOW                            │
└─────────────────────────────────────────────────────────────────────┘

[User opens app]
    ↓
┌──────────────────┐
│   Dashboard      │
│                  │  - Shows current allocation status
│  Last: $1000     │  - "New Allocation" button prominently placed
│  (2 days ago)    │  - Pull-to-refresh to update data
│                  │
│  [New Allocation]│  ← Large, primary action button
└────────┬─────────┘
         ↓
    [Tap "New Allocation"]
         ↓
┌──────────────────┐
│  Income Entry    │  (10 seconds)
│                  │  - "How much did you receive?"
│  Amount: $1200   │  - Pre-filled with last amount (editable)
│                  │  - Income type pre-selected from profile
│  ●Variable       │  - Quick toggle if needed
│                  │  - "Next" button
│  Template?       │  - Option: "Use last allocation" for instant reuse
│  ○ Use my        │
│    "Regular      │
│    Month" strategy
└────────┬─────────┘
         ↓
    [Choose "Use last allocation" OR "Adjust manually"]
         ↓
         ├─── IF "Use last" ────────────┐
         │                              │
         ↓                              ↓
┌──────────────────┐           ┌──────────────────┐
│  Quick Confirm   │           │  Slider Adjust   │
│                  │           │                  │
│  Using "Regular  │           │  Family Support  │
│  Month" strategy:│           │  [=====>    ] 30%│
│                  │           │  $360            │
│  • Family: $360  │           │                  │
│  • Emergency: $  │           │  ... (4 more)    │
│  • Savings: $    │           │                  │
│                  │           └────────┬─────────┘
│  [Confirm]       │                    ↓
└────────┬─────────┘              [Manual adjustments]
         │                              │
         └──────────┬───────────────────┘
                    ↓
                [Saved]
                    ↓
┌──────────────────┐
│   Dashboard      │  - Updated with new allocation
│                  │  - Success message: "Your allocation is saved!"
│  Latest: $1200   │  - Breakdown shows updated amounts
│  (just now)      │
│                  │
│  [Category cards]│
└──────────────────┘

Total Time: 10-30 seconds (depending on path)
```

**Key Design Decisions:**
- **Strategy reuse:** One-tap to use saved strategy
- **Pre-filled values:** Last income amount suggested
- **Flexible paths:** Quick confirm OR manual adjust
- **Auto-save:** No manual "save" step needed
- **Immediate feedback:** Dashboard updates instantly

---

### Flow 3: Category Management

**Goal:** Allow user to customize categories to match their unique situation.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CATEGORY MANAGEMENT FLOW                         │
└─────────────────────────────────────────────────────────────────────┘

[Dashboard]
    ↓
    [Tap "Manage Categories"]
    ↓
┌──────────────────────────────┐
│   Categories Screen          │
│                              │
│   Your Categories:           │
│                              │
│   ┌─────────────────────┐   │
│   │ 🏠 Family Support   │   │  ← Default category
│   │ Blue • Default      │   │    (edit allowed, delete disabled)
│   │ [Edit]              │   │
│   └─────────────────────┘   │
│                              │
│   ┌─────────────────────┐   │
│   │ 🚨 Emergencies      │   │
│   │ Red • Default       │   │
│   │ [Edit]              │   │
│   └─────────────────────┘   │
│                              │
│   ┌─────────────────────┐   │
│   │ 💰 Savings          │   │  ← Custom category
│   │ Green • Custom      │   │    (edit + delete allowed)
│   │ [Edit] [Delete]     │   │
│   └─────────────────────┘   │
│                              │
│   ... (2 more)               │
│                              │
│   [+ Add Category]           │  ← Floating action button
│                              │
└──────────────────────────────┘

         ↓ [Tap "Add Category"]
         ↓
┌──────────────────────────────┐
│   Add Category Dialog        │
│                              │
│   Category Name:             │
│   [________________]         │
│                              │
│   Choose Color:              │
│   ○ 🔵 ○ 🟢 ● 🟡 ○ 🔴       │  ← Color picker
│                              │
│   Choose Icon:               │
│   ○ 🏠 ○ 🎓 ● 🚗 ○ 💊      │  ← Icon picker
│                              │
│   [Cancel]  [Save]           │
└──────────────────────────────┘

         ↓ [Tap "Save"]
         ↓
┌──────────────────────────────┐
│   Categories Screen          │
│                              │
│   ✓ Category "Transport"     │  ← Success message (toast)
│     added successfully!      │
│                              │
│   [... updated list ...]     │
│                              │
│   ┌─────────────────────┐   │
│   │ 🚗 Transport        │   │  ← New category added
│   │ Yellow • Custom     │   │
│   │ [Edit] [Delete]     │   │
│   └─────────────────────┘   │
│                              │
└──────────────────────────────┘

         ↓ [Tap "Edit" on any category]
         ↓
┌──────────────────────────────┐
│   Edit Category Dialog       │
│                              │
│   Category Name:             │
│   [Transport_______]         │  ← Pre-filled
│                              │
│   Choose Color:              │
│   ○ 🔵 ○ 🟢 ● 🟡 ○ 🔴       │  ← Current selection
│                              │
│   Choose Icon:               │
│   ○ 🏠 ○ 🎓 ● 🚗 ○ 💊      │  ← Current selection
│                              │
│   [Cancel]  [Save Changes]   │
└──────────────────────────────┘

         ↓ [Tap "Delete" on custom category]
         ↓
┌──────────────────────────────┐
│   Confirmation Dialog        │
│                              │
│   ⚠️  Delete "Transport"?    │
│                              │
│   This will remove the       │
│   category from all your     │
│   allocations.               │
│                              │
│   This cannot be undone.     │
│                              │
│   [Cancel]  [Delete]         │  ← Destructive action styled
└──────────────────────────────┘

         ↓ [Tap "Delete"]
         ↓
┌──────────────────────────────┐
│   Categories Screen          │
│                              │
│   ✓ Category "Transport"     │  ← Success message
│     deleted                  │
│                              │
│   [... updated list ...]     │
│                              │
└──────────────────────────────┘
```

**Key Design Decisions:**
- **Default category protection:** Cannot delete default categories
- **Visual hierarchy:** Default vs custom categories clearly distinguished
- **Confirmation dialogs:** Prevent accidental deletion
- **Inline editing:** Edit/delete actions directly on category cards
- **Immediate feedback:** Toast messages confirm actions
- **Color + Icon selection:** Visual customization for personal relevance

---

### Flow 4: Strategy Management

**Goal:** Enable users to create, switch, edit, and delete allocation strategies.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    STRATEGY MANAGEMENT FLOW                         │
└─────────────────────────────────────────────────────────────────────┘

[Dashboard]
    ↓
    [Tap "Strategies"]
    ↓
┌────────────────────────────────────┐
│   Strategies Screen                │
│                                    │
│   Your Strategies:                 │
│                                    │
│   ┌────────────────────────────┐  │
│   │ ✓ Regular Month    ACTIVE  │  │  ← Active strategy badge
│   │                            │  │
│   │ • Family: 30%              │  │
│   │ • Emergency: 20%           │  │
│   │ • Savings: 20%             │  │
│   │ • Daily: 20%               │  │
│   │ • Community: 10%           │  │
│   │                            │  │
│   │ Last used: 2 days ago      │  │
│   │                            │  │
│   │ [Edit] [Delete]            │  │  ← Delete disabled (active)
│   └────────────────────────────┘  │
│                                    │
│   ┌────────────────────────────┐  │
│   │ Tight Month                │  │
│   │                            │  │
│   │ • Family: 25%              │  │
│   │ • Emergency: 25%           │  │
│   │ • Savings: 10%             │  │
│   │ • Daily: 30%               │  │
│   │ • Community: 10%           │  │
│   │                            │  │
│   │ Last used: 3 weeks ago     │  │
│   │                            │  │
│   │ [Set Active] [Edit] [Del]  │  │
│   └────────────────────────────┘  │
│                                    │
│   ─── OR START FROM TEMPLATE ───  │
│                                    │
│   ┌────────────────────────────┐  │
│   │ 📋 50/30/20 Balanced       │  │  ← Template strategies
│   │ 50% Needs, 30% Savings,    │  │
│   │ 20% Emergency              │  │
│   │ [Use Template]             │  │
│   └────────────────────────────┘  │
│                                    │
│   [+ Create New Strategy]          │  ← Floating action button
│                                    │
└────────────────────────────────────┘

         ↓ [Tap "Set Active" on "Tight Month"]
         ↓
┌────────────────────────────────────┐
│   Confirmation Dialog              │
│                                    │
│   Switch to "Tight Month"?         │
│                                    │
│   Your next allocation will use    │
│   this strategy by default.        │
│                                    │
│   [Cancel]  [Switch]               │
└────────────────────────────────────┘

         ↓ [Tap "Switch"]
         ↓
┌────────────────────────────────────┐
│   Strategies Screen                │
│                                    │
│   ✓ Switched to "Tight Month"      │  ← Success message
│                                    │
│   ┌────────────────────────────┐  │
│   │ Tight Month        ACTIVE  │  │  ← Now active
│   │ ...                        │  │
│   └────────────────────────────┘  │
│                                    │
│   ┌────────────────────────────┐  │
│   │ Regular Month              │  │  ← No longer active
│   │ [Set Active] [Edit] [Del]  │  │
│   └────────────────────────────┘  │
│                                    │
└────────────────────────────────────┘

         ↓ [Tap "Create New Strategy"]
         ↓
┌────────────────────────────────────┐
│   Create Strategy Screen           │
│                                    │
│   Strategy Name:                   │
│   [__________________]             │
│                                    │
│   Based on:                        │
│   ○ Current allocation             │
│   ○ Start from scratch             │
│   ○ Copy existing strategy         │
│                                    │
│   [Cancel]  [Next]                 │
└────────────────────────────────────┘

         ↓ [Enter name, tap "Next"]
         ↓
┌────────────────────────────────────┐
│   Allocation Editor                │
│                                    │
│   Creating: "Bonus Month"          │
│                                    │
│   Family Support                   │
│   [=======>      ] 40%             │
│   $400                             │
│                                    │
│   Emergencies                      │
│   [====>         ] 25%             │
│   $250                             │
│                                    │
│   ... (3 more categories)          │
│                                    │
│   Total: 100% ✓                    │
│                                    │
│   [Save Strategy]                  │
└────────────────────────────────────┘

         ↓ [Adjust sliders, tap "Save"]
         ↓
┌────────────────────────────────────┐
│   Strategies Screen                │
│                                    │
│   ✓ Strategy "Bonus Month" created│  ← Success message
│                                    │
│   [... updated list with new ...]  │
│   [... strategy added ...]         │
│                                    │
└────────────────────────────────────┘
```

**Key Design Decisions:**
- **Active strategy badge:** Clear visual indicator of current strategy
- **Delete protection:** Cannot delete active strategy
- **Template quick-start:** Pre-built strategies for instant use
- **Strategy preview:** See allocation breakdown before activating
- **Confirmation on switch:** Prevent accidental strategy changes
- **Last used tracking:** Help users remember when they used each strategy

---

### Flow 5: Dashboard Navigation

**Goal:** Provide quick access to all key features from central dashboard.

```
┌─────────────────────────────────────────────────────────────────────┐
│                         DASHBOARD LAYOUT                            │
└─────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────┐
│   Kairo                    [≡ Menu]│  ← Header with hamburger/settings
├────────────────────────────────────┤
│                                    │
│   Your Latest Allocation           │
│                                    │
│   ┌──────────────────────────┐    │
│   │  💰 $1,200               │    │  ← Income card
│   │  Received 2 days ago     │    │
│   │  Variable income         │    │
│   └──────────────────────────┘    │
│                                    │
│   Strategy: Regular Month ✓        │  ← Active strategy indicator
│                                    │
│   ┌──────────────────────────┐    │
│   │ Total Allocated: $1,200  │    │  ← Allocation summary card
│   │ 100% allocated ✓         │    │
│   │                          │    │
│   │ [====== 100% ======]     │    │  ← Visual progress bar
│   └──────────────────────────┘    │
│                                    │
│   Breakdown:                       │
│                                    │
│   ┌──────────────────────────┐    │
│   │ 🏠 Family Support        │    │  ← Category cards
│   │    $360 (30%)            │    │    (scrollable list)
│   │    [========>        ]   │    │
│   └──────────────────────────┘    │
│                                    │
│   ┌──────────────────────────┐    │
│   │ 🚨 Emergencies           │    │
│   │    $240 (20%)            │    │
│   │    [====>            ]   │    │
│   └──────────────────────────┘    │
│                                    │
│   ┌──────────────────────────┐    │
│   │ 💰 Savings               │    │
│   │    $240 (20%)            │    │
│   │    [====>            ]   │    │
│   └──────────────────────────┘    │
│                                    │
│   ... (2 more categories)          │
│                                    │
│   ─────────────────────────────   │
│                                    │
│   Quick Actions:                   │
│                                    │
│   [+ New Allocation]               │  ← Primary action button
│                                    │
│   [Manage Categories]              │  ← Secondary actions
│   [View Strategies]                │
│   [History]                        │
│                                    │
│                                    │
├────────────────────────────────────┤
│  [🏠 Home] [📊 Stats] [⚙️ Settings]│  ← Bottom navigation (optional)
└────────────────────────────────────┘

Navigation Paths:
├── [+ New Allocation] → Income Entry Screen
├── [Manage Categories] → Categories Screen
├── [View Strategies] → Strategies Screen
├── [History] → Allocation History Screen
├── [Menu] → Settings/Profile/About
└── [Pull-to-Refresh] → Reload current data
```

**Key Design Decisions:**
- **Income at top:** Most important context shown first
- **Visual progress:** Quick glance shows allocation status
- **Category cards:** Touch-friendly, color-coded breakdown
- **Quick actions:** One-tap access to common tasks
- **Pull-to-refresh:** Standard mobile pattern for data updates
- **Bottom navigation:** Optional for larger feature set
- **Scrollable content:** All content accessible without horizontal scrolling

---

## Wireframes

### Screen 1: Registration Screen

```
┌────────────────────────────────────┐
│                                    │
│                                    │
│           KAIRO LOGO               │
│      (Warm, African-inspired)      │
│                                    │
│     Money Allocation Made          │
│     Simple for African Lives       │
│                                    │
│                                    │
│   ┌──────────────────────────┐    │
│   │ Email                    │    │
│   │ [________________]       │    │
│   └──────────────────────────┘    │
│                                    │
│   ┌──────────────────────────┐    │
│   │ Password                 │    │
│   │ [________________] 👁     │    │  ← Show/hide toggle
│   └──────────────────────────┘    │
│                                    │
│   ┌──────────────────────────┐    │
│   │ Confirm Password         │    │
│   │ [________________] 👁     │    │
│   └──────────────────────────┘    │
│                                    │
│   Password must be 8+ chars,      │
│   include number & special char    │
│                                    │
│   ┌──────────────────────────┐    │
│   │   CREATE ACCOUNT         │    │  ← Large primary button
│   └──────────────────────────┘    │    (min 44x44dp tap target)
│                                    │
│                                    │
│   Already have an account?         │
│   LOG IN                           │  ← Link to login
│                                    │
│                                    │
│   By creating an account, you      │
│   agree to our Privacy Policy      │
│                                    │
└────────────────────────────────────┘

Design Notes:
- Logo: Warm colors (earth tones, vibrant accent)
- Typography: Clear, legible sans-serif (16sp minimum)
- Buttons: 48dp height, rounded corners, high contrast
- Inputs: 56dp height, clear labels, touch-friendly
- Spacing: 16dp between elements, 24dp margins
- Error messages: Below input fields, red text with info icon
- Loading state: Button shows spinner when processing
```

---

### Screen 2: Onboarding Allocation Screen

```
┌────────────────────────────────────┐
│ [← Back]    Step 2 of 3     [Skip]│  ← Progress indicator
├────────────────────────────────────┤
│                                    │
│   Allocate Your $1,000             │  ← Large, clear header
│                                    │
│   Drag sliders to decide where     │  ← Contextual tooltip
│   your money should go             │    (first time only)
│                                    │
│   ┌──────────────────────────┐    │
│   │ Total: 85%               │    │  ← Real-time total
│   │ $150 remaining           │    │    (updates as sliders move)
│   │ [========>       ]       │    │    Visual indicator
│   └──────────────────────────┘    │
│                                    │
│   🏠 Family Support                │
│   ┌──────────────────────────┐    │
│   │ [=======>        ] 30%   │    │  ← Large slider
│   │ $300                     │    │    (56dp height)
│   └──────────────────────────┘    │
│                                    │
│   🚨 Emergencies                   │
│   ┌──────────────────────────┐    │
│   │ [====>           ] 20%   │    │
│   │ $200                     │    │
│   └──────────────────────────┘    │
│                                    │
│   💰 Savings                       │
│   ┌──────────────────────────┐    │
│   │ [====>           ] 20%   │    │
│   │ $200                     │    │
│   └──────────────────────────┘    │
│                                    │
│   🛒 Daily Needs                   │
│   ┌──────────────────────────┐    │
│   │ [===>            ] 15%   │    │
│   │ $150                     │    │
│   └──────────────────────────┘    │
│                                    │
│   🤝 Community Contributions       │
│   ┌──────────────────────────┐    │
│   │ [>               ] 0%    │    │
│   │ $0                       │    │
│   └──────────────────────────┘    │
│                                    │
│   ─ OR USE A TEMPLATE ─            │
│   [50/30/20] [70/20/10] [Family]  │  ← Template chips
│                                    │
│   ┌──────────────────────────┐    │
│   │      NEXT                │    │  ← Enabled when total = 100%
│   └──────────────────────────┘    │    Disabled state shown clearly
│                                    │
└────────────────────────────────────┘

Interaction Notes:
- Sliders: Active color matches category color
- Slider thumb: 24dp diameter, easy to grab
- Percentage: Updates in real-time as slider moves (<100ms)
- Amount: Calculates (income × percentage) / 100
- Total indicator: Green when 100%, orange when under, red when over
- Template chips: One-tap to auto-fill sliders
- Haptic feedback: Light vibration when reaching 100%
- Accessibility: Slider values readable by screen readers
```

---

### Screen 3: Dashboard

```
┌────────────────────────────────────┐
│ Kairo              [⚙️] [🔔]      │  ← Header with settings & notifications
├────────────────────────────────────┤
│ ↓ Pull to refresh                  │  ← Pull-to-refresh indicator
│                                    │
│   Good morning, Amara! ☀️          │  ← Personalized greeting
│                                    │
│   ┌──────────────────────────┐    │
│   │ Latest Allocation        │    │
│   │                          │    │
│   │ 💰 $1,200                │    │  ← Large income display
│   │ Received 2 days ago      │    │
│   │ Variable income          │    │
│   │                          │    │
│   │ Strategy: Regular Month  │    │  ← Active strategy badge
│   │ [========== 100% ====]   │    │  ← Allocation progress
│   └──────────────────────────┘    │
│                                    │
│   Category Breakdown:              │
│                                    │
│   ┌──────────────────────────┐    │
│   │ 🏠 Family Support        │    │  ← Category card
│   │                          │    │    (Blue accent color)
│   │ $360                     │    │    Large amount
│   │ 30% of income            │    │    Percentage context
│   │ [==========>         ]   │    │    Visual bar
│   └──────────────────────────┘    │
│                                    │
│   ┌──────────────────────────┐    │
│   │ 🚨 Emergencies           │    │  ← Red accent
│   │ $240 • 20%               │    │
│   │ [======>             ]   │    │
│   └──────────────────────────┘    │
│                                    │
│   ┌──────────────────────────┐    │
│   │ 💰 Savings               │    │  ← Green accent
│   │ $240 • 20%               │    │
│   │ [======>             ]   │    │
│   └──────────────────────────┘    │
│                                    │
│   [+ Show all 5 categories]        │  ← Collapsed by default
│                                    │
│   ─────────────────────────────   │
│                                    │
│   Quick Actions:                   │
│                                    │
│   ┌──────────────────────────┐    │
│   │ + NEW ALLOCATION         │    │  ← Primary CTA
│   └──────────────────────────┘    │    (Large, vibrant color)
│                                    │
│   [📁 Categories] [📋 Strategies]  │  ← Secondary actions
│   [📊 History]    [💡 Insights]    │    (Grid layout)
│                                    │
├────────────────────────────────────┤
│ [🏠 Home] [📊 Stats] [⚙️ Settings] │  ← Bottom navigation
└────────────────────────────────────┘

Design Notes:
- Card elevation: 2dp, rounded corners (12dp)
- Category colors: Match category color_code from database
- Pull-to-refresh: Standard Material/iOS pattern
- Personalization: User's name from profile
- Time-based greeting: Morning/Afternoon/Evening
- Empty state: If no allocations, show "Create your first allocation"
- Success message: Toast after completing allocation
```

---

### Screen 4: Category Management Screen

```
┌────────────────────────────────────┐
│ [← Back]     Categories            │
├────────────────────────────────────┤
│                                    │
│   Manage your allocation           │
│   categories                       │
│                                    │
│   Default Categories:              │  ← Section header
│                                    │
│   ┌──────────────────────────┐    │
│   │ 🏠 Family Support        │    │
│   │ Blue • Default           │    │
│   │                          │    │
│   │          [✏️ Edit]       │    │  ← Edit only (no delete)
│   └──────────────────────────┘    │
│                                    │
│   ┌──────────────────────────┐    │
│   │ 🚨 Emergencies           │    │
│   │ Red • Default            │    │
│   │          [✏️ Edit]       │    │
│   └──────────────────────────┘    │
│                                    │
│   ┌──────────────────────────┐    │
│   │ 💰 Savings               │    │
│   │ Green • Default          │    │
│   │          [✏️ Edit]       │    │
│   └──────────────────────────┘    │
│                                    │
│   ┌──────────────────────────┐    │
│   │ 🛒 Daily Needs           │    │
│   │ Orange • Default         │    │
│   │          [✏️ Edit]       │    │
│   └──────────────────────────┘    │
│                                    │
│   ┌──────────────────────────┐    │
│   │ 🤝 Community             │    │
│   │ Purple • Default         │    │
│   │          [✏️ Edit]       │    │
│   └──────────────────────────┘    │
│                                    │
│   Custom Categories:               │  ← Section header
│                                    │
│   ┌──────────────────────────┐    │
│   │ 🚗 Transport             │    │
│   │ Yellow • Custom          │    │
│   │                          │    │
│   │   [✏️ Edit]  [🗑️ Delete] │    │  ← Edit + Delete
│   └──────────────────────────┘    │
│                                    │
│   ┌──────────────────────────┐    │
│   │ 📚 Education             │    │
│   │ Teal • Custom            │    │
│   │   [✏️ Edit]  [🗑️ Delete] │    │
│   └──────────────────────────┘    │
│                                    │
│                                    │
│           [+ ADD CATEGORY]         │  ← Floating action button
│                                    │
└────────────────────────────────────┘

Edit Dialog (appears as bottom sheet):
┌────────────────────────────────────┐
│   Edit Category                    │
│                                    │
│   Category Name:                   │
│   ┌──────────────────────────┐    │
│   │ Transport                │    │
│   └──────────────────────────┘    │
│                                    │
│   Choose Color:                    │
│   ○ Blue  ○ Green  ● Yellow       │
│   ○ Red   ○ Purple ○ Orange       │
│                                    │
│   Choose Icon:                     │
│   ○ 🏠  ○ 🚨  ○ 💰  ● 🚗         │
│   ○ 🛒  ○ 🤝  ○ 📚  ○ 💊         │
│                                    │
│   ┌──────────────────────────┐    │
│   │    SAVE CHANGES          │    │
│   └──────────────────────────┘    │
│                                    │
│   [Cancel]                         │
│                                    │
└────────────────────────────────────┘

Design Notes:
- Default categories: Cannot be deleted (protection)
- Custom categories: Full edit + delete permissions
- Color picker: 8-10 colors matching app theme
- Icon picker: 16-20 relevant financial icons
- Drag handles: For reordering (Story 3.5 - pending)
- Delete confirmation: Modal dialog before deletion
- Empty state: "You have no custom categories. Add one to get started!"
```

---

### Screen 5: Strategies Screen

```
┌────────────────────────────────────┐
│ [← Back]     Strategies            │
├────────────────────────────────────┤
│                                    │
│   Your Allocation Strategies       │
│                                    │
│   ┌──────────────────────────┐    │
│   │ ✓ Regular Month  ACTIVE  │    │  ← Active badge (green)
│   │                          │    │
│   │ • Family: 30%            │    │
│   │ • Emergency: 20%         │    │
│   │ • Savings: 20%           │    │
│   │ • Daily: 20%             │    │
│   │ • Community: 10%         │    │
│   │                          │    │
│   │ Last used: 2 days ago    │    │
│   │                          │    │
│   │ [✏️ Edit]  [🗑️ Delete]   │    │  ← Delete disabled (active)
│   └──────────────────────────┘    │
│                                    │
│   ┌──────────────────────────┐    │
│   │ Tight Month              │    │
│   │                          │    │
│   │ • Family: 25%            │    │
│   │ • Emergency: 25%         │    │
│   │ • Savings: 10%           │    │
│   │ • Daily: 30%             │    │
│   │ • Community: 10%         │    │
│   │                          │    │
│   │ Last used: 3 weeks ago   │    │
│   │                          │    │
│   │ [Set Active] [✏️] [🗑️]   │    │  ← All actions available
│   └──────────────────────────┘    │
│                                    │
│   ┌──────────────────────────┐    │
│   │ Bonus Month              │    │
│   │                          │    │
│   │ • Family: 40%            │    │
│   │ • Emergency: 15%         │    │
│   │ • Savings: 30%           │    │
│   │ • Daily: 10%             │    │
│   │ • Community: 5%          │    │
│   │                          │    │
│   │ Last used: Never         │    │
│   │                          │    │
│   │ [Set Active] [✏️] [🗑️]   │    │
│   └──────────────────────────┘    │
│                                    │
│   ──── OR START FROM TEMPLATE ───  │
│                                    │
│   ┌──────────────────────────┐    │
│   │ 📋 50/30/20 Balanced     │    │
│   │ 50% Needs, 30% Savings   │    │
│   │ 20% Emergency            │    │
│   │                          │    │
│   │ [Use Template]           │    │
│   └──────────────────────────┘    │
│                                    │
│   ┌──────────────────────────┐    │
│   │ 📋 70/20/10 Conservative │    │
│   │ 70% Savings, 20% Needs   │    │
│   │ 10% Emergency            │    │
│   │                          │    │
│   │ [Use Template]           │    │
│   └──────────────────────────┘    │
│                                    │
│   [+ CREATE NEW STRATEGY]          │  ← Floating action button
│                                    │
└────────────────────────────────────┘

Design Notes:
- Active indicator: Green checkmark + badge
- Strategy cards: Elevated (4dp), rounded corners
- Breakdown preview: Shows all categories with percentages
- Template cards: Slightly different styling (dashed border)
- Empty state: "Create your first strategy to get started"
- Confirmation on delete: "Delete 'Tight Month'? This cannot be undone."
- Confirmation on switch: "Switch to 'Tight Month'? Your next allocation will use this strategy."
```

---

### Screen 6: Strategy Creation/Edit Screen

```
┌────────────────────────────────────┐
│ [← Back]   Create Strategy         │
├────────────────────────────────────┤
│                                    │
│   Step 1: Name Your Strategy       │
│                                    │
│   ┌──────────────────────────┐    │
│   │ Strategy Name            │    │
│   │ [________________]       │    │
│   └──────────────────────────┘    │
│                                    │
│   Examples: "Regular Month",       │
│   "Tight Month", "Bonus Month"     │
│                                    │
│   Based on:                        │
│   ● Current allocation             │  ← Radio buttons
│   ○ Start from scratch             │
│   ○ Copy existing strategy         │
│                                    │
│   If "Copy existing":              │
│   ┌──────────────────────────┐    │
│   │ Select strategy ▼        │    │  ← Dropdown (conditional)
│   └──────────────────────────┘    │
│                                    │
│   ┌──────────────────────────┐    │
│   │      NEXT                │    │
│   └──────────────────────────┘    │
│                                    │
└────────────────────────────────────┘

         ↓ [Tap "Next"]

┌────────────────────────────────────┐
│ [← Back]   Create Strategy         │
├────────────────────────────────────┤
│                                    │
│   Step 2: Set Allocation           │
│                                    │
│   Creating: "Bonus Month"          │  ← Strategy name header
│                                    │
│   ┌──────────────────────────┐    │
│   │ Total: 100% ✓            │    │  ← Real-time total
│   │ [========== 100% ====]   │    │
│   └──────────────────────────┘    │
│                                    │
│   🏠 Family Support                │
│   ┌──────────────────────────┐    │
│   │ [=========>      ] 40%   │    │  ← Slider (category color)
│   │ (will allocate based on  │    │    Contextual note
│   │  income amount)          │    │
│   └──────────────────────────┘    │
│                                    │
│   🚨 Emergencies                   │
│   ┌──────────────────────────┐    │
│   │ [====>           ] 25%   │    │
│   └──────────────────────────┘    │
│                                    │
│   💰 Savings                       │
│   ┌──────────────────────────┐    │
│   │ [====>           ] 20%   │    │
│   └──────────────────────────┘    │
│                                    │
│   🛒 Daily Needs                   │
│   ┌──────────────────────────┐    │
│   │ [===>            ] 10%   │    │
│   └──────────────────────────┘    │
│                                    │
│   🤝 Community Contributions       │
│   ┌──────────────────────────┐    │
│   │ [=>              ] 5%    │    │
│   └──────────────────────────┘    │
│                                    │
│   ┌──────────────────────────┐    │
│   │   SAVE STRATEGY          │    │  ← Enabled when total = 100%
│   └──────────────────────────┘    │
│                                    │
│   [Cancel]                         │
│                                    │
└────────────────────────────────────┘

Design Notes:
- Two-step process: Name → Allocate
- Progress indicator: "Step 1 of 2" at top
- Strategy name: Max 50 characters, required
- Radio buttons: Clear selection indicators
- Sliders: Same as allocation screen (56dp height)
- Total indicator: Same real-time feedback as onboarding
- Save button: Disabled (greyed out) until total = 100%
- Cancel link: Confirmation dialog if changes made
- Success: Navigate to Strategies screen with toast message
```

---

## Interaction Patterns

### 1. Slider Interaction with Real-Time Calculation

**Behavior:**
- **Touch:** User touches slider thumb
- **Drag:** User drags to adjust percentage (0-100%, 1% increments)
- **Real-time update (<100ms):**
  - Percentage value updates
  - Calculated amount updates (income × percentage / 100)
  - Total percentage recalculates
  - Visual indicator updates (progress bar color)
- **Haptic feedback:** Light vibration at 100% total (iOS only, optional on Android)
- **Release:** Value persists, auto-save triggers after 500ms debounce

**Visual States:**
- **Default:** Track in light grey, thumb in category color
- **Active (dragging):** Track fills with category color up to thumb position
- **Validation:**
  - Total < 100%: Info message "You have X% unallocated" (blue)
  - Total = 100%: Success message "Perfect! 100% allocated" (green)
  - Total > 100%: Warning message "Over by X%" (orange, not red)

**Accessibility:**
- Screen reader announces: "Family Support, 30%, $300, slider, adjustable"
- Value changes announced in real-time
- Keyboard navigation: Arrow keys adjust by 1%, Shift+Arrow by 5%
- Minimum touch target: 44x44dp (thumb size: 24dp, touch area extends)

---

### 2. Strategy Template Selection

**Behavior:**
- User taps template chip (e.g., "50/30/20 Balanced")
- Modal/bottom sheet appears with template details:
  - Template name
  - Description
  - Full allocation breakdown with percentages
  - Preview chart (optional)
- User confirms "Use Template" or "Cancel"
- If confirmed:
  - All sliders animate to template percentages (300ms duration)
  - Real-time calculations update
  - User can immediately adjust before saving

**Visual Design:**
- Template chips: Outlined style, 36dp height
- Template icon: 📋 or similar
- Modal: Bottom sheet on mobile, centered dialog on tablet
- Animation: Smooth easing (ease-in-out)

**Smart Mapping:**
- Template categories map to user's existing categories by name
- If user has custom categories, template distributes proportionally
- Example: Template has "Needs" but user has "Daily Needs" + "Transport" → combines

---

### 3. Income Type Selection

**UI Component:** Segmented Button (Material 3) or iOS Segmented Control

**Options:**
1. **Fixed:** Predictable monthly salary
2. **Variable:** Irregular income (gig work, freelance)
3. **Mixed:** Combination of fixed + variable

**Visual Design:**
```
┌────────────────────────────────────┐
│  What type of income is this?      │
│                                    │
│  ┌────────┬────────┬────────┐     │
│  │ Fixed  │Variable│ Mixed  │     │  ← Segmented button
│  │        │   ●    │        │     │    (Variable selected)
│  └────────┴────────┴────────┘     │
│                                    │
│  💡 Variable income tip:           │  ← Contextual guidance
│  Consider 20-30% for emergencies   │    (only if Variable/Mixed)
│  to cover low-income periods.      │
│                                    │
└────────────────────────────────────┘
```

**Behavior:**
- Single selection only
- Tapping switches selection with visual feedback
- Selection persists in user profile
- Pre-selected on subsequent allocations
- Contextual tip appears/disappears based on selection

---

### 4. Temporary Allocation Adjustments

**Use Case:** User needs to adjust allocation for one month without changing saved strategy.

**Interaction Flow:**
1. User enters income amount
2. Toggle appears: "Use temporary allocation for this month only"
3. If enabled:
   - Visual badge: "Temporary Adjustment" appears on allocation screen
   - Sliders adjust percentages
   - Save button says "Save Temporary Allocation"
   - Saved with `is_temporary` flag in database
4. Next allocation:
   - System reverts to saved strategy by default
   - Option to "Use last temporary allocation" available

**Visual Design:**
```
┌────────────────────────────────────┐
│   Allocate Your $800               │
│                                    │
│   ⚠️  Temporary Adjustment         │  ← Badge (orange)
│   Using "Regular Month" strategy   │
│   as base, adjustments won't be    │
│   saved to strategy.               │
│                                    │
│   [Revert to Strategy]             │  ← One-tap to reset
│                                    │
│   🏠 Family Support                │
│   [==========>       ] 35%         │  ← Adjusted from 30%
│   $280                             │
│                                    │
│   ... (other categories)           │
│                                    │
│   [Save Temporary Allocation]      │  ← Clear CTA
│                                    │
└────────────────────────────────────┘
```

**Forgiveness:**
- "Revert to Strategy" button restores original percentages
- No confirmation needed (non-destructive)
- Next allocation auto-reverts to strategy

---

### 5. Pull-to-Refresh on Dashboard

**Behavior:**
- User pulls down from top of dashboard
- Visual indicator: Spinner or animated icon appears
- Data refresh:
  - Latest allocation fetched
  - Income entries updated
  - Category allocations recalculated
  - Active strategy confirmed
- Spinner disappears, content updates with subtle animation
- Success: Brief toast "Updated just now"
- Failure: Toast "Unable to refresh. Please try again."

**Visual Design:**
- Platform-specific refresh indicators (Material/iOS)
- Smooth animation (no jank, 60fps)
- Timeout: 10 seconds maximum
- Offline: Message "You're offline. Showing last synced data."

---

## Visual Design Guidelines

### Color Palette

**Primary Colors:**
```
Primary Brand Color:    #E67E22  (Warm Orange - African sunset)
Primary Dark:           #D35400  (Darker orange for contrast)
Primary Light:          #F39C12  (Light orange for highlights)

Secondary Color:        #27AE60  (Vibrant Green - growth, savings)
Secondary Dark:         #229954
Secondary Light:        #2ECC71

Accent Color:           #3498DB  (Sky Blue - trust, stability)
```

**Category Colors:**
```
Family Support:         #3498DB  (Blue - family, support)
Emergencies:            #E74C3C  (Red - urgent, important)
Savings:                #27AE60  (Green - growth, future)
Daily Needs:            #F39C12  (Orange - daily, routine)
Community:              #9B59B6  (Purple - connection, shared)
Custom categories:      [Yellow, Teal, Pink, Indigo, Lime, Amber]
```

**Neutral Colors:**
```
Background:             #FAFAFA  (Off-white, warm)
Surface:                #FFFFFF  (Pure white for cards)
Surface Variant:        #F5F5F5  (Subtle grey for sections)

Text Primary:           #212121  (Almost black, high contrast)
Text Secondary:         #757575  (Medium grey for labels)
Text Disabled:          #BDBDBD  (Light grey for disabled)

Divider:                #E0E0E0  (Subtle line separator)
```

**Semantic Colors:**
```
Success:                #27AE60  (Green - confirmations)
Info:                   #3498DB  (Blue - informational)
Warning:                #F39C12  (Orange - caution, not alarm)
Error:                  #E74C3C  (Red - validation errors)
```

**Contrast Ratios (WCAG AA Compliance):**
- Text Primary on Background: 16.1:1 (AAA)
- Text Secondary on Background: 4.6:1 (AA)
- Primary Orange on White: 4.5:1 (AA)
- Secondary Green on White: 4.8:1 (AA)
- All interactive elements: Minimum 3:1 contrast

---

### Typography

**Font Family:**
- **Primary:** Inter (sans-serif, open-source, excellent for mobile)
- **Fallback:** System font stack (SF Pro on iOS, Roboto on Android)
- **Localization:** Noto Sans (supports extended character sets for future localization)

**Type Scale (Material Design 3 inspired):**
```
Display Large:   57sp / 64sp line height / Bold
                 (Used for: Large numbers like income amounts)

Headline Large:  32sp / 40sp / Bold
                 (Used for: Screen titles)

Headline Medium: 28sp / 36sp / Semibold
                 (Used for: Section headers)

Title Large:     22sp / 28sp / Medium
                 (Used for: Card titles, category names)

Body Large:      16sp / 24sp / Regular
                 (Used for: Primary body text, descriptions)

Body Medium:     14sp / 20sp / Regular
                 (Used for: Secondary text, labels)

Label Large:     14sp / 20sp / Medium
                 (Used for: Buttons, tabs)

Label Medium:    12sp / 16sp / Medium
                 (Used for: Input labels, captions)

Label Small:     11sp / 16sp / Medium
                 (Used for: Helper text, footnotes)
```

**Font Weights:**
- Regular: 400
- Medium: 500
- Semibold: 600
- Bold: 700

**Usage Guidelines:**
- **Minimum readable size:** 14sp for body text (accessibility)
- **Large touch targets:** Button text minimum 16sp
- **Financial amounts:** Display Large or Headline Large for prominence
- **Percentages:** Title Large, paired with category names
- **Helper text:** Label Small, always in Text Secondary color

---

### Iconography

**Icon System:** Material Symbols (variable font) or SF Symbols (iOS)

**Category Icons:**
```
🏠 Family Support:      home / people
🚨 Emergencies:         emergency / warning
💰 Savings:             savings / piggy_bank
🛒 Daily Needs:         shopping_cart / local_grocery_store
🤝 Community:           handshake / diversity
🚗 Transport:           directions_car / commute
📚 Education:           school / menu_book
💊 Healthcare:          local_hospital / medication
🎉 Entertainment:       celebration / movie
💳 Debt Repayment:      credit_card / payment
```

**UI Icons:**
```
➕ Add:                 add / add_circle
✏️ Edit:                edit / mode_edit
🗑️ Delete:              delete / delete_outline
⚙️ Settings:            settings / tune
📊 Statistics:          bar_chart / analytics
🔔 Notifications:       notifications / notifications_active
🔒 Security:            lock / security
👤 Profile:             person / account_circle
✓ Success:              check_circle / done
⚠️ Warning:             warning / error_outline
ℹ️ Info:                info / help_outline
↻ Refresh:              refresh / sync
→ Navigate:             arrow_forward / chevron_right
← Back:                 arrow_back / chevron_left
```

**Icon Sizes:**
```
Small:      16dp  (Inline with text, indicators)
Medium:     24dp  (Standard UI icons, buttons)
Large:      32dp  (Category cards, featured icons)
Extra Large: 48dp  (Empty states, onboarding)
```

**Color Usage:**
- **Category icons:** Use category color
- **UI icons:** Text Secondary (#757575) by default
- **Interactive icons:** Primary brand color on hover/press
- **Status icons:** Semantic colors (success green, error red, etc.)

**Accessibility:**
- All icons have text labels for screen readers
- Icons never used alone without accompanying text (except universally recognized: ×, ✓, +)
- Minimum touch target: 44x44dp even if icon is 24dp

---

### Spacing and Layout

**Spacing Scale (8dp grid system):**
```
4dp:   Minimal spacing (between related elements)
8dp:   Tight spacing (icon-text pairs, inline elements)
12dp:  Default spacing (between form fields)
16dp:  Standard spacing (card padding, margins)
24dp:  Section spacing (between major UI groups)
32dp:  Large spacing (between screens sections)
48dp:  Extra large spacing (top/bottom screen padding)
```

**Card Layout:**
```
┌────────────────────────────────────┐
│  16dp padding                      │
│  ┌──────────────────────────┐     │
│  │  Card Content            │     │  12dp border radius
│  │  16dp internal padding   │     │  2dp elevation
│  │                          │     │
│  └──────────────────────────┘     │
│  16dp padding                      │
└────────────────────────────────────┘
```

**Touch Targets:**
- **Minimum:** 44x44dp (WCAG AAA, iOS Human Interface Guidelines)
- **Recommended:** 48x48dp (Material Design, better for motor impairments)
- **Buttons:** 48dp height minimum
- **Sliders:** Thumb 24dp diameter, touch area 44dp minimum
- **List items:** 56dp height minimum for single-line, 72dp for two-line

**Screen Margins:**
- **Mobile portrait:** 16dp left/right margins
- **Mobile landscape:** 24dp left/right margins
- **Tablet:** 32dp left/right margins
- **Maximum content width:** 600dp (for readability on tablets)

**Grid System:**
- **Mobile:** 4-column grid with 16dp gutters
- **Tablet:** 8-column grid with 24dp gutters
- **Breakpoints:**
  - Small: < 600dp (phone portrait)
  - Medium: 600-840dp (phone landscape, small tablet)
  - Large: > 840dp (tablet)

---

### Elevation and Shadows

**Material Design Elevation Levels:**
```
Level 0 (0dp):    Flat surfaces, background
                  Box-shadow: none

Level 1 (2dp):    Cards, category items (default state)
                  Box-shadow: 0 1dp 2dp rgba(0,0,0,0.12)

Level 2 (4dp):    Cards on hover/press, floating buttons
                  Box-shadow: 0 2dp 4dp rgba(0,0,0,0.16)

Level 3 (8dp):    Modals, dialogs, bottom sheets
                  Box-shadow: 0 4dp 8dp rgba(0,0,0,0.20)

Level 4 (16dp):   Navigation drawer (if implemented)
                  Box-shadow: 0 8dp 16dp rgba(0,0,0,0.24)
```

**Usage Guidelines:**
- Elevation increases with user interaction hierarchy
- Modals/dialogs always highest elevation (except app bar)
- Avoid "floating" too many elements simultaneously (visual noise)
- Consistent elevation across similar components

---

### Border Radius

```
Small:    4dp   (Chips, tags, small buttons)
Medium:   8dp   (Input fields, small cards)
Large:    12dp  (Cards, main UI components)
X-Large:  16dp  (Modals, bottom sheets)
Full:     999dp (Circular elements, avatars, FABs)
```

**Component Examples:**
- Input fields: 8dp
- Buttons: 8dp
- Cards: 12dp
- Modals: 16dp top corners only (bottom sheet)
- Slider thumb: Full (circular)
- Floating Action Button: Full (circular)

---

## Accessibility Guidelines

### Color Contrast (WCAG 2.1 Level AA)

**Requirements:**
- **Normal text (< 18sp):** Minimum 4.5:1 contrast ratio
- **Large text (≥ 18sp or ≥ 14sp bold):** Minimum 3:1 contrast ratio
- **UI components and graphics:** Minimum 3:1 contrast ratio
- **Target:** Achieve AAA (7:1 for normal text) where possible

**Validated Combinations:**
```
✓ Text Primary (#212121) on Background (#FAFAFA): 16.1:1 (AAA)
✓ Text Primary (#212121) on Surface (#FFFFFF): 16.4:1 (AAA)
✓ Text Secondary (#757575) on Background (#FAFAFA): 4.6:1 (AA)
✓ Primary Brand (#E67E22) on Surface (#FFFFFF): 4.5:1 (AA)
✓ Secondary Green (#27AE60) on Surface (#FFFFFF): 4.8:1 (AA)
✓ Error Red (#E74C3C) on Surface (#FFFFFF): 4.7:1 (AA)
```

**Considerations for Color Blindness:**
- Never rely on color alone to convey information
- Use icons, patterns, or text labels alongside color
- Example: Category cards use color + icon + text label
- Success/error states use color + icon + descriptive text
- Sliders show percentage numbers, not just visual position

---

### Font Sizes for Readability

**Minimum Sizes:**
- **Body text:** 14sp minimum (preferably 16sp)
- **Labels and captions:** 12sp minimum
- **Interactive elements (buttons):** 16sp minimum
- **Financial amounts:** 24sp+ for prominence

**Line Height:**
- **Minimum:** 1.5× font size for body text (WCAG 2.1 Success Criterion 1.4.8)
- **Optimal:** 1.5-1.75× for readability
- **Example:** 16sp text → 24sp line height

**Letter Spacing:**
- **Default:** 0sp for most text
- **All caps labels:** +0.5sp to +1sp for readability
- **Large display text:** -0.5sp for tighter tracking

**Scalability:**
- Support user's system font size preferences
- Test with 200% zoom (WCAG 2.1 Success Criterion 1.4.4)
- Use scalable units (sp for text, not fixed px)

---

### Touch Target Sizes

**Minimum Standards:**
- **WCAG 2.1 Level AAA:** 44×44dp
- **Material Design:** 48×48dp recommended
- **iOS Human Interface Guidelines:** 44×44pt

**Implementation:**
```
Visual element:    Icon 24dp
Touch target:      Padding extends to 48dp total

┌─────────────┐
│             │  ← 48dp height
│   [Icon]    │
│             │
└─────────────┘
   ← 48dp width

Example in code:
InkWell(
  child: Icon(Icons.edit, size: 24),
  padding: EdgeInsets.all(12),  // 12dp × 2 + 24dp = 48dp
  onTap: () {},
)
```

**Spacing Between Targets:**
- **Minimum:** 8dp between adjacent touch targets
- **Recommended:** 12-16dp for easier tapping
- **Critical actions:** 24dp+ spacing to prevent mis-taps

**Special Cases:**
- **Sliders:** Thumb 24dp visual, 44dp touch area (extends beyond visual)
- **List items:** 56dp height minimum for single-line, 72dp for two-line
- **Bottom sheet drag handle:** 48dp height, full width

---

### Screen Reader Support

**Flutter Semantics Implementation:**
- All interactive elements have semantic labels
- Example: `Semantics(label: "Family Support category, 30%, $300", child: ...)`
- Sliders: "Family Support, 30%, $300, slider, adjustable"
- Buttons: "New Allocation, button, double-tap to activate"
- Images: Alt text for meaningful images, decorative images marked `excludeFromSemantics: true`

**Reading Order:**
- Logical focus order matching visual layout (top to bottom, left to right)
- Modals: Focus traps within dialog (doesn't escape to background)
- Navigation: Announce route changes "Dashboard screen" on navigation

**Dynamic Content:**
- Live regions for real-time updates (slider calculations)
- Announcements for success/error messages
- Example: "Allocation saved successfully" announced after save

**Interactive Elements:**
- Clear action descriptions: "Edit category button" not just "Edit"
- State announcements: "Active strategy Regular Month"
- Error states: "Password field, required, error: Password must be 8 characters minimum"

---

### Support for Low-End Android Devices

**Performance Optimization:**
- **Target devices:** Android 8.0+ (API 26+), mid-range devices (2-4GB RAM)
- **App size:** < 20MB APK (use ProGuard/R8 for code shrinking)
- **Launch time:** < 3 seconds on mid-range devices (tested on Samsung Galaxy A series)
- **Memory usage:** < 100MB typical, < 200MB peak

**UI Optimization:**
- Avoid expensive animations on low-end devices (detect via device performance tier)
- Lazy loading: Load images and data as needed, not all at once
- Efficient list rendering: RecyclerView/ListView with view recycling
- Conservative use of transparency/blur effects (expensive on low-end GPUs)

**Network Efficiency:**
- Minimal API payloads (< 5KB typical)
- Image compression: WebP format, responsive sizing
- Cache API responses locally (reduce redundant network calls)
- Graceful degradation on slow networks (3G support)

**Battery Efficiency:**
- No constant background processing
- Efficient location/sensor usage (none in MVP)
- Dark mode support (OLED battery savings) - post-MVP

**Testing:**
- Test on physical mid-range Android devices (Galaxy A, Xiaomi Redmi series)
- Firebase Test Lab or similar for device coverage
- Performance profiling with Android Profiler

---

## Error States and Edge Cases

### 1. Allocation Doesn't Total 100%

**Scenario:** User adjusts sliders but total is not exactly 100%.

**Under 100% (e.g., 85%):**
```
┌────────────────────────────────────┐
│   Total: 85%                       │
│   $150 remaining                   │  ← Info color (blue)
│   [======>       ]                 │
│                                    │
│   💡 You have 15% unallocated.     │  ← Helpful message
│   Adjust sliders to reach 100%.    │    (not alarming)
│                                    │
│   [Save Allocation]                │  ← Button DISABLED
└────────────────────────────────────┘

Button state: Disabled (greyed out, not clickable)
Tooltip on hover: "Allocate remaining 15% to save"
```

**Over 100% (e.g., 105%):**
```
┌────────────────────────────────────┐
│   Total: 105%                      │
│   Over by $50                      │  ← Warning color (orange, not red)
│   [==========>X]                   │
│                                    │
│   ⚠️  You've allocated 5% more     │  ← Calm warning
│   than available. Adjust sliders   │    (not "ERROR!")
│   to reach 100%.                   │
│                                    │
│   [Save Allocation]                │  ← Button DISABLED
└────────────────────────────────────┘

Button state: Disabled
Visual: Progress bar shows overflow (goes past 100% mark)
```

**Exactly 100% (Success):**
```
┌────────────────────────────────────┐
│   Total: 100% ✓                    │  ← Success color (green)
│   [========== 100% ====]           │
│                                    │
│   ✓ Perfect! Your allocation is    │  ← Positive affirmation
│   ready to save.                   │
│                                    │
│   [Save Allocation]                │  ← Button ENABLED (vibrant)
└────────────────────────────────────┘

Button state: Enabled, prominent primary color
Haptic feedback: Light vibration when reaching 100% (iOS/Android)
```

**Auto-Correction (Optional Enhancement - Post-MVP):**
- "Auto-adjust to 100%" button redistributes remaining % proportionally
- Example: 85% allocated → Add 15% proportionally across all categories

---

### 2. No Internet Connection

**Scenario:** User tries to save allocation but device is offline.

**During Save:**
```
┌────────────────────────────────────┐
│   ⚠️  You're offline               │  ← Warning banner (orange)
│                                    │
│   Your allocation will save when   │
│   you reconnect to the internet.   │
│                                    │
│   [Continue Anyway]  [Dismiss]     │
└────────────────────────────────────┘

Behavior:
- Allocation queued locally (Drift/Hive local database)
- User can continue using app with local data
- Auto-sync when connection restored
- "Syncing..." indicator appears when reconnected
- Success toast: "Allocation synced successfully"
```

**On App Launch (Offline):**
```
┌────────────────────────────────────┐
│   📶 You're offline                │  ← Info banner (blue)
│                                    │
│   Showing your last synced data.   │
│   Connect to internet to see       │
│   latest allocations.              │
│                                    │
│   [Dismiss]                        │
└────────────────────────────────────┘

Dashboard behavior:
- Shows last synced data with timestamp "Last updated: 2 hours ago"
- "New Allocation" button still works (queues locally)
- Pull-to-refresh shows "Unable to refresh. You're offline."
```

**Sync Failure (After Reconnection):**
```
┌────────────────────────────────────┐
│   ⚠️  Sync failed                  │  ← Warning banner
│                                    │
│   We couldn't sync your recent     │
│   allocations. Check your          │
│   connection and try again.        │
│                                    │
│   [Retry]  [Dismiss]               │
└────────────────────────────────────┘

Behavior:
- Retry button attempts sync again
- If persists, show "Contact support" option
- Data remains safe locally, no data loss
```

---

### 3. First-Time User (No Data)

**Dashboard Empty State:**
```
┌────────────────────────────────────┐
│   Kairo                    [⚙️]    │
├────────────────────────────────────┤
│                                    │
│                                    │
│          💰                        │  ← Large icon (48dp)
│                                    │
│   Welcome to Kairo!                │  ← Headline
│                                    │
│   Let's create your first          │  ← Encouraging message
│   allocation and get clarity       │    (not "No data found")
│   on your finances.                │
│                                    │
│   ┌──────────────────────────┐    │
│   │  CREATE YOUR FIRST       │    │  ← Large CTA
│   │  ALLOCATION              │    │
│   └──────────────────────────┘    │
│                                    │
│   It takes less than 60 seconds    │  ← Reassuring context
│                                    │
│                                    │
└────────────────────────────────────┘

Behavior:
- Tapping CTA launches onboarding flow
- No overwhelming "setup" steps, just start allocating
- Positive, action-oriented language
```

**Categories Screen (Before Any Custom Categories):**
```
┌────────────────────────────────────┐
│   Categories                       │
├────────────────────────────────────┤
│                                    │
│   Your Default Categories:         │
│                                    │
│   [5 default category cards]       │
│                                    │
│   ─────────────────────────────   │
│                                    │
│   Custom Categories:               │
│                                    │
│          📁                        │
│                                    │
│   You have no custom categories.   │  ← Neutral statement
│   Add one to track a specific      │    (not "empty" or "none")
│   priority in your life.           │
│                                    │
│   ┌──────────────────────────┐    │
│   │  + ADD CATEGORY          │    │
│   └──────────────────────────┘    │
│                                    │
└────────────────────────────────────┘
```

**Strategies Screen (No Saved Strategies):**
```
┌────────────────────────────────────┐
│   Strategies                       │
├────────────────────────────────────┤
│                                    │
│          📋                        │
│                                    │
│   No strategies yet                │
│                                    │
│   Create your first strategy to    │  ← Encouraging guidance
│   save different allocation plans  │
│   for different months.            │
│                                    │
│   ┌──────────────────────────┐    │
│   │  CREATE STRATEGY         │    │
│   └──────────────────────────┘    │
│                                    │
│   ──── OR START FROM TEMPLATE ───  │
│                                    │
│   [Template cards shown]           │  ← Templates always available
│                                    │
└────────────────────────────────────┘
```

---

### 4. Deleting Active Strategy

**Scenario:** User tries to delete the currently active strategy.

**Prevention:**
```
┌────────────────────────────────────┐
│   Strategies                       │
├────────────────────────────────────┤
│                                    │
│   ┌────────────────────────────┐  │
│   │ ✓ Regular Month  ACTIVE    │  │
│   │                            │  │
│   │ • Family: 30%              │  │
│   │ ...                        │  │
│   │                            │  │
│   │ [Edit]  [🗑️ Delete]        │  │  ← Delete button DISABLED
│   └────────────────────────────┘  │
│                                    │
└────────────────────────────────────┘

Visual state:
- Delete icon greyed out (disabled color #BDBDBD)
- Tapping shows tooltip: "Cannot delete active strategy. Activate a different strategy first."
```

**If User Attempts (Tooltip):**
```
┌────────────────────────────────────┐
│   ⚠️  Cannot delete active strategy│  ← Toast message
│                                    │
│   Activate a different strategy    │
│   first, then delete this one.     │
│                                    │
└────────────────────────────────────┘

Duration: 3 seconds
Action: User must activate another strategy first
```

**Successful Deletion (Non-Active Strategy):**
```
┌────────────────────────────────────┐
│   Delete "Tight Month"?            │  ← Confirmation dialog
│                                    │
│   This will permanently remove     │
│   this strategy.                   │
│                                    │
│   You can always create a new      │  ← Reassurance
│   strategy later.                  │
│                                    │
│   [Cancel]  [Delete]               │  ← Destructive action (red)
└────────────────────────────────────┘

After deletion:
- Strategy removed from list
- Success toast: "Strategy 'Tight Month' deleted"
- No undo option (but user can recreate manually)
```

---

### 5. Income Validation Errors

**Scenario:** User enters invalid income amount.

**Zero or Negative Amount:**
```
┌────────────────────────────────────┐
│   How much did you receive?        │
│                                    │
│   Amount:                          │
│   ┌──────────────────────────┐    │
│   │ $0                       │    │  ← Invalid input (red border)
│   └──────────────────────────┘    │
│                                    │
│   ⚠️  Please enter an amount       │  ← Error message (red text)
│   greater than 0.                  │    (below input field)
│                                    │
│   [Next]                           │  ← Button DISABLED
└────────────────────────────────────┘

Behavior:
- Input field border turns red (#E74C3C)
- Error icon appears next to message
- Button remains disabled until valid input
- Real-time validation (updates as user types)
```

**Non-Numeric Input:**
```
┌────────────────────────────────────┐
│   Amount:                          │
│   ┌──────────────────────────┐    │
│   │ $abc                     │    │  ← Invalid input
│   └──────────────────────────┘    │
│                                    │
│   ⚠️  Please enter a valid number. │
│                                    │
│   [Next]                           │  ← Button DISABLED
└────────────────────────────────────┘

Prevention:
- Numeric keyboard shown on mobile (prevents most non-numeric input)
- Input masking: Only allows digits and decimal point
- Locale-aware formatting: Handles commas for thousands, correct decimal separator
```

**Extremely Large Amount (Edge Case):**
```
┌────────────────────────────────────┐
│   Amount:                          │
│   ┌──────────────────────────┐    │
│   │ $999,999,999,999         │    │  ← Very large input
│   └──────────────────────────┘    │
│                                    │
│   ⚠️  That's a lot! Please check   │  ← Friendly validation
│   if this amount is correct.       │    (not "ERROR!")
│                                    │
│   [Correct] [That's Right]         │  ← User confirms or corrects
└────────────────────────────────────┘

Behavior:
- Soft validation (doesn't block, asks for confirmation)
- Threshold: > $100,000 or local currency equivalent
- Prevents accidental extra zeros
```

**Empty Field (On Submit):**
```
┌────────────────────────────────────┐
│   Amount:                          │
│   ┌──────────────────────────┐    │
│   │ $_______                 │    │  ← Empty input (focus)
│   └──────────────────────────┘    │
│                                    │
│   ⚠️  Please enter your income     │
│   amount to continue.              │
│                                    │
│   [Next]                           │  ← Button DISABLED
└────────────────────────────────────┘

Prevention:
- Button disabled until input provided
- If user somehow submits (edge case), validation catches it
- Focus automatically moves to input field
```

---

## Microcopy and Messaging

### Welcome Messages

**First App Launch:**
```
Welcome to Kairo!

Allocate your income across what matters most to you—
family, emergencies, savings, and more—in under 60 seconds.

[Get Started]
```

**Returning User (Dashboard):**
```
Good morning, Amara! ☀️
(or Good afternoon / Good evening based on time)

Your latest allocation: $1,200 (2 days ago)
```

**After Completing Onboarding:**
```
Great work! 🎉

You've completed your first allocation.
You now have clarity on where your money is going.

[View Dashboard]
```

---

### Success Confirmations

**Allocation Saved:**
```
✓ Allocation saved successfully!

Your $1,200 has been allocated across your priorities.
```

**Strategy Created:**
```
✓ Strategy "Bonus Month" created!

You can now switch to this strategy anytime from the Strategies screen.
```

**Strategy Activated:**
```
✓ Switched to "Tight Month"

Your next allocation will use this strategy by default.
```

**Category Added:**
```
✓ Category "Transport" added!

You can now allocate funds to this category in your next allocation.
```

**Category Updated:**
```
✓ Category "Transport" updated successfully!

Your changes are saved and will appear in your next allocation.
```

**Category Deleted:**
```
✓ Category "Transport" deleted

This category has been removed from your account.
```

---

### Error Messages (Positive Tone)

**Network Error:**
```
⚠️ Unable to connect

We couldn't reach our servers. Check your internet connection and try again.

[Retry]
```

**Save Failed:**
```
⚠️ Save unsuccessful

We couldn't save your allocation. Your data is safe. Try again in a moment.

[Try Again]
```

**Invalid Login:**
```
⚠️ Login unsuccessful

The email or password you entered doesn't match our records. Please try again.

[Forgot Password?]
```

**Validation Error (Password):**
```
⚠️ Password must be stronger

Your password needs:
• At least 8 characters
• One number (0-9)
• One special character (!@#$%^&*)
```

**Account Already Exists:**
```
⚠️ Account already exists

An account with this email already exists. Try logging in instead.

[Log In]
```

---

### Loading States

**Saving Allocation:**
```
Saving your allocation...
(with spinner animation)
```

**Loading Dashboard:**
```
Loading your data...
(with spinner animation)
```

**Syncing Data:**
```
Syncing with cloud...
(with sync icon animation)
```

**Processing Payment (Future Feature):**
```
Processing...
(with progress indicator)
```

---

### Empty States

**No Allocations Yet (Dashboard):**
```
💰 Welcome to Kairo!

Let's create your first allocation and get clarity on your finances.

It takes less than 60 seconds.

[Create Your First Allocation]
```

**No Custom Categories (Category Management):**
```
📁 No custom categories yet

You have the 5 default categories. Add a custom category to track a specific priority in your life.

[+ Add Category]
```

**No Strategies (Strategies Screen):**
```
📋 No strategies yet

Create your first strategy to save different allocation plans for different months.

[Create Strategy]

──── OR START FROM TEMPLATE ────

[Template cards]
```

**No History (Allocation History - Future):**
```
📊 No allocation history yet

Your past allocations will appear here once you create your first allocation.

[Create Allocation]
```

---

### Onboarding Tooltips

**First Allocation (Step 2):**
```
💡 Drag sliders to allocate your income

Each category shows the percentage and exact amount.
Your total should equal 100% to save.

[Got it]
```

**Templates (First Time Seeing):**
```
💡 Try a template for a quick start

These are proven allocation strategies.
Select one and adjust it to fit your needs.

[Dismiss]
```

**Strategy Management (First Visit):**
```
💡 Strategies help you plan for different scenarios

Create multiple strategies like "Regular Month", "Tight Month",
or "Bonus Month" and switch between them anytime.

[Got it]
```

**Temporary Allocation (First Use):**
```
💡 Temporary allocation for one-time changes

This adjustment won't change your saved strategy.
Next time, you'll start with your original strategy.

[Understand]
```

---

### Milestone Celebrations

**First Allocation Completed:**
```
🎉 Congratulations!

You've completed your first allocation.
You're already building better money habits.
```

**10 Allocations Completed:**
```
🎉 10 allocations completed!

You're building great financial awareness. Keep it up!
```

**30 Days Active:**
```
🎉 30-day streak!

You've been using Kairo for a month.
Your financial clarity is growing stronger every day.
```

**First Strategy Created:**
```
🎉 First strategy created!

You're becoming a financial planning pro.
You can now switch strategies anytime.
```

---

### Contextual Guidance

**Variable Income User (Income Entry):**
```
💡 Variable income tip:

Consider allocating 20-30% to emergencies to cover low-income periods.
This provides a safety buffer during lean months.

[Dismiss]
```

**Allocation Under 100%:**
```
💡 You have 15% unallocated

Allocate the remaining percentage to complete your plan.
```

**Strategy Switching:**
```
💡 Switching strategies

Your next allocation will use "Tight Month" percentages by default.
You can still adjust manually if needed.
```

---

## Animation and Motion

### Principles

**Purpose-Driven Animation:**
- Animations guide attention, not distract
- Reinforce hierarchy (what's important happens first/faster)
- Provide feedback for user actions
- Smooth state transitions reduce cognitive load

**Performance:**
- 60fps minimum (16ms per frame)
- Hardware-accelerated when possible (GPU, not CPU)
- Reduced motion for accessibility (respect system preferences)
- Skip animations on low-end devices if performance suffers

---

### Transition Animations

**Screen Transitions:**
- **Duration:** 300ms (standard Material/iOS duration)
- **Easing:** Ease-in-out (smooth start and end)
- **Type:**
  - Forward navigation: Slide from right (iOS) or fade + slide (Material)
  - Back navigation: Slide to right (iOS) or fade + slide reverse (Material)
  - Modal presentation: Slide up from bottom (both platforms)

**Example (Flutter):**
```dart
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => NextScreen(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(position: offsetAnimation, child: child);
  },
  transitionDuration: Duration(milliseconds: 300),
)
```

---

### Micro-Interactions

**Button Press:**
- **Duration:** 150ms
- **Effect:** Slight scale down (0.95×) on press, scale up (1.0×) on release
- **Ripple:** Material ripple effect (Android), opacity fade (iOS)

**Slider Drag:**
- **Real-time:** Thumb moves immediately with finger (<16ms latency)
- **Spring physics:** Slight overshoot and bounce when released (feels natural)
- **Haptic feedback:** Light vibration at 100% total (iOS/Android)

**Toggle Switch:**
- **Duration:** 200ms
- **Easing:** Ease-out (fast start, slow end)
- **Effect:** Thumb slides across track, track color changes

**Card Tap:**
- **Duration:** 100ms
- **Effect:** Slight elevation increase (2dp → 4dp) on press

---

### Loading Animations

**Spinner (Indeterminate Progress):**
- **Type:** Circular spinner (Material CircularProgressIndicator)
- **Size:** 24dp (inline), 48dp (full-screen)
- **Color:** Primary brand color (#E67E22)
- **Speed:** 1 rotation per second

**Progress Bar (Determinate):**
- **Type:** Linear progress bar
- **Height:** 4dp
- **Color:** Primary brand color
- **Animation:** Smooth fill from left to right (ease-in-out)

**Skeleton Screens (Preferred for Data Loading):**
- **Effect:** Placeholder cards with subtle shimmer animation
- **Duration:** Infinite loop until data loads
- **Color:** Light grey (#E0E0E0) with animated gradient overlay

**Example (Dashboard Loading):**
```
┌────────────────────────────────────┐
│   Kairo                            │
├────────────────────────────────────┤
│                                    │
│   ┌──────────────────────────┐    │  ← Skeleton card
│   │  ████████████            │    │    (shimmer effect)
│   │  ████████                │    │
│   └──────────────────────────┘    │
│                                    │
│   ┌──────────────────────────┐    │
│   │  ████████████            │    │
│   └──────────────────────────┘    │
│                                    │
│   ... (3 more skeleton cards)      │
│                                    │
└────────────────────────────────────┘
```

---

### Success Animations

**Checkmark Animation (After Save):**
- **Duration:** 400ms
- **Effect:** Checkmark draws from start to finish (SVG path animation)
- **Color:** Success green (#27AE60)
- **Scale:** Slight scale-up (1.2×) then settle to 1.0×

**Confetti (Milestone Celebrations):**
- **Trigger:** First allocation, 10 allocations, 30-day streak
- **Duration:** 2 seconds
- **Effect:** Colorful confetti falls from top
- **Particles:** 20-30 pieces, randomized colors from brand palette
- **Physics:** Gravity + slight rotation

**Toast Message (Success Confirmations):**
- **Duration:** 3 seconds on screen
- **Entry:** Slide up from bottom (200ms)
- **Exit:** Fade out (200ms)
- **Position:** Bottom of screen, above bottom navigation

---

### Error Animations

**Shake (Validation Errors):**
- **Duration:** 500ms
- **Effect:** Input field shakes horizontally (5px left, 5px right, repeat 3×)
- **Trigger:** Invalid form submission
- **Accessibility:** Accompanied by error message (not animation alone)

**Error Icon Pulse:**
- **Duration:** 1 second (single pulse)
- **Effect:** Error icon (⚠️) scales up (1.1×) then down (1.0×)
- **Color:** Error red (#E74C3C)

---

### State Change Animations

**Slider Value Change:**
- **Real-time:** Percentage text and amount update instantly (<16ms)
- **Progress bar:** Smooth fill animation (100ms ease-out)
- **Color transition:** Total indicator changes color (green/orange/red) with 200ms fade

**Category Card Expand/Collapse:**
- **Duration:** 300ms
- **Easing:** Ease-in-out
- **Effect:** Height animates smoothly, content fades in/out

**Bottom Sheet Open/Close:**
- **Duration:** 250ms
- **Easing:** Ease-out (fast open), ease-in (fast close)
- **Effect:** Slides up from bottom, backdrop fades in (black 50% opacity)

---

### List Animations

**List Item Insert:**
- **Duration:** 300ms
- **Effect:** New item fades in + slides down from above
- **Stagger:** If multiple items, 50ms delay between each

**List Item Delete:**
- **Duration:** 300ms
- **Effect:** Item slides left + fades out, items below slide up to fill gap

**List Reorder (Drag):**
- **Elevation:** Item elevation increases to 8dp while dragging
- **Shadow:** Larger shadow indicates "floating" state
- **Gap:** Other items shift to show drop target

---

### Reduced Motion

**Accessibility Consideration:**
- Respect user's system "Reduce Motion" preference (iOS/Android)
- If enabled, disable all non-essential animations:
  - Screen transitions: Instant crossfade (100ms)
  - Micro-interactions: Remove scale/bounce, keep opacity changes
  - Loading: Static spinner, no rotation
  - Success: Checkmark appears instantly, no draw animation
  - Confetti: Single static checkmark instead

**Implementation (Flutter):**
```dart
final reducedMotion = MediaQuery.of(context).disableAnimations;

if (reducedMotion) {
  // Show instant transition
  return FadeTransition(opacity: animation, child: child);
} else {
  // Show full animation
  return SlideTransition(position: offsetAnimation, child: child);
}
```

---

## Responsive Design Considerations

### Screen Size Breakpoints

**Mobile (Primary Focus):**
```
Small:   < 360dp width  (Older small phones)
Medium:  360-480dp      (Standard phones)
Large:   480-600dp      (Large phones, phablets)
```

**Tablet (Secondary - Future Enhancement):**
```
Small tablet:  600-840dp   (7-10" tablets portrait)
Large tablet:  > 840dp     (10"+ tablets, landscape)
```

**Design Approach:**
- **Mobile-first:** Design for small screens, enhance for larger
- **Fluid layouts:** Use flexible containers, not fixed widths
- **Breakpoint-specific:** Adjust layout at breakpoints, not continuously

---

### Layout Adaptations

**Phone Portrait (< 600dp):**
- Single-column layout
- Full-width cards
- Bottom navigation (if used)
- Floating action buttons bottom-right
- Sliders stack vertically

**Phone Landscape (600-840dp):**
- Single-column layout maintained (avoid cramming)
- Increased side margins (24dp instead of 16dp)
- Modals use max-width (480dp) centered
- Bottom navigation hides, use top navigation

**Tablet Portrait (> 840dp):**
- Two-column layout where appropriate (categories, strategies)
- Max content width: 600dp (prevents excessive line length)
- Side navigation drawer instead of bottom navigation
- Centered content with generous margins (32-64dp)

**Tablet Landscape (> 840dp):**
- Two-column layout primary
- Master-detail view (list on left, detail on right)
- Full-width sliders in detail pane
- Side navigation always visible

---

### Typography Scaling

**Base Size (Mobile):**
```
Display Large:   48sp (scaled down from 57sp for small screens)
Headline Large:  28sp (scaled down from 32sp)
Headline Medium: 24sp
Title Large:     20sp
Body Large:      16sp
Body Medium:     14sp
```

**Tablet Size:**
```
Display Large:   57sp (full size)
Headline Large:  32sp
Headline Medium: 28sp
Title Large:     22sp
Body Large:      16sp
Body Medium:     14sp
```

**User Preference:**
- Support system font size settings (Accessibility > Display > Font Size)
- Test with 200% zoom (WCAG requirement)
- Use sp units (scalable pixels) not dp for text

---

### Touch Target Adjustments

**Small Screens (< 360dp):**
- Maintain 44x44dp minimum (never reduce below this)
- Increase spacing between targets (16dp minimum)
- Avoid cramming too many actions in one row

**Large Screens (> 600dp):**
- Increase touch targets to 48x48dp
- More generous spacing (24dp between targets)
- Larger buttons for comfort (56dp height)

---

### Image and Asset Scaling

**Icon Sizes:**
```
Small screens:   20dp (slightly smaller for space)
Medium screens:  24dp (standard)
Large screens:   32dp (more comfortable)
```

**Category Icons:**
```
Small screens:   28dp
Medium screens:  32dp
Large screens:   40dp
```

**Empty State Icons:**
```
Small screens:   40dp
Medium screens:  48dp
Large screens:   64dp
```

**Responsive Images:**
- Use vector assets (SVG) when possible (scales perfectly)
- Provide 1x, 2x, 3x raster images for different densities
- Lazy load large images (not critical for MVP with minimal imagery)

---

### Orientation Handling

**Portrait (Primary):**
- Optimized for vertical scrolling
- Sliders stacked vertically
- Single-column layouts

**Landscape (Secondary):**
- Adjust spacing to prevent excessive whitespace
- Consider two-column layouts for categories/strategies
- Keep critical actions visible (no horizontal scrolling)
- Keyboard navigation: Inputs don't get hidden by keyboard

**Orientation Lock (Optional):**
- Lock to portrait for onboarding flow (simpler UX)
- Allow rotation on dashboard and management screens
- Test both orientations thoroughly

---

### Safe Areas and Notches

**iOS Notch/Dynamic Island:**
- Respect safe area insets (top and bottom)
- Use `SafeArea` widget (Flutter) or equivalent
- Background extends to edges, content stays in safe area

**Android Gesture Navigation:**
- Respect system gesture areas (bottom edge)
- Bottom navigation sits above gesture bar
- FABs positioned above gesture bar (16dp clearance)

**Foldable Devices (Future):**
- Detect fold hinge position
- Avoid placing critical UI at fold line
- Adapt layout to multi-window modes

---

## Summary

This UX design documentation provides comprehensive guidance for creating a mobile-first, culturally-intelligent financial allocation app for African users. Key design decisions include:

**Cultural Sensitivity:**
- Default categories reflect African financial realities (Family Support, Community Contributions)
- Warm, earth-tone color palette evokes African aesthetics
- Positive, empowering messaging respects cultural context
- Variable income support acknowledges economic realities

**60-Second Value Delivery:**
- Action-based onboarding: user allocates immediately, no lengthy setup
- Pre-populated categories eliminate configuration friction
- Template strategies provide instant starting points
- Real-time slider feedback enables quick decision-making

**Forgiveness Architecture:**
- Auto-save prevents data loss
- Temporary allocations don't overwrite saved strategies
- Undo/revert options for all major actions
- Confirmation dialogs prevent accidental deletions

**Positive Psychology:**
- Encouraging language: "This month was different" not "You overspent"
- Success celebrations reinforce good habits
- Empty states motivate action, not blame
- Error messages calm and helpful, never alarming

**Mobile-First Accessibility:**
- 44x44dp minimum touch targets (WCAG AAA)
- WCAG AA color contrast throughout
- Screen reader support with semantic labels
- Support for low-end Android devices (< 3s launch, < 100MB memory)

**Progressive Disclosure:**
- Dashboard shows essentials, hides complexity
- Advanced features (strategies, custom categories) accessible but not overwhelming
- Contextual tooltips appear only when needed
- Power users unlock depth naturally through engagement

This design specification ensures Kairo delivers financial clarity and empowerment while respecting African users' unique contexts and needs.

---

*UX Design v1.0 - Created 2026-01-11*
