# PR Consolidation Plan

## Strategy

Based on the PR review, we have 20 performance optimization PRs that need consolidation. Most focus on optimizing `OnTick()` with new bar checks.

## Phase 1: Review Top Priority PRs

### PR #78: Optimize MTF Confirmation with Caching ⭐ HIGHEST PRIORITY
- **Type:** Caching optimization
- **Impact:** High - Reduces redundant MTF calculations
- **Status:** Ready for review
- **Action:** Review and merge first (most comprehensive)

### PR #76: Add early exit to OnTick
- **Type:** Early exit optimization
- **Impact:** Medium-High
- **Status:** Ready for review
- **Action:** Review after PR #78

### PR #75: Optimize OnTick by checking for new bar before CopyRates
- **Type:** New bar check + CopyRates optimization
- **Impact:** High - Prevents unnecessary CopyRates calls
- **Status:** Ready for review
- **Action:** Review and potentially merge with PR #76

## Phase 2: Consolidate Duplicate PRs

### Group 1: New Bar Check PRs (12+ PRs)
These PRs all add new bar checks to OnTick():
- PR #74, #73, #72, #71, #70, #69, #65, #62, #58, #57, #56, #54, #52

**Strategy:**
1. Review PR #75 (most comprehensive - includes CopyRates optimization)
2. If PR #75 is good, merge it
3. Close remaining duplicates with comment: "Merged via PR #75"

### Group 2: Early Exit PRs (5+ PRs)
- PR #76, #65, #56, #54

**Strategy:**
1. Review PR #76 (most recent, ready)
2. Merge if comprehensive
3. Close duplicates

### Group 3: Draft PRs (5 PRs)
- PR #81, #80, #79, #64, #63

**Strategy:**
1. Check if they're duplicates of ready PRs
2. If duplicate, close with reference to merged PR
3. If unique, complete draft or close

## Phase 3: Review Feature PRs

### PR #67: Automate Exness demo session
- **Type:** Feature
- **Status:** WIP
- **Action:** Review and complete or close

### PR #77: [WIP] n/a
- **Type:** Unknown
- **Status:** WIP
- **Action:** Determine purpose or close

## Implementation Steps

### Step 1: Review PR #78 (MTF Caching)
```bash
gh pr checkout 78
# Review changes
# Test if possible
# Merge if good
```

### Step 2: Review PR #76 (Early Exit)
```bash
gh pr checkout 76
# Review changes
# Check compatibility with PR #78
# Merge if compatible
```

### Step 3: Review PR #75 (New Bar Check + CopyRates)
```bash
gh pr checkout 75
# Review changes
# Check if it includes PR #76 functionality
# Merge if comprehensive
```

### Step 4: Close Duplicates
After merging best implementations, close duplicates:
```bash
# Close duplicates with comment
gh pr close <pr_number> --comment "Merged via PR #<merged_pr_number>"
```

### Step 5: Handle Draft PRs
```bash
# Review each draft PR
# Close if duplicate
# Complete if unique and valuable
```

## Expected Outcome

- **Merged:** 2-3 best optimization PRs
- **Closed:** 17-18 duplicate PRs
- **Result:** Clean PR list with best optimizations merged

## Testing After Merge

1. Test EA in Strategy Tester
2. Verify performance improvements
3. Check for any regressions
4. Monitor in demo/live if possible

## Timeline

- **Day 1:** Review and merge PR #78, #76, #75
- **Day 2:** Close duplicates
- **Day 3:** Handle draft PRs and feature PRs

---

*Last Updated: 2026-01-10*
