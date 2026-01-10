# Backlog Tracker

This document tracks technical debt, future enhancements, and backlog items for the Run to Canada project.

## Backlog Summary

| Category | Count |
|----------|-------|
| Tech Debt | 2 |
| Future Enhancements | 9 |
| Nice to Have | 4 |
| **Total** | **15** |

---

## Technical Debt

Technical debt items that need to be addressed for code quality, performance, or maintainability.

| ID | Priority | Component | Description | Impact | Effort | Added | Reference | Status |
|----|----------|-----------|-------------|--------|--------|-------|-----------|--------|
| TD-001 | Low | Storage | Add Hive encryption for user-scoped boxes | Unencrypted local data accessible on rooted/jailbroken devices | Medium | 2026-01-09 | Session 22 multi-user fix | Open |
| TD-002 | Low | Data Access | Remove redundant userId filtering in datasources | Box already user-scoped, filtering adds unnecessary overhead | Small | 2026-01-09 | Session 22 multi-user fix | Open |
| ~~TD-003~~ | ~~Low~~ | ~~Architecture~~ | ~~Implement lazy datasource initialization~~ | ~~Datasources created before login could cause StateError~~ | ~~Small~~ | ~~2026-01-09~~ | ~~Session 22 multi-user fix~~ | **✅ COMPLETE** (Session 23) |

---

## Future Enhancements

Planned features and enhancements for future sprints or post-MVP releases.

### Planned for Post-MVP (v1.1+)

| ID | Priority | Category | Description | Sprint Target | Added | Reference |
|----|----------|----------|-------------|---------------|-------|-----------|
| FE-001 | High | Social | Friends & Following - Add/follow friends, see their journey progress, compare achievements | v1.1 | 2025-12-28 | Product concept |
| FE-002 | High | Social | Share Journey Progress - Share milestone achievements, journey maps on social media with beautiful graphics | v1.1 | 2025-12-28 | Product concept |
| FE-003 | High | Goals | Multiple Active Goals - Allow users to track multiple concurrent journeys (Premium feature) | v1.1 | 2025-12-28 | Product concept |
| FE-004 | Medium | Social | Community Challenges - "1000 people running to Tokyo together" group challenges | v1.2 | 2025-12-28 | Product concept |
| FE-005 | Medium | Goals | Premium Route Packs - Curated famous routes (Route 66, Pacific Coast, Silk Road, etc.) | v1.2 | 2025-12-28 | Product concept |
| FE-006 | Medium | Integration | Fitness App Integration - Sync with Apple Health, Google Fit, Strava | v1.2 | 2025-12-28 | Product concept |
| FE-007 | Medium | Features | Virtual Tourism - Detailed city guides when you "arrive" at destinations | v1.2 | 2025-12-28 | Product concept |
| FE-008 | Low | Integration | Wearable Support - Apple Watch, Wear OS support for tracking | v2.0 | 2025-12-28 | Product concept |
| ENH-001 | Medium | Social | Share Individual Runs - Share run statistics and route map on social media | v1.1 | 2026-01-10 | Session 032 Testing |

---

## Nice to Have

Lower priority items that could improve the system but are not critical.

| ID | Category | Description | Value | Added | Reference |
|----|----------|-------------|-------|-------|-----------|
| NTH-001 | Gamification | Achievement Badges & Collections - Earn badges for milestones, distance, streaks | Engagement | 2025-12-28 | Product concept |
| NTH-002 | Monetization | Sponsored Destinations - Tourism boards sponsor specific destinations with perks | Revenue | 2025-12-28 | Product concept |
| NTH-003 | Monetization | Affiliate Links - Book hotels in cities you "reach" through affiliate partnerships | Revenue | 2025-12-28 | Product concept |
| NTH-004 | B2B | Corporate Wellness - Team plans for companies, employee health challenges | Revenue | 2025-12-28 | Product concept |

---

## Items by Priority

### High Priority

High-impact features for user engagement and retention.

| ID | Type | Component/Category | Description | Target | Reference |
|----|------|-------------------|-------------|--------|-----------|
| FE-001 | Enhancement | Social | Friends & Following | v1.1 | Product concept |
| FE-002 | Enhancement | Social | Share Journey Progress | v1.1 | Product concept |
| FE-003 | Enhancement | Goals | Multiple Active Goals | v1.1 | Product concept |

### Medium Priority

Valuable features that enhance the experience but aren't critical.

