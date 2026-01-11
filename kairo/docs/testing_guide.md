# Kairo End-to-End Testing Guide

**Purpose:** Test income management flows before production deployment
**Time Required:** 20-30 minutes
**Prerequisites:** Flutter app running, Supabase database deployed

---

## Pre-Testing Checklist

### 1. Environment Setup
- [ ] `.env` file configured with Supabase credentials
- [ ] Database migrations applied to Supabase
- [ ] `flutter pub get` executed successfully
- [ ] No critical compilation errors

### 2. Verify App Starts
```bash
# Clean build
flutter clean
flutter pub get

# Run on Chrome (fastest for testing)
flutter run -d chrome

# Or Windows
flutter run -d windows
```

**Expected:** App launches to login/splash screen

---

## Test Suite 1: User Registration & Auto-Initialization

### Test 1.1: New User Registration
**Path:** Splash → Register Screen

**Steps:**
1. Launch app
2. Click "Sign Up" or "Register"
3. Fill in:
   - Email: `testuser@kairo.app`
   - Full Name: `Test User`
   - Password: `Test123!@#`
   - Confirm Password: `Test123!@#`
4. Click "Create Account"

**Expected Results:**
- ✅ No validation errors
- ✅ "Account created successfully" message
- ✅ Redirected to onboarding or dashboard
- ✅ No console errors

**Database Verification (Supabase Dashboard):**
```sql
-- Check profile created
SELECT * FROM profiles WHERE email = 'testuser@kairo.app';

-- Check default categories created (should be 5)
SELECT name, color, is_default, sort_order
FROM allocation_categories
WHERE user_id = (SELECT id FROM profiles WHERE email = 'testuser@kairo.app')
ORDER BY sort_order;

-- Expected categories:
-- 1. Family Support (#EF4444)
-- 2. Emergencies (#F59E0B)
-- 3. Savings (#10B981)
-- 4. Daily Needs (#3B82F6)
-- 5. Community Contributions (#8B5CF6)

-- Check default strategy created
SELECT * FROM allocation_strategies
WHERE user_id = (SELECT id FROM profiles WHERE email = 'testuser@kairo.app');
-- Expected: "Balanced Allocation", is_active = true
```

**Pass Criteria:**
- [ ] Profile row exists
- [ ] 5 categories created with correct colors
- [ ] 1 strategy created and active
- [ ] 5 strategy allocations (totaling 100%)

---

## Test Suite 2: Income Entry Flow

### Test 2.1: Navigate to Income Entry
**Path:** Dashboard → Income Entry

**Steps:**
1. From dashboard, navigate to `/dashboard/income/new`
   - Or click "Add Income" button if visible

**Expected:**
- ✅ Income entry form displayed
- ✅ All form fields visible
- ✅ Currency selector shows KES, NGN, GHS, ZAR, USD
- ✅ Income type buttons: Fixed, Variable, Mixed
- ✅ Income source chips visible

---

### Test 2.2: Add First Income (Valid Data)
**Path:** Income Entry Form

**Test Data:**
```
Amount: 50000
Currency: KES
Date: Today
Income Type: Variable
Income Source: Gig Income
Description: Freelance web development project
```

**Steps:**
1. Enter amount: `50000`
2. Select currency: `KES`
3. Select date: Today (default)
4. Click income type: `Variable`
5. Click income source: `Gig Income`
6. Enter description: `Freelance web development project`
7. Click "Add Income"

**Expected Results:**
- ✅ Form validates successfully
- ✅ "Income added successfully" message appears
- ✅ Redirected to dashboard or income history
- ✅ Auto-save status showed "Saving..." then "Saved"

**Database Verification:**
```sql
SELECT * FROM income_entries
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'testuser@kairo.app')
ORDER BY created_at DESC
LIMIT 1;

-- Expected:
-- amount: 50000.00
-- currency: KES
-- income_type: variable
-- income_source: gigIncome
-- description: Freelance web development project
```

**Pass Criteria:**
- [ ] Entry saved to database
- [ ] All fields match input
- [ ] created_at timestamp set
- [ ] No validation errors

---

### Test 2.3: Add Second Income (Different Source)
**Test Data:**
```
Amount: 75000
Currency: KES
Date: Yesterday
Income Type: Fixed
Income Source: Formal Salary
Description: Monthly salary - January
```

**Expected:**
- ✅ Second entry created
- ✅ Different type/source displayed correctly
- ✅ Total income now KSh 125,000

---

### Test 2.4: Validation Testing
**Purpose:** Test form validation

**Test Cases:**

| Test | Input | Expected Result |
|------|-------|-----------------|
| Empty amount | Amount: `` | ❌ "Please enter an amount" |
| Zero amount | Amount: `0` | ❌ "Please enter a valid amount greater than 0" |
| Negative amount | Amount: `-100` | ❌ Prevented by input formatter |
| Future date | Date: Tomorrow | Should allow (or validate based on requirement) |
| No type selected | Type: None | ✅ Default to Variable |
| No source selected | Source: None | ✅ Allow (optional field) |

