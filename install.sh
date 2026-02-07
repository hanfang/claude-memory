#!/bin/bash

set -e

CLAUDE_DIR="$HOME/.claude"
MEMORY_DIR="$CLAUDE_DIR/memory"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Claude Memory Skill..."

# Create directories
mkdir -p "$MEMORY_DIR/topics"
mkdir -p "$MEMORY_DIR/projects"
mkdir -p "$COMMANDS_DIR"

# Copy skill file
if [ -f "$SCRIPT_DIR/skill/mem.md" ]; then
    cp "$SCRIPT_DIR/skill/mem.md" "$COMMANDS_DIR/mem.md"
else
    # Inline skill content for curl install
    cat > "$COMMANDS_DIR/mem.md" << 'SKILL_EOF'
# Memory Skill

You have a persistent hierarchical memory system at `~/.claude/memory/`.

## Structure

```
~/.claude/memory/
├── core.md              # Summaries + pointers (always loaded)
├── me.md                # About the user (always loaded)
├── topics/
│   └── <topic>.md       # Detailed entries by topic
└── projects/
    └── <project>.md     # Project-specific knowledge
```

## Commands

### `/mem load` — Session Start

Run in background at session start. Spawns a memory agent to:
1. Read `~/.claude/memory/me.md`
2. Read `~/.claude/memory/core.md`
3. If in a git repo, check for `projects/<project>.md`
4. Return a context summary

**Usage:** At the start of a session, spawn a background agent:
```
Task(subagent_type="general-purpose", run_in_background=true, prompt="""
Memory load task. Read and summarize:
1. ~/.claude/memory/me.md (who the user is)
2. ~/.claude/memory/core.md (key learnings + pointers)
3. Check if projects/<current-project>.md exists

Return a brief context summary for the main agent.
""")
```

### `/mem save <observation>` — Persist Learning

Run in background when you learn something worth keeping. Spawns a memory agent to:
1. Categorize the observation (pick or create a topic)
2. Append to `topics/<topic>.md` with format:
   ```markdown
   ## <Short title> [YYYY-MM-DD]
   <The insight in 1-3 sentences>
   ```
3. If this is a significant/recurring insight, update `core.md`:
   ```markdown
   ## <Topic>
   <One-line summary>
   → topics/<topic>.md
   ```

**Usage:** Spawn a background agent:
```
Task(subagent_type="general-purpose", run_in_background=true, prompt="""
Memory save task. Observation to save:
"<the observation>"

1. Determine the topic (debugging, patterns, tools, <domain>, etc.)
2. Read ~/.claude/memory/topics/<topic>.md if it exists
3. Append the observation with timestamp
4. If this represents a significant pattern, update core.md with a summary + pointer
""")
```

### `/mem recall <query>` — Retrieve Context

Run when you need specific context. Can block if context is immediately needed.
1. Grep `core.md` for relevant topics
2. Follow pointers to load matching topic files
3. Return relevant entries

**Usage:** Spawn an agent (can be blocking):
```
Task(subagent_type="general-purpose", prompt="""
Memory recall task. Query: "<the query>"

1. Read ~/.claude/memory/core.md
2. Identify relevant topic pointers
3. Read those topic files
4. Return entries relevant to the query
""")
```

### `/mem show` — Display State

Show current memory structure and contents.
1. List all files in `~/.claude/memory/`
2. Show contents of `core.md`
3. Show summary of each topic file (first few lines)

### `/mem forget <topic>` — Remove Entries

Remove a topic or specific entries.
1. Delete `topics/<topic>.md` if removing whole topic
2. Remove corresponding entry from `core.md`

## When to Save

Save silently in background when:
- User explicitly says "remember..." or similar
- You solve a non-trivial problem
- You discover a user preference
- You learn something project-specific
- A pattern emerges across multiple interactions

## When to Recall

Recall when:
- Starting unfamiliar work (check for relevant past learnings)
- Stuck on a problem (search for similar past issues)
- User asks "do you remember..."
- Context from memory would clearly help

## Principles

- **Background ops**: Load and save don't block the main agent
- **Hierarchical**: core.md summaries → topic details
- **Categorized**: No dumping ground, everything has a topic
- **Atomic entries**: One `##` block = one memory
- **User editable**: Plain markdown, user can edit anytime
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

if [ ! -f "$MEMORY_DIR/core.md" ]; then
    cat > "$MEMORY_DIR/core.md" << 'EOF'
# Core Memory

<!-- Summaries + pointers to topic files -->
<!-- Updated by memory agent when topics accumulate significant insights -->

EOF
    echo "Created $MEMORY_DIR/core.md"
fi

# Add hook to CLAUDE.md
HOOK_TEXT="## Memory

I have a hierarchical memory system at \`~/.claude/memory/\`.

**Session start:** Run \`/mem load\` in background to load context.
**During session:** Run \`/mem save <observation>\` in background when I learn something worth keeping.
**When stuck:** Run \`/mem recall <query>\` to retrieve relevant past learnings.

Memory structure: \`core.md\` (summaries + pointers) → \`topics/<topic>.md\` (details)"

if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    if grep -q "hierarchical memory" "$CLAUDE_DIR/CLAUDE.md"; then
        echo "Memory hook already exists in CLAUDE.md"
    else
        # Remove old memory hook if present
        if grep -q "persistent memory" "$CLAUDE_DIR/CLAUDE.md"; then
            echo "Updating existing memory hook..."
            # Create backup
            cp "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.bak"
        fi
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
echo "  /mem load      - load memory context (runs at session start)"
echo "  /mem save X    - save an observation"
echo "  /mem recall X  - retrieve relevant memories"
echo "  /mem show      - see memory structure"
echo "  /mem forget X  - remove memories about X"
