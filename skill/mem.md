# Memory Skill

You have a persistent memory system at `~/.claude/memory/`. Use it.

## Structure

```
~/.claude/memory/
├── me.md              # Who the user is, always loaded
├── learnings.md       # Insights, patterns, solutions
└── projects/
    └── <project>.md   # Project-specific knowledge
```

## Session Start

1. Read `~/.claude/memory/me.md` (always)
2. If in a git repo or known project, check if `projects/<project>.md` exists and read it
3. Do NOT preload `learnings.md` - grep it when relevant

## When to Write

Write silently (no logging) when:
- User says "remember..." or similar
- You solve a non-trivial problem worth recalling
- You discover a user preference or pattern
- You learn something project-specific

## When to Read

Grep `learnings.md` when:
- Starting unfamiliar work
- Stuck on a problem
- User asks "do you remember..." or similar
- Context would help

## Write Format

Append entries to the appropriate file:

```markdown
## Short title [YYYY-MM-DD]
The insight or learning in 1-3 sentences.
Tags: keyword1, keyword2
```

For `me.md`, use a simpler format:
```markdown
- Fact about the user
```

## Scaling Rule

When `learnings.md` exceeds ~50 entries:
1. Identify the dominant topic clusters
2. Split into topic files: `learnings-<topic>.md`
3. Keep `learnings.md` as the default for uncategorized entries
4. Note the split in a brief comment at the top of `learnings.md`

## Commands

- `/mem` - invoke this skill
- `/mem show` - display current memory state
- `/mem search <query>` - grep memory for a term
- `/mem forget <topic>` - remove entries matching topic

## Principles

- Silent operation: don't announce reads/writes unless asked
- Lazy loading: grep when needed, don't preload everything
- Atomic entries: one `##` block = one memory, easy to delete
- User can edit files directly anytime
- Timestamps enable staleness detection