| ID | Type | Component/Category | Description | Target | Reference |
|----|------|-------------------|-------------|--------|-----------|
| FE-004 | Enhancement | Social | Community Challenges | v1.2 | Product concept |
| FE-005 | Enhancement | Goals | Premium Route Packs | v1.2 | Product concept |
| FE-006 | Enhancement | Integration | Fitness App Integration | v1.2 | Product concept |
| FE-007 | Enhancement | Features | Virtual Tourism | v1.2 | Product concept |

### Low Priority

Nice additions but not essential for core experience.

| ID | Type | Component/Category | Description | Target | Reference |
|----|------|-------------------|-------------|--------|-----------|
| FE-008 | Enhancement | Integration | Wearable Support | v2.0 | Product concept |

---

## Items by Version Target

### v1.0 (MVP) - Launch

**Status:** In Planning
**Target Date:** 12-15 weeks from start
**Focus:** Core running tracker + journey gamification

**Features:**
- ✅ GPS run tracking
- ✅ Goal creation (any location to any location)
- ✅ Journey visualization on map
- ✅ Milestones with city photos & facts
- ✅ Run history
- ✅ User profile & settings
- ✅ Premium subscription ($2.99/mo or $19.99/yr)
- ✅ Freemium model (100km limit for free users)
- ✅ Firebase sync across devices
- ✅ AdMob ads for free users

**Not Included (Post-MVP):**
- Social features
- Multiple concurrent goals
- Advanced integrations

---

### v1.1 - Social Features

**Target Date:** 2-3 months post-launch
**Focus:** Social engagement and sharing

| ID | Feature | Priority | Description | Status |
|----|---------|----------|-------------|--------|
| FE-001 | Friends & Following | High | Add friends, see their progress | 🔲 Planned |
| FE-002 | Share Progress | High | Share milestones on social media | 🔲 Planned |
| FE-003 | Multiple Goals | High | Track multiple concurrent journeys | 🔲 Planned |
| ENH-001 | Share Individual Runs | Medium | Share run stats and route map | 🔲 Planned |

**Dependencies:**
- v1.0 must be stable and launched
- User base of 1,000+ active users
- Social infrastructure (friend connections, feed)

---

### v1.2 - Enhanced Features

**Target Date:** 4-6 months post-launch
**Focus:** Enhanced features and integrations

| ID | Feature | Priority | Description | Status |
|----|---------|----------|-------------|--------|
| FE-004 | Community Challenges | Medium | Group challenges and leaderboards | 🔲 Planned |
| FE-005 | Premium Route Packs | Medium | Curated famous routes | 🔲 Planned |
| FE-006 | Fitness Integrations | Medium | Sync with Apple Health, Google Fit | 🔲 Planned |
| FE-007 | Virtual Tourism | Medium | Detailed city guides at destinations | 🔲 Planned |

**Dependencies:**
- v1.1 social features
- User base of 5,000+ active users
- Content partnerships (tourism boards, etc.)

---

### v2.0 - Platform Expansion

**Target Date:** 6-12 months post-launch
**Focus:** Platform expansion and advanced features

| ID | Feature | Priority | Description | Status |
|----|---------|----------|-------------|--------|
| FE-008 | Wearable Support | Low | Apple Watch, Wear OS | 🔲 Planned |

**Dependencies:**
- Strong user retention (40%+ at 30 days)
- Revenue positive
- Technical resources for wearable development

---

## Items by Category

### Social Features

| ID | Priority | Description | Target | Status |
|----|----------|-------------|--------|--------|
| FE-001 | High | Friends & Following | v1.1 | 🔲 Planned |
| FE-002 | High | Share Journey Progress | v1.1 | 🔲 Planned |
| FE-004 | Medium | Community Challenges | v1.2 | 🔲 Planned |
| ENH-001 | Medium | Share Individual Runs | v1.1 | 🔲 Planned |

### Goals & Journey

| ID | Priority | Description | Target | Status |
|----|----------|-------------|--------|--------|
| FE-003 | High | Multiple Active Goals | v1.1 | 🔲 Planned |
| FE-005 | Medium | Premium Route Packs | v1.2 | 🔲 Planned |
| FE-007 | Medium | Virtual Tourism | v1.2 | 🔲 Planned |

### Integrations

| ID | Priority | Description | Target | Status |
|----|----------|-------------|--------|--------|
| FE-006 | Medium | Fitness App Integration | v1.2 | 🔲 Planned |
| FE-008 | Low | Wearable Support | v2.0 | 🔲 Planned |

