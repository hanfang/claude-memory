#!/bin/bash

set -e

CLAUDE_DIR="$HOME/.claude"
MEMORY_DIR="$CLAUDE_DIR/memory"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Claude Memory..."

# Create directories
mkdir -p "$MEMORY_DIR/projects"
mkdir -p "$COMMANDS_DIR"

# Copy skill file
if [ -f "$SCRIPT_DIR/skill/mem.md" ]; then
    cp "$SCRIPT_DIR/skill/mem.md" "$COMMANDS_DIR/mem.md"
else
    # Inline skill content for curl install
    cat > "$COMMANDS_DIR/mem.md" << 'SKILL_EOF'
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
SKILL_EOF
fi

# Create template files if they don't exist
if [ ! -f "$MEMORY_DIR/me.md" ]; then
    cat > "$MEMORY_DIR/me.md" << 'EOF'
# About the User

<!-- Add facts about yourself: role, preferences, tech stack, etc. -->
<!-- Claude loads this at every session start. -->

EOF
    echo "Created $MEMORY_DIR/me.md"
fi

if [ ! -f "$MEMORY_DIR/learnings.md" ]; then
    cat > "$MEMORY_DIR/learnings.md" << 'EOF'
# Learnings

<!-- Claude appends insights, patterns, and solutions here. -->
<!-- Format: ## Title [YYYY-MM-DD] \n Description \n Tags: ... -->

EOF
    echo "Created $MEMORY_DIR/learnings.md"
fi

# Add hook to CLAUDE.md
HOOK_TEXT="## Memory

I have persistent memory at \`~/.claude/memory/\`. At session start, I load \`me.md\`. I grep \`learnings.md\` and \`projects/\` when relevant context would help. I write silently when I learn something worth keeping. Use \`/mem\` to view or manage memory."

if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    if grep -q "persistent memory" "$CLAUDE_DIR/CLAUDE.md"; then
        echo "Memory hook already exists in CLAUDE.md"
    else
        echo "" >> "$CLAUDE_DIR/CLAUDE.md"
        echo "$HOOK_TEXT" >> "$CLAUDE_DIR/CLAUDE.md"
        echo "Added memory hook to existing CLAUDE.md"
    fi
else
    echo "# Claude Code Settings" > "$CLAUDE_DIR/CLAUDE.md"
    echo "" >> "$CLAUDE_DIR/CLAUDE.md"
    echo "$HOOK_TEXT" >> "$CLAUDE_DIR/CLAUDE.md"
    echo "Created $CLAUDE_DIR/CLAUDE.md with memory hook"
fi

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Edit ~/.claude/memory/me.md with facts about yourself"
echo "  2. Start a new Claude Code session"
echo "  3. Claude will now remember things across sessions"
echo ""
echo "Commands:"
echo "  /mem           - manage memory"
echo "  /mem show      - see what Claude remembers"
echo "  /mem forget X  - remove memories about X"