**Pass Criteria:**
- [ ] All validation messages clear and helpful
- [ ] Cannot submit invalid data
- [ ] Positive, non-judgmental error messages

---

## Test Suite 3: Income History Flow

### Test 3.1: View Income History
**Path:** Dashboard → Income History

**Steps:**
1. Navigate to `/dashboard/income/history`

**Expected Results:**
- ✅ Income history screen displayed
- ✅ Summary card shows: "2 Entries, KSh 125,000.00"
- ✅ Both income entries visible in list
- ✅ Sorted by date (newest first)
- ✅ Each entry shows:
  - Amount with currency symbol
  - Date formatted correctly
  - Type chip (color-coded: Variable=Orange, Fixed=Blue)
  - Source chip
  - Description

**Visual Checks:**
- [ ] Gig Income entry: Orange "Variable" chip
- [ ] Formal Salary entry: Blue "Fixed" chip
- [ ] Amounts formatted with commas: "KSh 50,000.00"
- [ ] Dates readable: "January 11, 2026"

---

### Test 3.2: Filter by Income Type
**Steps:**
1. Click filter icon (top-right)
2. Select "Variable" only
3. Click "Apply"

**Expected:**
- ✅ Only 1 entry shown (Gig Income)
- ✅ Summary updates: "1 Entry, KSh 50,000.00"

**Steps:**
4. Open filter again
5. Select "Fixed" only
6. Click "Apply"

**Expected:**
- ✅ Only 1 entry shown (Formal Salary)
- ✅ Summary updates: "1 Entry, KSh 75,000.00"

**Steps:**
7. Open filter
8. Click "Clear All"

**Expected:**
- ✅ Both entries shown again
- ✅ Summary back to: "2 Entries, KSh 125,000.00"

---

### Test 3.3: Filter by Income Source
**Steps:**
1. Click filter icon
2. Select "Gig Income" source
3. Click "Apply"

**Expected:**
- ✅ Only Gig Income entry shown
- ✅ Summary correct

---

### Test 3.4: Pull to Refresh
**Steps:**
1. Pull down on income list (or use refresh gesture)

**Expected:**
- ✅ Loading indicator appears
- ✅ List refreshes
- ✅ Data still displayed correctly

---

## Test Suite 4: Income Edit Flow

### Test 4.1: Edit Income Entry
**Path:** Income History → Edit

**Steps:**
1. Find the Gig Income entry (KSh 50,000)
2. Click three-dot menu (⋮)
3. Click "Edit"

**Expected:**
- ✅ Income entry screen opens
- ✅ All fields pre-filled with existing data
- ✅ Title shows "Edit Income"

**Steps:**
4. Change amount to: `60000`
5. Change description to: `Freelance project - updated rate`
6. Click "Update Income"

**Expected Results:**
- ✅ "Income updated successfully" message
- ✅ Navigated back to history
- ✅ Entry shows new amount: KSh 60,000.00
- ✅ Summary updated: "2 Entries, KSh 135,000.00"

**Database Verification:**
```sql
SELECT amount, description, updated_at
FROM income_entries
WHERE id = 'ENTRY_ID';

-- Expected:
-- amount: 60000.00
-- description: Freelance project - updated rate
-- updated_at: [recent timestamp]
```

**Pass Criteria:**
- [ ] Changes saved correctly
- [ ] updated_at timestamp changed
- [ ] UI reflects changes immediately

---

## Test Suite 5: Income Delete Flow

### Test 5.1: Delete Income Entry
**Path:** Income History → Delete

**Steps:**
1. Find any income entry
2. Click three-dot menu (⋮)
3. Click "Delete"

**Expected:**
- ✅ Confirmation dialog appears
- ✅ Message shows amount being deleted
- ✅ Example: "Are you sure you want to delete this income entry of KSh 60,000.00?"

**Steps:**
4. Click "Cancel"

**Expected:**
- ✅ Dialog closes
- ✅ Entry still in list (not deleted)

**Steps:**
5. Click three-dot menu again
6. Click "Delete"
7. Click "Delete" (confirm)

**Expected Results:**
- ✅ "Income entry deleted" message
- ✅ Entry removed from list
- ✅ Summary updated (1 entry, KSh 75,000 remaining)
- ✅ No errors

**Database Verification:**
```sql
SELECT * FROM income_entries
WHERE id = 'DELETED_ENTRY_ID';

-- Expected: Either
-- 1. Row deleted (hard delete)
-- 2. is_deleted = true (soft delete)
```

**Pass Criteria:**
- [ ] Entry removed from UI
- [ ] Database updated
- [ ] Summary recalculated
- [ ] Smooth UX (no flash/errors)

---

### Test 5.2: Delete All Entries (Empty State)
**Steps:**
1. Delete remaining income entry
2. Confirm deletion

**Expected:**
- ✅ Empty state displayed
- ✅ Icon shown (wallet or similar)
- ✅ Message: "No income entries yet"
- ✅ Helpful subtext: "Track your income to see your allocation insights"
- ✅ "Add Your First Income" button visible

