```
     _____ _____ _____
    |     |   __|     |  claude-memory-skill
    | | | |   __| | | |  ────────────────────
    |_|_|_|_____|_|_|_|  persistent memory for claude code
```

A hierarchical, agent-driven memory system for Claude Code.

## The Problem

Claude Code forgets everything between sessions. Built-in auto-memory exists but:
- It's opaque (Claude decides what's "meaningful")
- Limited to 200 lines loaded at startup
- Not tightly integrated into the agentic loop
- No hierarchical organization (scales poorly)

## The Solution

A skill-based memory protocol with:
- **Hierarchical storage**: `core.md` summaries → `topics/<topic>.md` details
- **Background agents**: Memory ops don't block the main agent
- **Categorized entries**: No dumping ground, everything has a topic
- **Filesystem-based**: Robust, inspectable, git-trackable

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/hanfang/claude-memory-skill/main/install.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/hanfang/claude-memory-skill.git
cd claude-memory-skill
./install.sh
```

## What Gets Installed

```
~/.claude/
├── CLAUDE.md              # Hook added (or created)
├── commands/
│   └── mem.md             # The memory skill
└── memory/
    ├── core.md            # Summaries + pointers (always loaded)
    ├── me.md              # About you (always loaded)
    ├── topics/            # Detailed entries by topic
    │   └── <topic>.md
    └── projects/          # Project-specific memories
        └── <project>.md
```

## Architecture

```
┌─────────────────────────────────────────────────────┐
│  Main Agent                                         │
│  - Focuses on user's task                           │
│  - Spawns memory agent when needed                  │
│  - Doesn't wait (background)                        │
└─────────────────────┬───────────────────────────────┘
                      │ spawn (background)
                      ▼
┌─────────────────────────────────────────────────────┐
│  Memory Agent                                       │
│  - Reads core.md + relevant topics                  │
│  - Writes to topic files                            │
│  - Updates core.md summaries                        │
└─────────────────────────────────────────────────────┘
```

## How It Works

### Agent-Initiated (Automatic)

These run automatically — you don't invoke them:

| Action | When | Blocking |
|--------|------|----------|
| `load` | Session start | No |
| `save` | Claude learns something useful | No |
| `recall` | Claude needs context | No |

### User-Initiated (Manual)

These are for you to inspect and manage memory:

| Command | Description |
|---------|-------------|
| `/mem show` | Display memory structure and contents |
| `/mem forget <topic>` | Remove a topic or specific entries |

### Tell Claude What to Remember

Just say it naturally:
- "Remember that we use pnpm, not npm"
- "Save that the API requires auth headers"
- "Note that tests need Redis running"

### Fill In Your Profile

Edit `~/.claude/memory/me.md` with facts about yourself:

```markdown
# About the User

- AI researcher, focus on agents and RL
- Prefer explicit code over clever abstractions
- Python, PyTorch, JAX
```

### Hierarchical Memory

**core.md** (always loaded):
```markdown
# Core Memory

## Debugging
Mostly async/timing issues. Prefer explicit logging.
→ topics/debugging.md

## RL Research
PPO tuning, reward shaping experiments.
→ topics/rl.md
```

**topics/debugging.md** (loaded on demand):
```markdown
## Async race condition fix [2024-01-15]
Added explicit locks around shared state access.

## Redis timeout debugging [2024-01-10]
Default timeout was too short for large payloads.
```

### Write Flow

1. Learn something → spawn background memory agent
2. Agent categorizes → finds or creates topic file
3. Agent appends entry with timestamp
4. If significant, agent updates core.md summary

### Read Flow

1. Session start → agent reads core.md + me.md in background
2. When stuck → agent follows pointers to relevant topics
3. Returns context to main agent

## Design Principles

- **Background ops**: Memory doesn't block the main agent
- **Hierarchical**: Summaries in core.md, details in topics
- **Categorized**: Every entry belongs to a topic
- **Atomic entries**: One `##` block = one memory
- **No semantic search**: Deterministic, grep-based retrieval
- **User editable**: Plain markdown, edit anytime

## Uninstall

```bash
rm -rf ~/.claude/memory
rm ~/.claude/commands/mem.md
# Manually remove the memory hook from ~/.claude/CLAUDE.md
```

## License

MIT
