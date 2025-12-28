# Run to Canada - Development Trackers

This folder contains tracking documents for managing the development of the Run to Canada mobile application.

---

## Tracker Files

### 📝 [Session_log.md](./Session_log.md)
**Purpose:** Track all development sessions

**What it contains:**
- Session entries with date, duration, participants
- Sprint reference for each session
- Objectives and work completed
- Files modified during the session
- Issues encountered and resolutions
- Next steps

**When to update:**
- At the start of each development session
- When completing a major milestone
- At the end of each work day

**Example use case:**
> You just finished implementing Firebase authentication (Sprint 2). Log this in Session_log.md with details about what files were created, any issues encountered, and what's next.

---

### 📊 [Change_log.md](./Change_log.md)
**Purpose:** Track all changes made to the project

**What it contains:**
- Changes organized by session
- Changes organized by sprint
- Changes organized by type (Feature, Bug Fix, Configuration, etc.)
- Detailed change descriptions with file counts

**When to update:**
- After completing any sprint task
- When implementing features
- When fixing bugs
- When updating documentation or configuration

**Example use case:**
> You added GPS tracking functionality in Sprint 4. Add an entry showing which files were created/modified and link to the session where this was done.

---

### 🐛 [Bug_tracker.md](./Bug_tracker.md)
**Purpose:** Track bugs and their resolution status

**What it contains:**
- Open bugs awaiting fixes
- Bugs currently being worked on
- Fixed bugs awaiting verification
- Closed (verified) bugs
- Bugs organized by priority (Critical, High, Medium, Low)
- Bugs organized by sprint and component

**When to update:**
- When discovering a new bug
- When starting to work on a bug
- When fixing a bug
- When verifying a bug fix

**Example use case:**
> During testing, you notice GPS tracking stops after 5 minutes. Create a bug entry (BUG-001) with priority High, steps to reproduce, and assign it for fixing.

---

### 📋 [Backlog_tracker.md](./Backlog_tracker.md)
**Purpose:** Track future enhancements and technical debt

**What it contains:**
- Technical debt items that need addressing
- Future enhancement ideas for post-MVP
- Nice-to-have features
- Items organized by priority and target version
- Effort estimates for planning

**When to update:**
- When identifying technical debt during development
- When planning future features
- When users request features
- During roadmap planning sessions

**Example use case:**
> Users are requesting social features (friends, sharing). Add this as FE-001 (Future Enhancement) targeting v1.1, with High priority.

---

## Tracker Workflow

### Daily Development Workflow

```
1. Start Development Session
   ↓
   Create new session entry in Session_log.md

2. Work on Sprint Tasks
   ↓
   Reference sprint plan (docs/03-sprint-plan.md)

3. Make Changes
   ↓
   Track changes in Change_log.md as you go

4. Encounter Bug?
   ↓
   Log in Bug_tracker.md with details

5. New Feature Ideas?
   ↓
   Add to Backlog_tracker.md

6. End Session
   ↓
   Update Session_log.md with summary and next steps
```

---

## Tracker Conventions

### ID Formats

- **Session:** Session XXX (e.g., Session 001, Session 002)
- **Bug:** BUG-XXX (e.g., BUG-001, BUG-002)
- **Tech Debt:** TD-XXX (e.g., TD-001, TD-002)
- **Future Enhancement:** FE-XXX (e.g., FE-001, FE-002)
- **Nice to Have:** NTH-XXX (e.g., NTH-001, NTH-002)

### Priority Levels

**Critical / High / Medium / Low**

- **Critical:** System down, data loss, security issue
- **High:** Major feature broken, significant user impact
- **Medium:** Feature partially broken, workaround exists
- **Low:** Minor issue, cosmetic, edge case

### Status Values

**Bugs:**
- Open
- In Progress
- Fixed
- Closed

**Enhancements:**
- Planned
- In Progress
- Completed
- Deferred

---

## How to Use These Trackers

### For Solo Developer

1. **Start each session:** Add entry to Session_log.md
2. **Track changes:** Update Change_log.md after completing tasks
3. **Log bugs immediately:** Don't rely on memory, log in Bug_tracker.md
4. **Capture ideas:** Add feature ideas to Backlog_tracker.md as they come up
5. **Weekly review:** Review all trackers, update priorities

### For Team Development

1. **Session log:** Each developer logs their sessions
2. **Change log:** Team reviews changes during standups
3. **Bug tracker:** Team triages bugs by priority
4. **Backlog:** Team discusses and prioritizes during sprint planning