### Gamification

| ID | Priority | Description | Target | Status |
|----|----------|-------------|--------|--------|
| NTH-001 | Nice-to-Have | Achievement Badges | Future | 🔲 Planned |

### Monetization

| ID | Priority | Description | Target | Status |
|----|----------|-------------|--------|--------|
| NTH-002 | Nice-to-Have | Sponsored Destinations | Future | 🔲 Planned |
| NTH-003 | Nice-to-Have | Affiliate Links | Future | 🔲 Planned |
| NTH-004 | Nice-to-Have | Corporate Wellness | Future | 🔲 Planned |

---

## Item Templates

### Technical Debt Item

**ID Format:** TD-XXX (e.g., TD-001)

**Template:**
```markdown
| ID | Priority | Component | Description | Impact | Effort | Added | Reference |
|----|----------|-----------|-------------|--------|--------|-------|-----------|
| TD-001 | High | GPS Tracking | GPS service needs refactoring for battery efficiency | Performance | Medium | YYYY-MM-DD | Sprint X |
```

**Required Information:**
- **ID:** Unique identifier
- **Priority:** High/Medium/Low based on impact
- **Component:** Which part of the app
- **Description:** What needs to be addressed
- **Impact:** Performance, Maintainability, Security, etc.
- **Effort:** Small (< 1 day) / Medium (1-3 days) / Large (> 3 days)
- **Added:** Date identified
- **Reference:** Sprint or session where identified

---

### Future Enhancement Item

**ID Format:** FE-XXX (e.g., FE-001)

**Template:**
```markdown
| ID | Priority | Category | Description | Sprint Target | Added | Reference |
|----|----------|----------|-------------|---------------|-------|-----------|
| FE-001 | High | Social | Friends & Following feature | v1.1 | YYYY-MM-DD | Product concept |
```

**Required Information:**
- **ID:** Unique identifier
- **Priority:** High/Medium/Low based on value and impact
- **Category:** Feature, Integration, UI/UX, etc.
- **Description:** Brief description of the enhancement
- **Sprint Target:** Which version/sprint to implement
- **Added:** Date added to backlog
- **Reference:** Source document or session

---

### Nice to Have Item

**ID Format:** NTH-XXX (e.g., NTH-001)

**Template:**
```markdown
| ID | Category | Description | Value | Added | Reference |
|----|----------|-------------|-------|-------|-----------|
| NTH-001 | Gamification | Achievement badges system | Engagement | YYYY-MM-DD | Brainstorm session |
```

**Required Information:**
- **ID:** Unique identifier
- **Category:** Type of feature
- **Description:** What it is
- **Value:** What benefit it provides
- **Added:** Date added
- **Reference:** Where the idea came from

---

## Priority & Effort Definitions

### Priority Levels

**High Priority:**
- Significant impact on user engagement or retention
- Directly addresses user pain points
- Competitive differentiator
- High revenue potential

**Medium Priority:**
- Moderate improvement to user experience
- Nice-to-have feature that enhances product
- Incremental revenue opportunity

**Low Priority:**
- Minor improvements or edge case features
- Low user demand
- Minimal competitive impact

### Effort Estimates

**Small:** < 1 day of development
- Simple UI changes
- Configuration updates
- Minor feature additions

**Medium:** 1-3 days of development
- New screens or flows
- Integration with external services
- Moderate complexity features

**Large:** > 3 days of development
- Major features with multiple components
- Complex integrations
- Significant refactoring

---

## Backlog Management

### When to Add Items

Add items to backlog when:
- Users request features
- Identifying areas for improvement during development
- Discovering technical debt
- Planning future roadmap
- Brainstorming new ideas

### Review Frequency

- **Weekly:** During development sprints
- **Monthly:** After major releases
- **Quarterly:** Strategic roadmap planning

### Prioritization Criteria

Consider these factors when prioritizing:
1. **User Impact:** How many users benefit?
2. **Business Value:** Revenue potential or retention impact?
3. **Effort:** Development time required?
4. **Dependencies:** What else needs to be done first?
5. **Timing:** Is now the right time?

---

**Last Updated:** 2026-01-10 (Session 032 - Run Summary & History Testing)
**Total Items:** 15
**Tech Debt Open:** 2 (TD-001, TD-002)
**Tech Debt Complete:** 1 (TD-003 - Session 23)
**Future Enhancements:** 9 (FE-001 to FE-008, ENH-001)
**Next Review:** After Sprint 18 completion
