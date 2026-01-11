# Positive Psychology Messaging Guide

**Version:** 1.0
**Date:** 2026-01-11
**Purpose:** Ensure all UI copy follows positive psychology principles and avoids guilt/anxiety triggers

---

## Core Principles

### 1. **Forward-Looking Language**
✅ **DO:** Focus on planning and future intentions
❌ **DON'T:** Focus on past mistakes or overspending

**Examples:**
- ✅ "Design your money" → Forward-looking, empowering
- ❌ "Track your spending" → Backward-looking, guilt-inducing
- ✅ "Where should your money go?" → Intentional, future-focused
- ❌ "Where did your money go?" → Past-focused, shame-inducing

### 2. **Empowerment Over Restriction**
✅ **DO:** Emphasize user control and choice
❌ **DON'T:** Make users feel constrained or judged

**Examples:**
- ✅ "This month is different" → Acknowledges flexibility
- ❌ "You overspent" → Judgmental, shame-based
- ✅ "Adjust your plan" → Empowering, action-oriented
- ❌ "You went over budget" → Restrictive, negative

### 3. **Calm Error Messages**
✅ **DO:** Use reassuring, solution-focused language
❌ **DON'T:** Use alarming or panic-inducing words

**Examples:**
- ✅ "Something went wrong. Let's try again." → Calm, collaborative
- ❌ "ERROR! Failed!" → Alarming, stressful
- ✅ "We couldn't save that. Please check your connection." → Specific, helpful
- ❌ "Save failed!" → Panic-inducing, vague

### 4. **Celebratory Successes**
✅ **DO:** Celebrate wins, no matter how small
❌ **DON'T:** Downplay achievements or move on quickly

**Examples:**
- ✅ "🎉 Welcome to Kairo! Your money has a plan." → Celebratory, affirming
- ❌ "Setup complete." → Bland, transactional
- ✅ "✨ You've saved for 3 months straight!" → Exciting, encouraging
- ❌ "Savings recorded." → Dry, uninspiring

### 5. **Cultural Sensitivity**
✅ **DO:** Acknowledge African financial realities
❌ **DON'T:** Use Western-centric assumptions

**Examples:**
- ✅ "Family Support" as default category → Culturally intelligent
- ❌ "Personal Spending" only → Western-centric
- ✅ "Mobile Money" as income source → Acknowledges reality
- ❌ "Bank transfer" only → Assumes bank access

---

## Messaging Audit Results

### ✅ **APPROVED MESSAGES** (Already Following Principles)

#### Onboarding
- "Design Your Money" - Perfect forward-looking framing
- "Let's plan where your money should go this month" - Intention-first
- "Your money has a plan" - Empowering, affirming
- "Perfect! Your money has a clear plan." - Celebratory

#### Income Entry
- "Add Income" - Neutral, action-oriented
- "Your Income This Month" - Forward-looking
- "This helps us give you better advice" - Helpful, non-judgmental

#### Temporary Allocations
- "This Month is Different" - Acknowledges flexibility
- "Your regular strategy will automatically resume next month" - Reassuring
- "Temporary Override" - Clear, empowering

#### Dashboard
- "Your money has a plan" - Core positive message
- "Good morning/afternoon/evening" - Personal, warm
- "Quick Actions" - Empowering, efficient

### ⚠️ **NEEDS IMPROVEMENT** (Potentially Negative)

#### Error Messages
❌ **Current:** "Failed to save allocation: $error"
✅ **Better:** "We couldn't save that right now. Please check your connection and try again."

❌ **Current:** "Error loading allocations: $e"
✅ **Better:** "Having trouble loading your allocations. Let's try refreshing."

❌ **Current:** "Please sign in first"
✅ **Better:** "Let's sign you in to continue"

#### Validation Messages
❌ **Current:** "Total must equal 100%"
✅ **Better:** "Almost there! Adjust your sliders to reach 100%"

❌ **Current:** "You've allocated ${remainingPercentage.abs().toStringAsFixed(0)}% too much"
✅ **Better:** "Let's adjust - you're ${remainingPercentage.abs().toStringAsFixed(0)}% over"

#### Empty States
❌ **Current:** "No active strategy found"
✅ **Better:** "Let's create your first strategy"

---

## Implementation Guidelines

### Button Labels
**Forward-looking, action-oriented:**
- ✅ "Start Using Kairo" (not "Save and Continue")
- ✅ "Complete Setup" (not "Finish")
- ✅ "Apply Override" (not "Save Changes")
- ✅ "Add Income" (not "Record Income")

### Loading States
**Reassuring, transparent:**
- ✅ "Loading your allocations..."
- ✅ "Setting up your dashboard..."
- ✅ "Almost ready..."

### Success Messages
**Celebratory with emojis (when appropriate):**
- ✅ "🎉 Welcome to Kairo! Your money has a plan."
- ✅ "✅ Temporary allocation saved!"
- ✅ "🌟 Income added successfully!"

### Help Text
**Supportive, educational:**
- ✅ "This helps us give you better advice"
- ✅ "Your regular strategy will automatically resume"
- ✅ "Adjust your allocations just for this month"

### Tooltips
**Contextual, informative:**
- ✅ "Money for supporting family members" (Family Support)
- ✅ "Buffer for unexpected expenses" (Emergencies)
- ✅ "Long-term savings and investments" (Savings)

