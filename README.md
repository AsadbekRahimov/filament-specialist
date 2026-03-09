# Filament v5 Specialist - Claude Code Skill

Expert FilamentPHP v5 assistant for Claude Code. Generates resources, forms, tables, actions, widgets, infolists, schemas, and Pest tests following official Filament v5 documentation patterns.

## Installation

Clone directly into Claude Code's skills directory:

```bash
# Global (available in all projects)
git clone https://github.com/AsadbekRahimov/filament-specialist.git ~/.claude/skills/filament-specialist

# Project-level (available only in this project)
git clone https://github.com/AsadbekRahimov/filament-specialist.git .claude/skills/filament-specialist
```

That's it. Claude Code will automatically discover the `SKILL.md` at:
```
~/.claude/skills/filament-specialist/SKILL.md
```

### Populate Documentation (optional)

Fetch the official FilamentPHP v5 docs from GitHub for offline reference:

```bash
bash ~/.claude/skills/filament-specialist/docs/rebuildFilamentDocs.sh
```

## Requirements

- PHP 8.2+
- Laravel 11.28+
- FilamentPHP v5.x
- Livewire v4.0+
- Tailwind CSS v4.1+
- Pest testing framework

## What It Can Do

- **Generate CRUD Resources** — Complete resources with forms, tables, pages, and relation managers
- **Build Forms** — 20+ field types, validation, reactivity, layout components
- **Configure Tables** — Columns, filters, actions, summaries, grouping
- **Create Actions** — Modal actions, CRUD actions, import/export, bulk actions
- **Build Widgets** — Stats overview, charts, table widgets
- **Create Infolists** — Read-only data displays
- **Generate Notifications** — Flash, database, and broadcast notifications
- **Write Tests** — Comprehensive Pest tests for all components
- **Build Dashboards** — Multi-tab dashboards with filters and widgets
- **Diagnose Issues** — Error identification and troubleshooting

## Structure

```
filament-specialist/
├── SKILL.md                         # Main skill (Claude Code entry point)
├── references/                      # Detailed code references
│   ├── resource.md                  # CRUD resource generation
│   ├── form.md                      # Form schemas and fields
│   ├── table.md                     # Table configurations
│   ├── action.md                    # Actions, modals, import/export
│   ├── widget.md                    # Dashboard widgets
│   ├── infolist.md                  # Read-only data displays
│   ├── test.md                      # Pest test generation
│   ├── notification.md              # Notification system
│   ├── dashboard.md                 # Dashboard pages
│   ├── diagnose.md                  # Error diagnosis
│   └── docs-search.md              # Documentation search guide
├── docs/                            # Official Filament v5 documentation
│   ├── rebuildFilamentDocs.sh       # Script to fetch docs from GitHub
│   └── references/                  # Local copy of official docs
└── README.md
```

## Filament v5 vs v4

Filament v5 has **no new Filament-specific features** over v4. The major version bump is solely for **Livewire v4 compatibility**. Features ship to both v4 and v5 in parallel.

### Notable Features (available in both v4.5+ and v5)
- Schemas package, Import/Export actions, Code editor, Slider, ModalTableSelect
- Flex layout, FusedGroup, Enhanced reactivity (`afterStateUpdatedJs`, `hiddenJs`)
- Type-safe Get, RichEditor enhancements, Rate limiting, Keyboard shortcuts
- TestAction helper, Clusters, Resource sub-navigation, Dashboard FilterAction
