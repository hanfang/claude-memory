# Claude Memory

A minimal, low-friction memory system for Claude Code.

## The Problem

Claude Code forgets everything between sessions. Built-in auto-memory exists but:
- It's opaque (Claude decides what's "meaningful")
- Limited to 200 lines loaded at startup
- Not tightly integrated into the agentic loop

## The Solution

A skill-based memory protocol that:
- Uses the filesystem (robust, inspectable, git-trackable)
- Follows a clear behavioral protocol (when to read/write)
- Operates silently (no confirmation prompts, no verbose logging)
- Scales automatically (splits files when they get large)

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/claude-memory/main/install.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/YOUR_USERNAME/claude-memory.git
cd claude-memory
./install.sh
```

## What Gets Installed

```
~/.claude/
├── CLAUDE.md              # Hook added (or created)
├── commands/
│   └── mem.md             # The memory skill
└── memory/
    ├── me.md              # About you (fill this in)
    ├── learnings.md       # Claude writes insights here
    └── projects/          # Project-specific memories
```

## Usage

### Automatic Behavior

Once installed, Claude will:
- Load `me.md` at every session start
- Grep `learnings.md` when context would help
- Write entries silently when learning something useful
- Auto-split files when they exceed ~50 entries

### Commands

| Command | Description |
|---------|-------------|
| `/mem` | Invoke memory skill |
| `/mem show` | Display current memory state |
| `/mem search <query>` | Search memory for a term |
| `/mem forget <topic>` | Remove entries matching topic |

### Tell Claude What to Remember

Just say it naturally:
- "Remember that we use pnpm, not npm"
- "Save that the API requires auth headers"
- "Note that tests need Redis running"

### Fill In Your Profile

Edit `~/.claude/memory/me.md` with facts about yourself:

```markdown
# About the User

- Backend engineer, Go and Python
- Prefer explicit code over clever abstractions
- Use vim keybindings
- Work on distributed systems
```

## How It Works

### Memory Format

Entries are stored as atomic blocks:

```markdown
## Short title [YYYY-MM-DD]
The insight in 1-3 sentences.
Tags: keyword1, keyword2
```

### Scaling

When `learnings.md` exceeds ~50 entries, Claude splits it into topic files:

```
~/.claude/memory/
├── learnings.md           # Uncategorized entries
├── learnings-debugging.md # Debugging insights
├── learnings-patterns.md  # Code patterns
└── ...
```

### Retrieval

No semantic search. Claude uses grep with tags/keywords for deterministic retrieval.

## Design Principles

- **Silent operation**: No "Saved to memory!" announcements
- **Lazy loading**: Grep when needed, don't preload everything
- **User control**: Edit files directly, use "forget" to remove entries
- **Atomic entries**: One heading = one memory, easy to delete
- **No magic**: Plain text files, grep-based search, fully inspectable

## Uninstall

```bash
rm -rf ~/.claude/memory
rm ~/.claude/commands/mem.md
# Manually remove the memory hook from ~/.claude/CLAUDE.md
```

## License

MIT