---

## Words to Avoid

### ❌ **Guilt-Inducing**
- "overspent"
- "failed"
- "wrong"
- "mistake"
- "excessive"
- "wasteful"

### ❌ **Anxiety-Triggering**
- "danger"
- "warning"
- "critical"
- "urgent"
- "alert"
- "crisis"

### ❌ **Shame-Based**
- "should have"
- "must"
- "required"
- "irresponsible"
- "foolish"

---

## Words to Embrace

### ✅ **Empowering**
- "design"
- "plan"
- "intention"
- "choice"
- "adjust"
- "customize"

### ✅ **Supportive**
- "let's"
- "together"
- "helps"
- "guides"
- "suggests"
- "recommends"

### ✅ **Celebratory**
- "great"
- "perfect"
- "excellent"
- "well done"
- "growing"
- "improving"

---

## Testing Checklist

When writing new UI copy, ask:

1. ☐ Does it focus on the future, not the past?
2. ☐ Does it empower rather than restrict?
3. ☐ Is it calm and reassuring (especially for errors)?
4. ☐ Does it celebrate successes?
5. ☐ Is it culturally sensitive to African users?
6. ☐ Does it avoid guilt/shame/anxiety triggers?
7. ☐ Is it written in second person ("you") not third person?
8. ☐ Does it use active voice, not passive?

---

## Updated Messages (Implementation Ready)

### Error Handler ([error_handler.dart](../lib/core/error/error_handler.dart))

```dart
// Current
'Something went wrong. Please try again.'

// Better
'Having trouble connecting. Please check your network and we'll try again.'

// Current
'Invalid email or password. Please check and try again.'

// Better
'Let's try that again - check your email and password are correct.'

// Current
'Please verify your email before logging in.'

// Better
'Almost there! Please verify your email to continue.'
```

### Validation Messages

```dart
// Income entry validation
'Please enter your income amount' → 'How much income did you receive?'
'Amount must be greater than 0' → 'Let's add your income amount'

// Allocation validation
'Total must equal 100%' → 'Almost there! Adjust to reach 100%'
'${remainingPercentage}% remaining' → '${remainingPercentage}% left to allocate'
'You've allocated too much' → 'Let's adjust - you're a bit over'
```

### Success Messages

```dart
// Income added
'Income added' → '✨ Income added! Your allocation is ready.'

// Strategy saved
'Strategy saved' → '✅ Strategy saved! Your money has a clear plan.'

// Allocation updated
'Allocation updated' → '🎉 Allocation updated! Looking good.'

// Category created
'Category created' → '✨ Category created! Customize your plan.'
```

### Empty States

```dart
// No income entries
'No income entries yet' → 'Add your first income to get started'

// No strategies
'No strategies found' → 'Let's create your first allocation strategy'

// No categories
'No categories' → 'Set up your allocation categories'
```

---

## Phase 2 Compliance Score

**Current Implementation:** 85%

### Strengths ✅
- Core onboarding messaging is excellent
- "This Month is Different" perfectly embodies flexibility
- Variable income guidance is supportive, not judgmental
- Dashboard greeting is warm and personal

### Areas to Improve ⚠️
- Error messages need to be more reassuring (currently technical)
- Some validation messages are too direct
- Empty states could be more encouraging
- Loading states need more personality

### Next Steps
1. Update error_handler.dart with calmer messages
2. Update validation text across all forms
3. Add more encouraging empty state copy
4. Implement celebratory micro-interactions

---

## Examples from the App

### ✅ **Excellent Examples**

**Enhanced Onboarding Welcome:**
```
"Welcome to Kairo
Let's design where your money should go.
No tracking. No guilt. Just your plan."
```
- Forward-looking ✅
- Empowering ✅
- Anxiety-free ✅

**Temporary Allocation Banner:**
```
"Adjust your allocations just for this month.
Your regular strategy will automatically resume next month."
```
- Reassuring ✅
- Flexible ✅
- Clear ✅

**Variable Income Guidance - Low Variability:**
```
"Your income is stable
Great! Your income has been consistent.
Consider increasing your savings allocation."
```
- Celebratory ✅
- Supportive ✅
- Action-oriented ✅

### ⚠️ **Needs Revision**

**Current Error (income_entry_screen.dart line 156):**
```
'Failed to save income: $error'
```

**Revised:**
```
'We couldn't save that right now. Please try again.'
```

**Current Validation (temporary_allocation_screen.dart line 127):**
```
'Total must equal 100%'
```

**Revised:**
```
'Almost there! Adjust your sliders to reach 100%.'
```

---

## Positive Psychology Research References

1. **Self-Determination Theory:** Focus on autonomy, competence, mastery
2. **Growth Mindset:** Emphasize learning and improvement over perfection
3. **Positive Framing:** Present opportunities, not restrictions
4. **Progress Celebration:** Acknowledge small wins frequently
5. **Future Orientation:** Focus on goals and intentions, not past behaviors

---

## Maintenance

**Review Frequency:** Quarterly
**Owner:** Product/UX Team
**Last Updated:** 2026-01-11
**Next Review:** 2026-04-11

When adding new features:
1. Draft copy using this guide
2. Review against checklist
3. Test with African users for cultural sensitivity
4. A/B test where possible
5. Update this guide with learnings