### Integration with Sprint Plan

The trackers complement [03-sprint-plan.md](../03-sprint-plan.md):

- **Sprint Plan:** What needs to be done (checkable tasks)
- **Session Log:** When and how it was done
- **Change Log:** What actually changed
- **Bug Tracker:** Issues discovered
- **Backlog:** What to do next (future work)

---

## Quick Reference

### Adding a Session Entry

```markdown
### Session XXX - YYYY-MM-DD

**Sprint:** Sprint X - Sprint Name
**Duration:** X hours
**Participants:** Your Name

**Objectives:**
- Objective 1
- Objective 2

**Work Completed:**
- Task 1 ✅
- Task 2 ✅

**Files Modified:**
- Created: `path/to/file.dart` - Description
- Modified: `path/to/file.dart` - Changes

**Issues Encountered:**
- Issue description and resolution

**Next Steps:**
- Next task 1
- Next task 2
```

### Adding a Bug Entry

```markdown
**BUG-XXX: Brief description**

| Bug ID | Priority | Sprint | Component | Description | Discovered | Reference |
|--------|----------|--------|-----------|-------------|------------|-----------|
| BUG-XXX | High | Sprint X | Component | Details... | YYYY-MM-DD | Session XXX |
```

### Adding a Change Entry

```markdown
| Session | Date | Sprint | Files Changed | Type | Description | Reference |
|---------|------|--------|---------------|------|-------------|-----------|
| XXX | YYYY-MM-DD | Sprint X | N files | Feature | Description | [Session XXX] |
```

### Adding a Backlog Item

```markdown
| ID | Priority | Category | Description | Sprint Target | Added | Reference |
|----|----------|----------|-------------|---------------|-------|-----------|
| FE-XXX | High | Social | Description | v1.1 | YYYY-MM-DD | Source |
```

---

## Tracker Maintenance

### Daily
- ✅ Update Session_log.md at start and end of session
- ✅ Update Change_log.md as you make changes
- ✅ Log bugs immediately when discovered

### Weekly
- 🔄 Review open bugs and update priorities
- 🔄 Update bug statuses (In Progress → Fixed → Closed)
- 🔄 Review session log entries for completeness

### Monthly
- 📊 Generate summary reports from trackers
- 📊 Review backlog and reprioritize
- 📊 Archive closed bugs and completed enhancements
- 📊 Update sprint completion metrics

---

## Benefits of Using Trackers

### For Development
- ✅ Clear history of what was done and when
- ✅ Easy to track progress across sprints
- ✅ Helps onboard new developers
- ✅ Provides context for code reviews

### For Project Management
- ✅ Visibility into development progress
- ✅ Identify blockers and issues early
- ✅ Track velocity and estimate timelines
- ✅ Plan sprints based on historical data

### For Quality Assurance
- ✅ Comprehensive bug tracking
- ✅ Verify all bugs are fixed
- ✅ Regression testing based on bug history
- ✅ Track quality metrics over time

### For Future You
- ✅ Remember why decisions were made
- ✅ Understand what was tried and didn't work
- ✅ Reference solutions to similar problems
- ✅ Learn from past mistakes

---

## Tips for Effective Tracking

1. **Be Consistent:** Update trackers regularly, don't batch updates
2. **Be Specific:** Provide enough detail to be useful later
3. **Link Everything:** Cross-reference between trackers
4. **Stay Current:** Update statuses as work progresses
5. **Review Regularly:** Weekly reviews keep trackers accurate
6. **Don't Overthink:** Quick updates are better than perfect documentation

---

## Tracker Statistics (Current)

| Tracker | Total Entries | Last Updated |
|---------|--------------|--------------|
| Session Log | 1 | 2025-12-28 |
| Change Log | 2 | 2025-12-28 |
| Bug Tracker | 0 | 2025-12-28 |
| Backlog | 12 | 2025-12-28 |

---

## Questions?

If you're unsure about how to use these trackers:

1. **Look at examples:** Review the Classly project trackers for reference
2. **Start simple:** Don't worry about perfection, just start logging
3. **Iterate:** Improve your tracking process over time
4. **Ask:** Reach out to the team if you need clarification

---

**Remember:** These trackers are tools to help you, not add burden. Use them in a way that makes sense for your workflow!

---

**Last Updated:** 2025-12-28
**Created By:** Development Team
**Status:** Ready for Use