**Steps:**
3. Click "Add Your First Income"

**Expected:**
- ✅ Navigated to income entry form
- ✅ Ready to add new income

---

## Test Suite 6: Multi-Currency Testing

### Test 6.1: Different Currencies
**Purpose:** Test currency handling

**Test Data:**
Add 3 entries with different currencies:

| Amount | Currency | Type | Source |
|--------|----------|------|--------|
| 5000 | USD | Fixed | Formal Salary |
| 200000 | NGN | Variable | Gig Income |
| 15000 | ZAR | Mixed | Cash |

**Expected:**
- ✅ All entries display with correct currency symbols
- ✅ USD: $ 5,000.00
- ✅ NGN: ₦200,000.00
- ✅ ZAR: R 15,000.00

**Note:** Summary might show mixed currencies - this is expected behavior

---

## Test Suite 7: Edge Cases & Error Handling

### Test 7.1: Network Error Simulation
**Steps:**
1. Disconnect internet
2. Try to add income entry
3. Click "Add Income"

**Expected:**
- ✅ Error message displayed
- ✅ Message is helpful: "No internet connection. Please check your network and try again."
- ✅ Can retry when connection restored

---

### Test 7.2: Large Numbers
**Test Data:**
```
Amount: 999999999.99
```

**Expected:**
- ✅ Handles large amounts
- ✅ Formats correctly with commas
- ✅ No overflow errors

---

### Test 7.3: Decimal Precision
**Test Data:**
```
Amount: 12345.67
```

**Expected:**
- ✅ Saves with 2 decimal places
- ✅ Displays as "KSh 12,345.67"

---

### Test 7.4: Special Characters in Description
**Test Data:**
```
Description: Project #1 - Client's "special" request (50% upfront)
```

**Expected:**
- ✅ Special characters accepted
- ✅ No SQL injection issues
- ✅ Displays correctly

---

## Test Suite 8: Performance Testing

### Test 8.1: Load Time
**Metrics to Track:**
- [ ] App launch time: < 5 seconds
- [ ] Income history load: < 2 seconds
- [ ] Income entry form load: < 1 second
- [ ] Save operation: < 1 second

### Test 8.2: Many Entries
**Steps:**
1. Add 20+ income entries
2. Navigate to history

**Expected:**
- ✅ List scrolls smoothly
- ✅ Summary calculates correctly
- ✅ No lag or stuttering

---

## Test Suite 9: Integration Testing

### Test 9.1: Login Persistence
**Steps:**
1. Add income entry
2. Close app completely
3. Reopen app

**Expected:**
- ✅ Still logged in
- ✅ Income history shows saved entries
- ✅ No need to re-login

### Test 9.2: Multiple Sessions
**Steps:**
1. Login on Chrome
2. Add income entry
3. Logout
4. Login on Windows app
5. Check income history

**Expected:**
- ✅ Income entry visible on both platforms
- ✅ Data synced via Supabase

---

## Bug Reporting Template

If you find issues, document them:

```markdown
### Bug: [Brief Description]

**Severity:** Critical / High / Medium / Low

**Steps to Reproduce:**
1.
2.
3.

**Expected Behavior:**


**Actual Behavior:**


**Screenshots/Logs:**


**Environment:**
- OS:
- Browser/Device:
- Flutter version:
- Supabase status:
```

---

## Test Results Checklist

### Core Functionality
- [ ] User registration works
- [ ] Auto-initialization creates defaults
- [ ] Can add income entries
- [ ] Can view income history
- [ ] Can edit income entries
- [ ] Can delete income entries
- [ ] Filters work correctly
- [ ] Summary calculates accurately

### User Experience
- [ ] Navigation is smooth
- [ ] Error messages are helpful
- [ ] Loading states are clear
- [ ] Empty states are friendly
- [ ] Forms are intuitive

### Data Integrity
- [ ] All fields save correctly
- [ ] Timestamps are accurate
- [ ] Currency formatting correct
- [ ] Database constraints enforced

### Performance
- [ ] Loads quickly (< 5s)
- [ ] No lag or stuttering
- [ ] Handles many entries
- [ ] Network errors handled gracefully

---

## Success Criteria

**Minimum Passing Grade:** 90% of tests pass

**Critical Tests (Must Pass):**
- ✅ User registration
- ✅ Add income entry
- ✅ View income history
- ✅ Edit income entry
- ✅ Delete income entry

**Optional Tests (Nice to Have):**
- Filters working perfectly
- Multi-currency handling
- Performance optimizations

---

## Next Steps After Testing

### If All Tests Pass ✅
1. Document any minor issues
2. Proceed with Phase 2 features
3. Consider beta testing with real users

### If Critical Tests Fail ❌
1. Fix blocking issues first
2. Re-run failed tests
3. Update code and re-test

### If 50-90% Tests Pass ⚠️
1. Prioritize fixes by severity
2. Fix high/critical issues
3. Document known issues
4. Continue development with caution

---

**Happy Testing!** 🧪✅

*Testing Guide v1.0 - Generated 2026-01-11*
