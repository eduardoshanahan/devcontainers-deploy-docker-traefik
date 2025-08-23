# Multi-Session Development Rules

## Never Lose Context Between Sessions

### **Core Principle: Seamless Continuity**

When working across multiple development sessions, **NEVER lose context** or assume knowledge from previous sessions. Every session must be self-contained while building upon previous work.

### **Rule: Comprehensive Session Documentation**

**FAIL - Don't do this**:

- Start coding without reviewing previous session
- Assume previous decisions are still valid
- Skip documentation updates
- Ignore pending issues from last session

**PASS - Do this instead**:

- Always review previous session documentation
- Verify current project state before starting
- Document all changes and decisions
- Maintain clear session continuity

## Session Workflow

### **1. Session Start (ALWAYS)**

**Before writing any code:**

```bash
# Review previous session
git log --oneline -10
git diff HEAD~1

# Check current state
ls -la documentation/sessions/
cat documentation/sessions/current-session.md

# Verify project status
cat documentation/research-and-development/progress/current-state.md
```

**Required Actions:**

- [ ] Read previous session summary
- [ ] Check current project state
- [ ] Review pending decisions
- [ ] Verify current phase
- [ ] Understand next goals

### **2. Session Progress (CONTINUOUS)**

**During development:**

```bash
# Update progress continuously
echo "## Progress Update $(date)" >> documentation/sessions/current-session.md
echo "- Completed: [task description]" >> documentation/sessions/current-session.md
echo "- Next: [next task]" >> documentation/sessions/current-session.md
```

**Required Actions:**

- [ ] Document every significant change
- [ ] Update progress tracking
- [ ] Record decisions made
- [ ] Note issues encountered
- [ ] Track file modifications

### **3. Session End (ALWAYS)**

**Before ending session:**

```bash
# Create session summary
cp documentation/sessions/current-session.md documentation/sessions/session-001-summary.md

# Update current state
cat documentation/research-and-development/progress/current-state.md

# Prepare next session
echo "## Next Session Goals" >> documentation/sessions/current-session.md
echo "1. [Goal 1]" >> documentation/sessions/current-session.md
echo "2. [Goal 2]" >> documentation/sessions/current-session.md
```

**Required Actions:**

- [ ] Create session summary
- [ ] Update current state
- [ ] Document next session goals
- [ ] Commit all changes
- [ ] Verify documentation completeness

## Documentation Requirements

### **1. Session Documentation**

**Every session must include:**

```markdown
# Session X: [Session Title]

## Session Overview
- **Date**: [Date]
- **Duration**: [Duration]
- **Focus**: [Main focus area]
- **Status**: [In Progress/Complete]

## Session Objectives
1. [Objective 1]
2. [Objective 2]
3. [Objective 3]

## Session Progress
### Phase X: [Phase Name] - [Status]
- [Task 1]: [Status]
- [Task 2]: [Status]

## Key Deliverables
1. [Deliverable 1]
2. [Deliverable 2]

## Session Notes
### Key Insights
- [Insight 1]
- [Insight 2]

### Technical Decisions
- [Decision 1]
- [Decision 2]

## Blockers and Issues
- [Issue 1]: [Status]
- [Issue 2]: [Status]

## Next Session Planning
**Priority Tasks for Next Session**:
1. [Task 1]
2. [Task 2]

## Session Metrics
- **Files Created**: [Number]
- **Decisions Documented**: [Number]
- **Requirements Defined**: [Number]

## Session Summary
**Major Accomplishments**:
- [Accomplishment 1]
- [Accomplishment 2]

**Key Decisions Finalized**:
1. [Decision 1]
2. [Decision 2]

**Next Session Focus**:
- [Focus area 1]
- [Focus area 2]

## Session Closure
**Session X Status**: [COMPLETED SUCCESSFULLY/IN PROGRESS]

**All objectives achieved**:
- [Objective 1]: [Status]
- [Objective 2]: [Status]

**Next Session**: Session X+1 - [Next Session Title]
**Estimated Start**: [Date]
**Priority**: [Priority level]
```

### **2. Progress Tracking**

**Every session must update:**

```markdown
# Current State

## Project Status
- **Current Phase**: [Phase X.Y]
- **Phase Status**: [In Progress/Complete]
- **Overall Progress**: [X% Complete]

## Recent Changes
- [Date]: [Change description]
- [Date]: [Change description]

## Current Focus
- **Primary Goal**: [Goal description]
- **Secondary Goals**: [Goal list]
- **Blockers**: [Blocker list]

## Next Steps
1. [Next step 1]
2. [Next step 2]
3. [Next step 3]
```

### **3. Decision Log**

**Every decision must be documented:**

```markdown
# Decision X: [Decision Title]

**Date**: [Date]
**Session**: Session X
**Context**: [What led to this decision]

**Decision**: [What was decided]

**Rationale**: [Why this decision was made]

**Alternatives Considered**: [What other options were considered]

**Impact**: [What this decision affects]

**Status**: [Pending/Implemented/Rejected]
```

## File Organization

### **1. Session Files**

```text
sessions/
├── current-session.md          # Active session documentation
├── session-001-summary.md      # Session 1 summary
├── session-002-summary.md      # Session 2 summary
└── session-XXX-summary.md      # Session X summary
```

### **2. Progress Files**

```text
progress/
├── implementation-progress.md  # Overall progress tracking
├── decision-log.md            # All decisions made
└── issues-log.md              # Issues and resolutions
```

### **3. Continuity Management**

```text
continuity/
├── current-state.md           # Current project state
├── session-continuity.md      # Session-to-session continuity
└── knowledge-base.md          # Accumulated knowledge
```

## Quality Assurance

### **1. Session Review**

- **ALWAYS** review session documentation before ending
- **ALWAYS** verify all changes are documented
- **ALWAYS** ensure next session goals are clear
- **ALWAYS** validate that context is preserved

### **2. Documentation Validation**

- **ALWAYS** check that all files created/modified are listed
- **ALWAYS** verify that all decisions are documented
- **ALWAYS** ensure that issues are properly described
- **ALWAYS** confirm that next steps are actionable

## Summary

**NEVER lose context** - always maintain comprehensive session documentation to ensure seamless project continuity across multiple development sessions.
